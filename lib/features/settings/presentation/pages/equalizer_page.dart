import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../../../player/data/services/audio_player_service.dart';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  static const platform = MethodChannel('com.ezra.musicplayer/equalizer');
  
  bool _enableCustomEq = false;
  int? _sessionId;
  
  // Equalizer State
  List<int> _bands = []; // Center frequencies
  List<double> _bandLevels = [];
  int _minLevel = -1500; // millibels
  int _maxLevel = 1500;

  @override
  void initState() {
    super.initState();
    _initEqualizer();
  }

  Future<void> _initEqualizer() async {
    final service = getIt<AudioPlayerService>();
    _sessionId = await service.getAudioSessionId();

    if (_sessionId == null) {
      debugPrint("Audio Session ID is null. Falling back to Global Session (0).");
      _sessionId = 0;
    }

    if (_sessionId != null) {
      try {
        await platform.invokeMethod('init', {'sessionId': _sessionId});
        bool enabled = await platform.invokeMethod('isEnabled');
        
        final List<dynamic> range = await platform.invokeMethod('getBandLevelRange');
        _minLevel = range[0];
        _maxLevel = range[1];

        final List<dynamic> freqs = await platform.invokeMethod('getCenterBandFreqs');
        _bands = freqs.cast<int>();
        
        // Initialize levels
        _bandLevels = [];
        for (int i = 0; i < _bands.length; i++) {
          final int level = await platform.invokeMethod('getBandLevel', {'band': i});
          _bandLevels.add(level.toDouble());
        }

        if (mounted) {
           setState(() {
             _enableCustomEq = enabled;
           });
        }
      } catch (e) {
        debugPrint("Error init equalizer: $e");
        if (mounted) showSnackBar("Failed to init Equalizer: $e");
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _forceInitGlobal() async {
     try {
        await platform.invokeMethod('init', {'sessionId': 0});
        
        bool enabled = await platform.invokeMethod('isEnabled');
        
        final List<dynamic> range = await platform.invokeMethod('getBandLevelRange');
        _minLevel = range[0];
        _maxLevel = range[1];

        final List<dynamic> freqs = await platform.invokeMethod('getCenterBandFreqs');
        _bands = freqs.cast<int>();
        
        _bandLevels = [];
        for (int i = 0; i < _bands.length; i++) {
          final int level = await platform.invokeMethod('getBandLevel', {'band': i});
          _bandLevels.add(level.toDouble());
        }

        if (mounted) {
           setState(() {
             _sessionId = 0;
             _enableCustomEq = enabled;
           });
        }
      } catch (e) {
        debugPrint("Error force init global: $e");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Force Global Init Failed: $e")));
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Equalizer"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initEqualizer,
            tooltip: "Retry Connection",
          ),
        ],
      ),
      body: Container(
         decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                 Color(0xFF0F0F1A), 
                 Color(0xFF050510),
              ],
            ),
          ),
        child: Column(
          children: [
            if (_sessionId == null)
              const Expanded(child: Center(child: Text("Audio Session not available (Start music first)", style: TextStyle(color: Colors.white54)))),
            
            if (_sessionId != null && _bands.isEmpty) ...[
               const Expanded(
                 child: Center(
                   child: Text("Equalizer connected but no bands found.\nTry playing music and refreshing.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                 ),
               ),
            ],

            if (_sessionId != null && _bands.isNotEmpty) ...[
              SwitchListTile(
                title: const Text("Enable Equalizer", style: TextStyle(color: Colors.white)),
                value: _enableCustomEq,
                activeColor: const Color(0xFF39C5BB),
                onChanged: (value) async {
                   try {
                     await platform.invokeMethod('enable', {'enable': value});
                     setState(() {
                       _enableCustomEq = value;
                     });
                   } catch(e) {
                     debugPrint("Error toggle eq: $e");
                   }
                },
              ),
              const Divider(color: Colors.white10),
              
              if (_bands.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _bands.length,
                    itemBuilder: (context, index) {
                      final freq = _bands[index];
                      // Freq is in milliHertz
                      final freqHz = freq / 1000;
                      final freqLabel = freqHz < 1000 ? "${freqHz.toInt()} Hz" : "${(freqHz/1000).toStringAsFixed(1)} kHz";
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(freqLabel, style: const TextStyle(color: Colors.white54)),
                          Row(
                            children: [
                              Text("${(_minLevel/100).toInt()}dB", style: const TextStyle(color: Colors.white24, fontSize: 10)),
                              Expanded(
                                child: Slider(
                                  min: _minLevel.toDouble(),
                                  max: _maxLevel.toDouble(),
                                  value: _bandLevels.length > index ? _bandLevels[index] : 0,
                                  activeColor: const Color(0xFF39C5BB),
                                  inactiveColor: Colors.white12,
                                  onChanged: _enableCustomEq ? (value) async {
                                     setState(() {
                                       _bandLevels[index] = value;
                                     });
                                     await platform.invokeMethod('setBandLevel', {'band': index, 'level': value.toInt()});
                                  } : null,
                                ),
                              ),
                              Text("${(_maxLevel/100).toInt()}dB", style: const TextStyle(color: Colors.white24, fontSize: 10)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}


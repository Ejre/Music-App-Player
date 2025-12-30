
  Future<void> _forceInitGlobal() async {
     try {
        await platform.invokeMethod('init', {'sessionId': 0});
        _sessionId = 0; // Fake it for UI
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

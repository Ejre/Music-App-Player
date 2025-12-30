import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../player/presentation/bloc/player_bloc.dart';
import '../../../player/presentation/bloc/player_event.dart';
import 'equalizer_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Timer duration in minutes. 0 means off.
  int _selectedDuration = 0; 
  String _timerLabel = "Off";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
               Color(0xFF2D0019), 
               Color(0xFF101010),
            ],
          ),
        ),
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Audio Settings", 
                style: TextStyle(color: Color(0xFF39C5BB), fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined, color: Colors.white),
              title: const Text("Sleep Timer", style: TextStyle(color: Colors.white)),
              subtitle: Text("Stop audio after $_timerLabel", 
                style: const TextStyle(color: Colors.white54)),
              onTap: () => _showSleepTimerDialog(),
            ),
            
            ListTile(
               leading: const Icon(Icons.equalizer, color: Colors.white),
               title: const Text("Equalizer", style: TextStyle(color: Colors.white)),
               subtitle: const Text("Adjust audio frequencies", style: TextStyle(color: Colors.white54)),
               onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const EqualizerPage()));
               }, 
            ),

            const Divider(color: Colors.white10),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("App Settings", 
                style: TextStyle(color: Color(0xFF39C5BB), fontWeight: FontWeight.bold)),
            ),
             ListTile(
               leading: const Icon(Icons.color_lens_outlined, color: Colors.white),
               title: const Text("Theme", style: TextStyle(color: Colors.white)),
               subtitle: BlocBuilder<ThemeCubit, ThemeData>(
                 builder: (context, theme) {
                   return const Text("Change App Theme", style: TextStyle(color: Colors.white54));
                 },
               ),
               onTap: () => _showThemeDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Set Sleep Timer", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               _buildTimerOption(15, "15 minutes"),
               _buildTimerOption(30, "30 minutes"),
               _buildTimerOption(60, "1 hour"),
               _buildTimerOption(0, "Turn Off"),
            ],
          ),
          actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text("Cancel"),
             )
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Select Theme", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               ListTile(
                 title: const Text("Miku Dark (Default)", style: TextStyle(color: Colors.white)),
                 onTap: () {
                   context.read<ThemeCubit>().setTheme(AppThemeType.mikuDark);
                   Navigator.pop(context);
                 },
               ),
               ListTile(
                 title: const Text("Neon Mode", style: TextStyle(color: Colors.white)),
                 onTap: () {
                   context.read<ThemeCubit>().setTheme(AppThemeType.mikuLight);
                   Navigator.pop(context);
                 },
               ),
               ListTile(
                 title: const Text("Sakura Miku (Pink)", style: TextStyle(color: Colors.white)),
                 onTap: () {
                   context.read<ThemeCubit>().setTheme(AppThemeType.sakuraMiku);
                   Navigator.pop(context);
                 },
               ),
            ],
          ),
          actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text("Cancel"),
             )
          ],
        );
      },
    );
  }

  Widget _buildTimerOption(int minutes, String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
         setState(() {
           _selectedDuration = minutes;
           _timerLabel = label;
           if (minutes == 0) {
             _timerLabel = "Off";
           }
         });
         
         if (minutes > 0) {
            context.read<PlayerBloc>().add(SetSleepTimer(Duration(minutes: minutes)));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sleep timer set for $label")),
            );
         } else {
            context.read<PlayerBloc>().add(CancelSleepTimer());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sleep timer turned off")),
            );
         }
         Navigator.pop(context);
      },
    );
  }
}

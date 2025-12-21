import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../features/player/presentation/bloc/player_bloc.dart';
import '../../../../features/player/presentation/bloc/player_event.dart';
import '../../../../features/player/presentation/widgets/mini_player_widget.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import 'song_search_delegate.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../bloc/library_event.dart'; // Ensure event is imported
import '../../../../features/player/presentation/bloc/player_state.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_bottom_sheet.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // We'll inject the AudioPlayerService directly here for now for simplicity,
  // ideally this should be in a PlayerBloc.

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    // Determine which permission to ask based on Android version/Platform
    // For simplicity, we ask for both (runtime checks handling internally by plugin usually or we logic check)
    // Actually permission_handler handles this well.
    
    // For Android 13+ (SDK 33), we need READ_MEDIA_AUDIO
    // For below, READ_EXTERNAL_STORAGE.
    
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.audio,
    ].request();
    
    // For Android 11+ (R) we might need Manage External Storage for full delete access
    // This is frowned upon by Play Store but fine for personal app.
    if (await Permission.manageExternalStorage.status.isDenied) {
        await Permission.manageExternalStorage.request();
    }

    if (statuses[Permission.storage]!.isGranted || 
        statuses[Permission.audio]!.isGranted ||
        await Permission.manageExternalStorage.isGranted) {
       _loadSongs();
    } else {
       // Show dialog or retry
       debugPrint("Permission denied");
    }
  }

  void _loadSongs() {
    context.read<LibraryBloc>().add(LoadSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('μRhythm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
               showSearch(context: context, delegate: SongSearchDelegate(context.read<LibraryBloc>()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D0019), // Very Dark Pink (Top)
              Color(0xFF101010), // Black (Mid)
              Color(0xFF0D1C1B), // Very Dark Cyan (Bottom)
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state is LibraryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LibraryLoaded) {
                  if (state.songs.isEmpty) {
                     return const Center(child: Text('No songs found'));
                  }
                  return BlocBuilder<PlayerBloc, PlayerState>(
                    buildWhen: (previous, current) => previous.currentSong != current.currentSong,
                    builder: (context, playerState) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(), // iOS-style smooth scrolling
                        cacheExtent: 500, // Pre-load items off-screen
                        itemExtent: 81.0, // Fixed height for performance
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100), // Zero side padding
                        itemCount: state.songs.length,
                        itemBuilder: (context, index) {
                          final song = state.songs[index];
                          final isPlaying = playerState.currentSong?.id == song.id;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
                            child: RepaintBoundary(
                              child: SongTile(
                                song: song,
                                isPlaying: isPlaying,
                                onTap: () {
                                  final currentSongs = state.songs;
                                  context.read<PlayerBloc>().add(PlayerSetQueue(currentSongs, initialIndex: index));
                                },
                                onDelete: () {
                                  _showDeleteConfirmation(context, song);
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => SongOptionsBottomSheet(
                                      song: song,
                                      onDelete: () {
                                        _showDeleteConfirmation(context, song);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  );
                } else if (state is LibraryError) {
                   return Center(child: Text(state.message));
                }
                return const Center(child: Text('Waiting for permissions...'));
              },
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayerWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, dynamic song) async {
    // song is of type Song entity
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Song?"),
          content: Text("Are you sure you want to delete '${song.title}'?\nThis will remove the file from your device."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<LibraryBloc>().add(DeleteSongEvent(song));
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

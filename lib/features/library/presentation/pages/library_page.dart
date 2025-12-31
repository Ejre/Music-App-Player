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
import '../../../../features/player/presentation/bloc/player_state.dart';
import '../widgets/song_tile.dart';
import '../widgets/song_options_bottom_sheet.dart';
import '../../../../features/playlist/presentation/pages/playlist_list_page.dart';
import '../../../../features/settings/presentation/pages/settings_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  
  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.audio,
    ].request();
    
    if (await Permission.manageExternalStorage.status.isDenied) {
        await Permission.manageExternalStorage.request();
    }

    if (statuses[Permission.storage]!.isGranted || 
        statuses[Permission.audio]!.isGranted || 
        await Permission.manageExternalStorage.isGranted) {
       _loadSongs();
    } else {
       debugPrint("Permission denied");
    }
  }

  void _loadSongs() {
    context.read<LibraryBloc>().add(LoadSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('μRhythm'),
          bottom: const TabBar(
            indicatorColor: Color(0xFF39C5BB),
            indicatorWeight: 3,
            labelColor: Color(0xFF39C5BB),
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: "Songs"),
              Tab(text: "Playlists"),
            ],
          ),
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
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
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
              TabBarView(
                children: [
                  // Tab 1: Songs
                  _buildSongsList(),
                  // Tab 2: Playlists
                  const PlaylistListPage(),
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false, 
                  child: const MiniPlayerWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    return BlocBuilder<LibraryBloc, LibraryState>(
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
                physics: const BouncingScrollPhysics(),
                cacheExtent: 500,
                itemExtent: 81.0, 
                // Add padding for miniplayer + safe area
                padding: EdgeInsets.fromLTRB(0, 0, 0, 100 + MediaQuery.of(context).padding.bottom),
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
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, dynamic song) async {
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

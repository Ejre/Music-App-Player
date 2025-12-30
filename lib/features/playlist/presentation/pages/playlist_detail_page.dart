import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart' hide PlaylistModel, SongModel;
import '../../../../features/library/domain/entities/song.dart';
import '../../../../features/library/presentation/bloc/library_bloc.dart';
import '../../../../features/library/presentation/bloc/library_state.dart';
import '../../../../features/player/presentation/bloc/player_bloc.dart';
import '../../../../features/player/presentation/bloc/player_event.dart';
import '../../data/models/playlist_model.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../bloc/playlist_state.dart';

class PlaylistDetailPage extends StatelessWidget {
  final String playlistId;
  final String initialName;

  PlaylistDetailPage({
    super.key, 
    required PlaylistModel playlist
  }) : playlistId = playlist.id, initialName = playlist.name;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, playlistState) {
        PlaylistModel? playlist;
        if (playlistState is PlaylistLoaded) {
          try {
            playlist = playlistState.playlists.firstWhere((p) => p.id == playlistId);
          } catch (e) {
            // Playlist deleted
            WidgetsBinding.instance.addPostFrameCallback((_) {
               Navigator.of(context).pop();
            });
            return const SizedBox.shrink();
          }
        }

        if (playlist == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(playlist.name),
            centerTitle: true,
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
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, libraryState) {
                  List<Song> playlistSongs = [];
                  if (libraryState is LibraryLoaded) {
                    // Filter songs that are in the playlist
                    // optimize: make a map if large, but for now list contains is fine for < 1000 songs
                    playlistSongs = libraryState.songs.where((song) => playlist!.songIds.contains(song.id)).toList();
                  }

                  if (playlistSongs.isEmpty) {
                    return Center(
                      child: Text(
                        "No songs in this playlist",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: playlistSongs.length,
                    itemBuilder: (context, index) {
                      final song = playlistSongs[index];
                      return ListTile(
                        leading: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.music_note, color: Colors.white54),
                          ),
                        ),
                        title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(song.artist ?? "Unknown", maxLines: 1, 
                            style: const TextStyle(color: Colors.white54)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                          onPressed: () {
                             context.read<PlaylistBloc>().add(RemoveSongFromPlaylistEvent(playlist!.id, song.id));
                          },
                        ),
                        onTap: () {
                           // Play this playlist
                           context.read<PlayerBloc>().add(PlayerSetQueue(playlistSongs, initialIndex: index));
                        },
                      );
                    },
                  );
                },
              ),
          ),
        );
      },
    );
  }
}

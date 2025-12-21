import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart' as bloc_state; // Alias for PlayerStatus
import '../pages/player_page.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
      buildWhen: (previous, current) => previous.currentSong != current.currentSong,
      builder: (context, state) {
        final song = state.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FullPlayerPage()),
            );
          },
          child: Container(
            height: 70, // Height of the mini player
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Artwork - Only rebuilds when song changes
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: QueryArtworkWidget(
                    key: ValueKey(song.id),
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: 50,
                    artworkWidth: 50,
                    size: 500, // HQ Thumbnail
                    quality: 100,
                    keepOldArtwork: true,
                    artworkBorder: BorderRadius.circular(8),
                    nullArtworkWidget: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
                ),
                // Title & Artist
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Controls - Rebuilds locally on status change
                BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                  buildWhen: (previous, current) => previous.status != current.status,
                  builder: (context, state) {
                    return IconButton(
                      icon: Icon(
                        state.status == bloc_state.PlayerStatus.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 32,
                      ),
                      onPressed: () {
                        if (state.status == bloc_state.PlayerStatus.playing) {
                          context.read<PlayerBloc>().add(PlayerPause());
                        } else {
                          context.read<PlayerBloc>().add(PlayerResume());
                        }
                      },
                    );
                  }
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

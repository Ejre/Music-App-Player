import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';

import 'package:just_audio/just_audio.dart' as ja; 
import '../../../../core/services/service_locator.dart';
import '../../data/services/audio_player_service.dart';
import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart' as bloc_state;
import '../widgets/lyrics_view.dart';
import '../widgets/player_tabs_view.dart';
import '../widgets/scrolling_text.dart';

class FullPlayerPage extends StatefulWidget {
  const FullPlayerPage({super.key});

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage> {
  final AudioPlayerService _playerService = getIt<AudioPlayerService>();
  double? _dragValue;
  bool _showLyrics = false;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "NOW PLAYING",
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white60,
            letterSpacing: 2,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
           IconButton(
             icon: const Icon(Icons.more_vert, color: Colors.white), 
             onPressed: () {
               showModalBottomSheet(
                 context: context,
                 backgroundColor: const Color(0xFF1B0526),
                 shape: const RoundedRectangleBorder(
                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                 ),
                 builder: (context) {
                   return SafeArea(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         ListTile(
                           leading: const Icon(Icons.playlist_add, color: Colors.white),
                           title: const Text('Add to Playlist', style: TextStyle(color: Colors.white)),
                           onTap: () {
                             Navigator.pop(context);
                             // TODO: Implement Add to Playlist
                           },
                         ),
                         ListTile(
                           leading: const Icon(Icons.timer, color: Colors.white),
                           title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
                           onTap: () {
                             Navigator.pop(context);
                             // TODO: Implement Sleep Timer
                           },
                         ),
                         const Divider(color: Colors.white24),
                         ListTile(
                           leading: const Icon(Icons.close, color: Colors.white),
                           title: const Text('Close Player', style: TextStyle(color: Colors.white)),
                           onTap: () {
                             Navigator.pop(context); // Close sheet
                             Navigator.pop(context); // Close player
                           },
                         ),
                       ],
                     ),
                   );
                 },
               );
             }
           ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1C1B), // Very Dark Cyan
              Color(0xFF101010), // Black
              Color(0xFF2D0019), // Very Dark Pink
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
            child: Column(
              children: [
                const Spacer(),
                
                // Artwork / Lyrics Switcher
                Stack(
                  children: [
                    BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                      buildWhen: (previous, current) => previous.currentSong != current.currentSong,
                      builder: (context, state) {
                        final song = state.currentSong;
                        return Visibility(
                          visible: !_showLyrics,
                          maintainState: true, 
                          child: Hero(
                            tag: 'player_artwork',
                            child: Container(
                              height: 320,
                              width: 320,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF39C5BB).withOpacity(0.3), // Cyan glow
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: song == null
                                    ? Container(color: Colors.white10, child: const Icon(Icons.music_note, size: 100, color: Colors.white24))
                                    : QueryArtworkWidget(
                                        id: song.id,
                                        type: ArtworkType.AUDIO,
                                        artworkHeight: 320,
                                        artworkWidth: 320,
                                        artworkFit: BoxFit.cover,
                                        size: 1000, // HD Quality
                                        quality: 100,
                                        keepOldArtwork: true, // Prevents flickering
                                        nullArtworkWidget: Container(
                                          color: Colors.white10,
                                          child: const Icon(Icons.music_note, size: 100, color: Colors.white24),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Lyrics View (Now Tabs View)
                    if (_showLyrics)
                      BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                         buildWhen: (previous, current) => 
                            previous.lyrics != current.lyrics || 
                            previous.currentLyricLine != current.currentLyricLine ||
                            previous.queue != current.queue ||
                            previous.currentIndex != current.currentIndex,
                         builder: (context, state) {
                           return Container(
                              height: MediaQuery.of(context).size.height * 0.5, // Expanded height for tabs
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF2D0019).withOpacity(0.95), // Dark Pinkish BG
                                    Colors.black.withOpacity(0.95),
                                  ],
                                ),
                              ),
                              child: PlayerTabsView(
                                queue: state.queue,
                                currentIndex: state.currentIndex,
                                lyrics: state.lyrics ?? [],
                                currentLyricLine: state.currentLyricLine,
                                onSongTap: (song) {
                                  context.read<PlayerBloc>().add(PlayerPlaySong(song));
                                },
                              ),
                           );
                         }
                      ),
                  ],
                ),
                
                const Spacer(),
                
                // Song Info & Favorite - Rebuilds on song change
                BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                  buildWhen: (previous, current) => previous.currentSong != current.currentSong,
                  builder: (context, state) {
                    final song = state.currentSong;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           // Lyrics Toggle
                           IconButton(
                             icon: Icon(Icons.lyrics_rounded, 
                               color: _showLyrics ? const Color(0xFF39C5BB) : Colors.white54
                             ),
                             onPressed: () {
                               setState(() {
                                 _showLyrics = !_showLyrics;
                               });
                             }, 
                           ),
                           
                           Expanded(
                             child: Column(
                               children: [
                                 SizedBox(
                                   height: 40, // Constrain height for scrolling text
                                   child: Center(
                                     child: ScrollingText(
                                       text: song?.title ?? "No Song",
                                       style: theme.textTheme.headlineSmall?.copyWith(
                                         color: Colors.white,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 SizedBox(
                                   height: 30, // Constrain height for secondary text
                                   child: Center(
                                     child: ScrollingText(
                                       text: song?.artist ?? "Unknown Artist",
                                       style: theme.textTheme.titleMedium?.copyWith(
                                         color: const Color(0xFF39C5BB), // Cyan Artist
                                       ),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),

                           // Favorite Button (RESTORED)
                           BlocBuilder<FavoriteBloc, FavoriteState>(
                             builder: (context, favState) {
                               bool isFavorite = false;
                               if (favState is FavoriteLoaded && song != null) {
                                  isFavorite = favState.favoriteIds.contains(song.id);
                               }
                               
                               return IconButton(
                                 icon: Icon(
                                   isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                                   color: isFavorite ? const Color(0xFFE4007F) : Colors.white54, // Pink heart
                                   size: 28,
                                 ),
                                 onPressed: () {
                                   if (song != null) {
                                     context.read<FavoriteBloc>().add(ToggleFavorite(song));
                                   }
                                 },
                               );
                             },
                           ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),

                // Seek Bar (StreamBuilder handles its own rebuilding)
                BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                  buildWhen: (previous, current) => previous.duration != current.duration,
                  builder: (context, state) {
                     // We just need the duration from state, position comes from stream
                     return StreamBuilder<Duration>(
                      stream: _playerService.positionStream,
                      builder: (context, snapshot) {
                        // If we are dragging, use local value. Else use stream value.
                        final durationMs = state.duration.inMilliseconds.toDouble();
                        final positionMs = snapshot.data?.inMilliseconds.toDouble() ?? 0.0;
                        final max = durationMs > 0 ? durationMs : 1.0;
                        final value = _dragValue ?? positionMs.clamp(0.0, max);
                        
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: const Color(0xFF39C5BB), // Cyan Track
                                inactiveTrackColor: Colors.white12,
                                thumbColor: Colors.white,
                                overlayColor: const Color(0xFF39C5BB).withOpacity(0.2),
                              ),
                              child: Slider(
                                min: 0.0,
                                max: max,
                                value: value,
                                onChanged: (newValue) {
                                  setState(() {
                                    _dragValue = newValue;
                                  });
                                },
                                onChangeEnd: (newValue) {
                                  _playerService.seek(Duration(milliseconds: newValue.round()));
                                  _dragValue = null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(Duration(milliseconds: value.round())), 
                                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  Text(_formatDuration(state.duration), 
                                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                ),

                const SizedBox(height: 24),

                // Controls - Rebuilds on status/shuffle/loop
                BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                  buildWhen: (previous, current) => 
                     previous.status != current.status || 
                     previous.isShuffleMode != current.isShuffleMode ||
                     previous.loopMode != current.loopMode,
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Shuffle
                        IconButton(
                          icon: Icon(Icons.shuffle, 
                            color: state.isShuffleMode ? const Color(0xFF39C5BB) : Colors.white54, 
                            size: 28),
                          onPressed: () => context.read<PlayerBloc>().add(PlayerShuffle()),
                        ),
                        
                        // Previous
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 42, color: Colors.white),
                          onPressed: () => context.read<PlayerBloc>().add(PlayerPrevious()),
                        ),
                        
                        // Play/Pause - Miku Gradient
                        GestureDetector(
                          onTap: () {
                            if (state.status == bloc_state.PlayerStatus.playing) {
                               context.read<PlayerBloc>().add(PlayerPause());
                             } else {
                               context.read<PlayerBloc>().add(PlayerResume());
                             }
                          },
                          child: Container(
                            height: 75,
                            width: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF39C5BB), Color(0xFFE4007F)], // Cyan to Pink
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF39C5BB).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              state.status == bloc_state.PlayerStatus.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Next
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 42, color: Colors.white),
                          onPressed: () => context.read<PlayerBloc>().add(PlayerNext()),
                        ),
                        
                        // Repeat
                        IconButton(
                          icon: Icon(
                             state.loopMode == bloc_state.LoopMode.one 
                               ? Icons.repeat_one_rounded
                               : Icons.repeat_rounded, 
                             color: state.loopMode != bloc_state.LoopMode.off ? Colors.purpleAccent : Colors.white54,
                             size: 28,
                          ),
                          onPressed: () => context.read<PlayerBloc>().add(PlayerRepeat()),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

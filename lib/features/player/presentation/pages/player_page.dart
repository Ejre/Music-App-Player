import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../library/domain/entities/song.dart';

import 'package:just_audio/just_audio.dart' as ja; 
import '../../../../core/services/service_locator.dart';
import '../../data/services/audio_player_service.dart';
import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart' as bloc_state;
import '../widgets/lyrics_view.dart';
import '../widgets/player_tabs_view.dart';
import '../widgets/scrolling_text.dart';
import '../../../library/presentation/widgets/song_options_bottom_sheet.dart';

class FullPlayerPage extends StatefulWidget {
  const FullPlayerPage({super.key});

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage> {
  final AudioPlayerService _playerService = getIt<AudioPlayerService>();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double? _dragValue;
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  void _toggleSheet() {
      // Always expand when tab header is tapped
       _sheetController.animateTo(
         0.9, 
         duration: const Duration(milliseconds: 300), 
         curve: Curves.easeInOut
       );
  }

  void _onHeaderDragUpdate(DragUpdateDetails details) {
    // Calculate new size: current size - (delta / total height)
    // Delta is positive when dragging DOWN (dy > 0), size should decrease.
    // Delta is negative when dragging UP (dy < 0), size should increase.
    // So: newSize = size - (dy / height)
    double newSize = _sheetController.size - (details.primaryDelta! / MediaQuery.of(context).size.height);
    
    // Clamp to min/max
    if (newSize < 0.12) newSize = 0.12;
    if (newSize > 0.9) newSize = 0.9;
    
    _sheetController.jumpTo(newSize);
  }

  void _onHeaderDragEnd(DragEndDetails details) {
    if (!_sheetController.isAttached) return; // Safety check

    double targetSize;
    double velocity = details.primaryVelocity ?? 0;

    // 1. Velocity Check (Fling)
    if (velocity < -500) { // Fast Drag UP
       targetSize = 0.9;
    } else if (velocity > 500) { // Fast Drag DOWN
       targetSize = 0.12;
    } 
    // 2. Position Check (Slow Drag)
    else {
      if (_sheetController.size > 0.5) {
        targetSize = 0.9;
      } else {
        targetSize = 0.12;
      }
    }
    
    _sheetController.animateTo(
      targetSize, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOutCubic
    );
  }


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
           BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
             builder: (context, state) {
               return IconButton(
                 icon: const Icon(Icons.more_vert, color: Colors.white, size: 28), 
                 onPressed: () {
                   final song = state.currentSong;
                   if (song != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SongOptionsBottomSheet(
                          song: song,
                          onDelete: () {
                             Navigator.pop(context);
                          },
                        ),
                      );
                   }
                 }
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
              Color(0xFF0D1C1B), 
              Color(0xFF101010), 
              Color(0xFF2D0019), 
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Layer 1: Main Player UI - Same as before
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 140), 
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                           // Artwork - Expanded to ensure visibility
                           Expanded(
                             flex: 4, 
                             child: Center(
                               child: BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                                  buildWhen: (previous, current) => previous.currentSong != current.currentSong,
                                  builder: (context, state) {
                                    final song = state.currentSong;
                                    return Hero(
                                      tag: 'player_artwork',
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: constraints.maxHeight * 0.45, // Keep responsive constraint
                                          maxWidth: constraints.maxHeight * 0.45,
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF39C5BB).withOpacity(0.3), 
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 15),
                                                  spreadRadius: -5,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: song == null
                                                  ? Container(color: Colors.white10, child: const Icon(Icons.music_note, size: 80, color: Colors.white24))
                                                  : QueryArtworkWidget(
                                                      id: song.id,
                                                      type: ArtworkType.AUDIO,
                                                      artworkFit: BoxFit.cover,
                                                      size: 1000, 
                                                      quality: 100,
                                                      keepOldArtwork: true,
                                                      nullArtworkWidget: Container(
                                                        color: Colors.white10,
                                                        child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                               ),
                             ),
                           ),
    
                           // Song Info
                            BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                              buildWhen: (previous, current) => previous.currentSong != current.currentSong,
                              builder: (context, state) {
                                final song = state.currentSong;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0), 
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                       Expanded(
                                         child: Column(
                                           mainAxisSize: MainAxisSize.min, 
                                           crossAxisAlignment: CrossAxisAlignment.start, 
                                           children: [
                                             SizedBox(
                                               height: 36, 
                                               child: Align( 
                                                 alignment: Alignment.centerLeft,
                                                 child: ScrollingText(
                                                   text: song?.title ?? "No Song",
                                                   style: theme.textTheme.headlineSmall?.copyWith(
                                                     color: Colors.white,
                                                     fontWeight: FontWeight.bold,
                                                     fontSize: 22, 
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             Text( 
                                               song?.artist ?? "Unknown Artist",
                                               style: theme.textTheme.titleMedium?.copyWith(
                                                 color: const Color(0xFF39C5BB), 
                                                 fontSize: 16,
                                               ),
                                               maxLines: 1,
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                             if (song != null) ...[
                                               const SizedBox(height: 4),
                                               _buildAudioQualityBadge(song),
                                             ],
                                           ],
                                         ),
                                       ),
                                       BlocBuilder<FavoriteBloc, FavoriteState>(
                                         builder: (context, favState) {
                                           bool isFavorite = false;
                                           if (favState is FavoriteLoaded && song != null) {
                                              isFavorite = favState.favoriteIds.contains(song.id);
                                           }
                                           return IconButton(
                                             icon: Icon(
                                               isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                                               color: isFavorite ? const Color(0xFF39C5BB) : Colors.white54, 
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
                           // Slider
                           BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                              buildWhen: (previous, current) => previous.duration != current.duration,
                              builder: (context, state) {
                                 return StreamBuilder<Duration>(
                                  stream: _playerService.positionStream,
                                  builder: (context, snapshot) {
                                    final durationMs = state.duration.inMilliseconds.toDouble();
                                    final positionMs = snapshot.data?.inMilliseconds.toDouble() ?? 0.0;
                                    final max = durationMs > 0 ? durationMs : 1.0;
                                    final value = _dragValue ?? positionMs.clamp(0.0, max);
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackHeight: 4,
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                            activeTrackColor: const Color(0xFF39C5BB),
                                            inactiveTrackColor: Colors.white12,
                                            thumbColor: const Color(0xFF39C5BB),
                                            overlayColor: const Color(0xFF39C5BB).withOpacity(0.2),
                                            trackShape: const RoundedRectSliderTrackShape(),
                                          ),
                                          child: Slider(
                                            min: 0.0,
                                            max: max,
                                            value: value,
                                            onChanged: (newValue) => setState(() => _dragValue = newValue),
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
                                                style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                              Text(_formatDuration(state.duration), 
                                                style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            ),
                            // Controls
                            BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                              buildWhen: (previous, current) => 
                                 previous.status != current.status || 
                                 previous.isShuffleMode != current.isShuffleMode ||
                                 previous.loopMode != current.loopMode,
                              builder: (context, state) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.shuffle, color: state.isShuffleMode ? const Color(0xFF39C5BB) : Colors.white54, size: 28),
                                      onPressed: () => context.read<PlayerBloc>().add(PlayerShuffle()),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.skip_previous_rounded, size: 48, color: Colors.white), 
                                      onPressed: () => context.read<PlayerBloc>().add(PlayerPrevious()),
                                    ),
                                    GestureDetector(
                                      onTap: () => state.status == bloc_state.PlayerStatus.playing 
                                         ? context.read<PlayerBloc>().add(PlayerPause())
                                         : context.read<PlayerBloc>().add(PlayerResume()),
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF39C5BB), 
                                          boxShadow: [
                                            BoxShadow(color: const Color(0xFF39C5BB).withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8)),
                                          ],
                                        ),
                                        child: Icon(
                                          state.status == bloc_state.PlayerStatus.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          size: 36,
                                          color: Colors.black, 
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.skip_next_rounded, size: 48, color: Colors.white),
                                      onPressed: () => context.read<PlayerBloc>().add(PlayerNext()),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                         state.loopMode == bloc_state.LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded, 
                                         color: state.loopMode != bloc_state.LoopMode.off ? const Color(0xFF39C5BB) : Colors.white54,
                                         size: 28,
                                      ),
                                      onPressed: () => context.read<PlayerBloc>().add(PlayerRepeat()),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24), // Extra bottom padding for safety
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
            
            // Layer 2: Sliding Panel (Glassmorphism & Interaction)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.12, 
              minChildSize: 0.12,
              maxChildSize: 0.9,
              snap: true, // Snap to min or max
              snapSizes: const [0.12, 0.9], // Explicit snap points to avoid partial states
              builder: (context, scrollController) {
                // Glassmorphism Container
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212).withOpacity(0.85), // Semi-transparent Dark
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5)),
                      ],
                    ),
                    child: BackdropFilter(
                      filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur Effect
                      child: BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
                          builder: (context, state) {
                               return PlayerTabsView(
                                    queue: state.queue,
                                    currentIndex: state.currentIndex,
                                    lyrics: state.lyrics ?? [],
                                    currentLyricLine: state.currentLyricLine,
                                    onSongTap: (song) {
                                      context.read<PlayerBloc>().add(PlayerPlaySong(song));
                                    },
                                    initialIndex: _selectedTabIndex,
                                    onTabChanged: (index) {
                                       _selectedTabIndex = index;
                                    },
                                    // Only attach scroll controller if expanded enough to scroll
                                    // But typically DraggableScrollableSheet needs it attached to drive the resize.
                                    // So we just pass it. The view handles attachment based on active tab.
                                    scrollController: scrollController,
                                    onHeaderTap: _toggleSheet, 
                                    onHeaderDragUpdate: _onHeaderDragUpdate, 
                                    onHeaderDragEnd: _onHeaderDragEnd,
                               );
                          },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAudioQualityBadge(Song song) {
    // Calculate Bitrate
    String bitrate = "";
    bool isHiRes = false;
    
    // Check if we have size and duration
    if (song.size != null && song.duration != null && song.duration! > 0) {
      // kbps = (size_bytes * 8) / (duration_seconds * 1000)
      // duration is in ms
      final kbps = (song.size! * 8) / song.duration!;
      bitrate = "${kbps.round()} kbps";
      
      // Determine Hi-Res based on bitrate or extension (if available)
      // FLAC usually > 700kbps, High quality MP3 is 320kbps.
      // Let's set Hi-Res threshold > 500 kbps or explicit extension check.
      // Note: extension check depends on implementation details of 'fileExtension' field.
      // Assuming fileExtension contains typical strings like "flac", "wav".
      
      final ext = song.fileExtension?.toLowerCase() ?? "";
      if (kbps > 500 || ext.contains("flac") || ext.contains("wav")) {
         isHiRes = true;
      }
    } else {
       // Fallback if data missing, just try extension
       final ext = song.fileExtension?.toLowerCase() ?? "";
       if (ext.contains("flac") || ext.contains("wav")) {
         isHiRes = true;
         bitrate = "Lossless";
       }
    }

    if (!isHiRes && bitrate.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHiRes ? const Color(0xFFD4AF37) : Colors.white12, // Gold for Hi-Res
        borderRadius: BorderRadius.circular(4),
        border: isHiRes ? Border.all(color: const Color(0xFFFFD700), width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHiRes) ...[
             const Icon(Icons.high_quality_rounded, size: 12, color: Colors.black),
             const SizedBox(width: 4),
             const Text("Hi-Res", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
             const SizedBox(width: 6),
             Container(width: 1, height: 10, color: Colors.black54),
             const SizedBox(width: 6),
          ],
          Text(
            bitrate.isNotEmpty ? bitrate : "MP3",
            style: TextStyle(
              color: isHiRes ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

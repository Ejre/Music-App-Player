import 'package:flutter/material.dart';
import '../../domain/entities/lyric_line.dart';
import '../../../../features/library/domain/entities/song.dart';
import '../../../../features/library/domain/entities/song.dart';
import 'lyrics_view.dart';
import 'mini_visualizer.dart';

class PlayerTabsView extends StatefulWidget {
  final List<Song> queue;
  final int currentIndex;
  final List<LyricLine> lyrics;
  final LyricLine? currentLyricLine;
  final Function(Song) onSongTap;
  final ScrollController? scrollController;
  final VoidCallback? onHeaderTap;
  final Function(DragUpdateDetails)? onHeaderDragUpdate; 
  final Function(DragEndDetails)? onHeaderDragEnd;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;

  const PlayerTabsView({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.lyrics,
    this.currentLyricLine,
    required this.onSongTap,
    this.scrollController,
    this.onHeaderTap,
    this.onHeaderDragUpdate,
    this.onHeaderDragEnd,
    this.initialIndex = 0,
    this.onTabChanged,
  });

  @override
  State<PlayerTabsView> createState() => _PlayerTabsViewState();
}

class _PlayerTabsViewState extends State<PlayerTabsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeIndex = 0;
  bool _hasScrolledQueue = false;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // Only update state when settled (swiping)
    // If tapped, indexIsChanging is true, but we handle that in onTap manually for speed
    if (!_tabController.indexIsChanging && _tabController.index != _activeIndex) {
       setState(() {
         _activeIndex = _tabController.index;
       });
       widget.onTabChanged?.call(_activeIndex);
    }
  }

  void _scrollToCurrentSong() {
    if (widget.scrollController == null || !widget.scrollController!.hasClients) return;
    if (_activeIndex != 0) return; // Only scroll if Up Next is active

    // Calculate offset: index * itemExtent
    // itemExtent is 72.0 as defined in ListView
    final offset = widget.currentIndex * 72.0;
    
    // Check if offset is valid (simple check)
    // Actually we should center it if possible, but jumping to top is fine for now
    // To center: offset - (screenHeight / 2) + (itemHeight / 2)
    // For now let's just ensure it's visible.
    
    // We try to center it:
    final position = widget.scrollController!.position;
    final viewportHeight = position.viewportDimension;
    final centeredOffset = offset - (viewportHeight / 2) + 36.0;

    // Clamp offset
    final maxScroll = position.maxScrollExtent;
    final targetOffset = centeredOffset.clamp(0.0, maxScroll);

    widget.scrollController!.animateTo(
      targetOffset, 
      duration: const Duration(milliseconds: 500), 
      curve: Curves.easeInOut
    );
  }

  @override
  void didUpdateWidget(PlayerTabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
       _hasScrolledQueue = false; // Reset on song change
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Draggable Header (Manual Drag + Tap)
        GestureDetector(
          onTap: widget.onHeaderTap,
          onVerticalDragUpdate: widget.onHeaderDragUpdate, 
          onVerticalDragEnd: widget.onHeaderDragEnd,
          child: Container(
            color: Colors.transparent, // Hit test
            padding: const EdgeInsets.only(top: 12, bottom: 0),
            width: double.infinity,
            child: Column(
              children: [
                 const SizedBox(height: 8), 
                 TabBar(
                  controller: _tabController,
                  onTap: (index) {
                    setState(() {
                      _activeIndex = index;
                    });
                    // Small delay to ensure the controller is attached to the new view
                    // before we tell the sheet to animate/expand.
                    Future.delayed(const Duration(milliseconds: 80), () {
                       widget.onHeaderTap?.call();
                    });
                  },
                  indicatorColor: const Color(0xFF39C5BB), 
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  tabs: const [
                    Tab(text: "UP NEXT"),
                    Tab(text: "LYRICS"),
                  ],
                ),
                const Divider(height: 1, color: Colors.white10),
              ],
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            color: Colors.transparent, 
            child: TabBarView(
              controller: _tabController,
              children: [
                // Up Next (Queue)
                _buildQueueList(_activeIndex == 0 ? widget.scrollController : null),
                
                // Lyrics
                LyricsView(
                  lyrics: widget.lyrics,
                  currentLine: widget.currentLyricLine,
                  scrollController: _activeIndex == 1 ? widget.scrollController : null, 
                  onTap: widget.onHeaderTap, 
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueueList(ScrollController? controller) {
    if (widget.queue.isEmpty) {
      return const Center(child: Text("Queue is empty", style: TextStyle(color: Colors.white54)));
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fix "Peeking": If collapsed, show empty list but keep Controller attached!
        // We use a single empty placeholder so the user can still drag the sheet.
        final isCollapsed = constraints.maxHeight < 100;
        
        // Auto-scroll Logic
        if (isCollapsed) {
           _hasScrolledQueue = false; 
        } else if (_activeIndex == 0 && !_hasScrolledQueue) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
               _scrollToCurrentSong();
               _hasScrolledQueue = true;
           });
        }
        // Also reset if we are not active (handled by ensuring _activeIndex check above)
        if (_activeIndex != 0) _hasScrolledQueue = false;

        return ListView.builder(
          controller: controller, // Always attach controller
          physics: const AlwaysScrollableScrollPhysics(),
          itemExtent: 72.0, // Fixed height for accurate scrolling
          padding: isCollapsed 
              ? EdgeInsets.zero 
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: isCollapsed ? 1 : widget.queue.length,
          itemBuilder: (context, index) {
            if (isCollapsed) {
               return Container(height: 200, color: Colors.transparent); // Invisible handle
            }
            
            final song = widget.queue[index];
            final isPlaying = index == widget.currentIndex;
            
            return ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: isPlaying 
                     ? MiniVisualizer(isPlaying: true, color: const Color(0xFF39C5BB))
                     : Text("${index + 1}", style: const TextStyle(color: Colors.white54)),
                ),
              ),
              title: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPlaying ? Colors.white : Colors.white70,
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                 song.artist,
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
                 style: const TextStyle(color: Colors.white38),
              ),
              onTap: () => widget.onSongTap(song),
            );
          },
        );
      }
    );
  }
}

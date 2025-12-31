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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.animation!.value == _tabController.index) {
       setState(() {}); 
       widget.onTabChanged?.call(_tabController.index);
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
                  onTap: (_) => widget.onHeaderTap?.call(),
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
                // Up Next (Queue) - Only attach controller if index is 0
                _buildQueueList(_tabController.index == 0 ? widget.scrollController : null),
                
                // Lyrics - Only attach controller if index is 1
                LyricsView(
                  lyrics: widget.lyrics,
                  currentLine: widget.currentLyricLine,
                  scrollController: _tabController.index == 1 ? widget.scrollController : null, 
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
    
    return ListView.builder(
      controller: controller, // Use conditionally passed controller
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.queue.length,
      itemBuilder: (context, index) {
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
}

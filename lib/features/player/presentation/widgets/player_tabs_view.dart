import 'package:flutter/material.dart';
import '../../domain/entities/lyric_line.dart';
import '../../../../features/library/domain/entities/song.dart';
import 'lyrics_view.dart';

class PlayerTabsView extends StatelessWidget {
  final List<Song> queue;
  final int currentIndex;
  final List<LyricLine> lyrics;
  final LyricLine? currentLyricLine;
  final Function(Song) onSongTap;

  const PlayerTabsView({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.lyrics,
    this.currentLyricLine,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1, // Default to Lyrics as requested for "Lyrics Mode"
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: "UP NEXT"),
              Tab(text: "LYRICS"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Up Next (Queue)
                _buildQueueList(),
                
                // Lyrics
                LyricsView(
                  lyrics: lyrics,
                  currentLine: currentLyricLine,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList() {
    if (queue.isEmpty) {
      return const Center(child: Text("Queue is empty", style: TextStyle(color: Colors.white54)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: queue.length,
      itemBuilder: (context, index) {
        final song = queue[index];
        final isPlaying = index == currentIndex;
        
        return ListTile(
          leading: isPlaying 
             ? const Icon(Icons.equalizer, color: Color(0xFF39C5BB))
             : Text("${index + 1}", style: const TextStyle(color: Colors.white54)),
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
          onTap: () => onSongTap(song),
        );
      },
    );
  }
}

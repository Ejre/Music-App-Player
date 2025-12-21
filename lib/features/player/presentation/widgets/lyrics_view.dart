import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../domain/entities/lyric_line.dart';

class LyricsView extends StatefulWidget {
  final List<LyricLine> lyrics;
  final LyricLine? currentLine;
  final VoidCallback? onTap;

  const LyricsView({
    super.key,
    required this.lyrics,
    this.currentLine,
    this.onTap,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  
  // To prevent scrolling conflict during manual scroll, we could track state.
  // But for simple sync, we just auto-scroll.

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLine != oldWidget.currentLine && widget.currentLine != null) {
      _scrollToCurrentLine();
    }
  }
  
  void _scrollToCurrentLine() {
    final index = widget.lyrics.indexOf(widget.currentLine!);
    if (index != -1 && _itemScrollController.isAttached) {
       _itemScrollController.scrollTo(
         index: index,
         duration: const Duration(milliseconds: 600), // Slower, smoother scroll
         curve: Curves.easeInOutCubic, // Smoother curve
         alignment: 0.5, // Center the item in the viewport (0.0 is top, 1.0 is bottom)
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyrics.isEmpty) {
      return Center(
        child: Text(
          "No lyrics found",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.transparent, 
        // ShaderMask for fading top/bottom
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent, 
                Colors.black, 
                Colors.black, 
                Colors.transparent
              ],
              stops: [0.0, 0.2, 0.8, 1.0], // Fade active area
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            padding: EdgeInsets.symmetric(
               horizontal: 0, 
               vertical: MediaQuery.of(context).size.height * 0.2
            ), // Large padding for centering first/last items
            itemCount: widget.lyrics.length,
            itemBuilder: (context, index) {
              final line = widget.lyrics[index];
              final isCurrent = line == widget.currentLine;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Initial 8 was too tight
                alignment: Alignment.centerLeft,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: isCurrent 
                    ? const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: 0.5,
                      )
                    : TextStyle(
                        color: Colors.white.withOpacity(0.5), // "Abu-abu" (Gray)
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                  child: Text(
                    line.text,
                    textAlign: TextAlign.left,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

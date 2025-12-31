import 'package:flutter/material.dart';
import '../../domain/entities/lyric_line.dart';

class LyricsView extends StatefulWidget {
  final List<LyricLine> lyrics;
  final LyricLine? currentLine;
  final VoidCallback? onTap;
  final ScrollController? scrollController; // Add controller

  const LyricsView({
    super.key,
    required this.lyrics,
    this.currentLine,
    this.onTap,
    this.scrollController,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final List<GlobalKey> _itemKeys = [];
  bool _hasScrolledToCurrent = false;

  @override
  void initState() {
    super.initState();
    _generateKeys();
  }

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lyrics != oldWidget.lyrics) {
      _generateKeys();
      _hasScrolledToCurrent = false; // Reset on new song
    }
    
    // If line changed, reset and try scroll
    if (widget.currentLine != oldWidget.currentLine) {
      _hasScrolledToCurrent = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLine());
    }
  }

  void _generateKeys() {
    _itemKeys.clear();
    for (var i = 0; i < widget.lyrics.length; i++) {
        _itemKeys.add(GlobalKey());
    }
  }
  
  void _scrollToCurrentLine() {
    if (widget.currentLine == null) return;
    
    final index = widget.lyrics.indexOf(widget.currentLine!);
    if (index != -1 && index < _itemKeys.length) {
       final key = _itemKeys[index];
       final context = key.currentContext;
       if (context != null) {
         Scrollable.ensureVisible(
           context,
           duration: const Duration(milliseconds: 600),
           curve: Curves.easeInOutCubic,
           alignment: 0.5, 
         );
         _hasScrolledToCurrent = true;
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed = constraints.maxHeight < 150;
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Define padding:
        // - Empty: Minimal/Zero padding so we can control centering manually
        // - Has Lyrics: Large vertical padding to allow top/bottom lines to scroll to center
        final scrollPadding = widget.lyrics.isEmpty 
            ? EdgeInsets.zero 
            : EdgeInsets.symmetric(horizontal: 0, vertical: screenHeight * 0.45);

        // Content Logic
        Widget content;
        if (widget.lyrics.isEmpty) {
           // Use a tall container to fill the expanded sheet and center content
           content = Container(
             height: screenHeight * 0.8, // Fill ~80% of screen (sheet is 90%)
             alignment: Alignment.center,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.lyrics_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
                 const SizedBox(height: 16),
                 Text(
                   "No lyrics found",
                   style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w500),
                 ),
               ],
             )
           );
        } else {
           // Lyrics List
           content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(widget.lyrics.length, (index) {
                final line = widget.lyrics[index];
                final isCurrent = line == widget.currentLine;
                final key = _itemKeys.length > index ? _itemKeys[index] : null;
                
                return Container(
                  key: key,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          color: Colors.white.withOpacity(0.5),
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
              }),
            );
        }

        // Auto-Scroll Logic
        if (widget.lyrics.isNotEmpty && !isCollapsed && !_hasScrolledToCurrent && widget.currentLine != null) {
           WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLine());
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            color: Colors.transparent, 
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
                  stops: [0.0, 0.1, 0.9, 1.0], 
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                controller: widget.scrollController, 
                physics: const AlwaysScrollableScrollPhysics(),
                padding: scrollPadding,
                // Even if collapsed, return ScrollView to keep controller attached
                child: isCollapsed 
                  ? Container(height: 100, color: Colors.transparent) 
                  : content,
              ),
            ),
          ),
        );
      },
    );
  }
}

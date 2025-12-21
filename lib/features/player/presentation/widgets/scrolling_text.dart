import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final ScrollController? scrollController;

  const ScrollingText({
    super.key,
    required this.text,
    this.style,
    this.scrollController,
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  
  // To measure text size
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _animationController = AnimationController(vsync: this);
    
    // Start animation loop after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimationLoop());
  }

  @override
  void didUpdateWidget(ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _resetAndRestart();
    }
  }

  void _resetAndRestart() {
    _animationController.stop();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimationLoop());
  }

  Future<void> _startAnimationLoop() async {
    if (!mounted) return;
    
    // 1. Measure content size vs viewport
    // In a ListView/SingleChildScrollView, maxScrollExtent tells us how much overflow there is.
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return; // No need to scroll

    // 2. Pause at start
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 3. Scroll to end
    // Speed: 30 pixels per second roughly
    final durationBytes = (maxScroll * 35).toInt(); 
    final duration = Duration(milliseconds: durationBytes);
    
    if (_scrollController.hasClients) {
       await _scrollController.animateTo(
        maxScroll,
        duration: duration,
        curve: Curves.linear,
      );
    }
    
    if (!mounted) return;

    // 4. Pause at end
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 5. Reset (Jump back or fade back? User asked for "Ganti ronde selanjutnya", usually means reset)
    // We jump back to 0.
    if (_scrollController.hasClients) {
       _scrollController.jumpTo(0);
    }
    
    // Loop
    _startAnimationLoop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(), // User shouldn't scroll manually interfering
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
      ),
    );
  }
}

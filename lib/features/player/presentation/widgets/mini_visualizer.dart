import 'package:flutter/material.dart';

class MiniVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  
  const MiniVisualizer({
    super.key,
    required this.isPlaying,
    this.color = const Color(0xFF39C5BB),
  });

  @override
  State<MiniVisualizer> createState() => _MiniVisualizerState();
}

class _MiniVisualizerState extends State<MiniVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _bars = [0.4, 0.7, 0.3, 0.8]; // Initial random heights

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MiniVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (index) {
            // Pseudo-random animation based on controller value and index
            double value = _controller.value + (index * 0.3);
            if (value > 1.0) value -= 1.0;
            // Map 0-1 to 0.3-1.0 height range
            double height = 4.0 + (value * 12.0); 
            
            return Container(
              width: 3,
              height: widget.isPlaying ? height : 4.0,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class ShimmerSkeleton extends StatefulWidget {
  const ShimmerSkeleton({
    super.key,
    this.height = 140,
    this.borderRadius = 24,
  });

  final double height;
  final double borderRadius;

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
      builder: (_, __) {
        final value = 0.3 + (_controller.value * 0.4);
        return Container(
          height: widget.height,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(value),
                Colors.white.withOpacity(value - 0.1),
                Colors.white.withOpacity(value),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}

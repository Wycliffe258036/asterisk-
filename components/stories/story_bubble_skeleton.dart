import 'package:flutter/material.dart';

class StoryBubbleSkeleton extends StatefulWidget {
  final double size;

  const StoryBubbleSkeleton({
    super.key,
    this.size = 68,
  });

  @override
  State<StoryBubbleSkeleton> createState() =>
      _StoryBubbleSkeletonState();
}

class _StoryBubbleSkeletonState
    extends State<StoryBubbleSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shimmering circular placeholder
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final pos = _controller.value; // 0.0 -> 1.0

              return ShaderMask(
                shaderCallback: (rect) {
                  final width = rect.width;
                  final gradientWidth = width * 0.6;
                  final dx = (pos * (width + gradientWidth)) - gradientWidth;

                  return LinearGradient(
                    colors: [
                      const Color(0xFFDFDFDF),
                      const Color(0xFFEFEFEF),
                      const Color(0xFFDFDFDF),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    transform: _SlidingGradientTransform(slidePercent: dx / width),
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 7),

          // Shimmering name placeholder
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final pos = _controller.value;

              return ShaderMask(
                shaderCallback: (rect) {
                  final width = rect.width;
                  final gradientWidth = width * 0.6;
                  final dx = (pos * (width + gradientWidth)) - gradientWidth;

                  return LinearGradient(
                    colors: [
                      const Color(0xFFDFDFDF),
                      const Color(0xFFEFEFEF),
                      const Color(0xFFDFDFDF),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    transform: _SlidingGradientTransform(slidePercent: dx / width),
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  width: widget.size * 0.65,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
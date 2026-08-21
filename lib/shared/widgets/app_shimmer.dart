import 'package:flutter/material.dart';

/// High-performance animated Shimmer widget for API loading states.
class AppShimmer extends StatefulWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF1E293B).withOpacity(0.6)
        : const Color(0xFFE2E8F0).withOpacity(0.8);
    final highlightColor = isDark
        ? const Color(0xFF38BDF8).withOpacity(0.3)
        : Colors.white.withOpacity(0.9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: _SlidingGradientTransform(slidePercent: _animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2.4 - 1.2), 0, 0);
  }
}

/// Shimmer placeholder container box
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? const Color(0xFF334155).withOpacity(0.5)
        : const Color(0xFFCBD5E1).withOpacity(0.6);
    final borderColor = isDark
        ? const Color(0xFF475569).withOpacity(0.4)
        : Colors.white.withOpacity(0.5);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.0),
      ),
    );
  }
}

/// Skeleton Shimmer Loader for Dashboard (Stats Cards & Questions)
class DashboardShimmerLoader extends StatelessWidget {
  const DashboardShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards row shimmer
          Row(
            children: const [
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16)),
              SizedBox(width: 14),
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 180, height: 22, borderRadius: 8),
          const SizedBox(height: 14),
          // Question cards shimmer list
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ShimmerBox(width: double.infinity, height: 76, borderRadius: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton Shimmer Loader for Viva Question Session
class VivaQuestionShimmerLoader extends StatelessWidget {
  const VivaQuestionShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          ShimmerBox(width: double.infinity, height: 160, borderRadius: 22),
          SizedBox(height: 20),
          ShimmerBox(width: double.infinity, height: 190, borderRadius: 22),
          SizedBox(height: 20),
          ShimmerBox(width: double.infinity, height: 50, borderRadius: 16),
        ],
      ),
    );
  }
}

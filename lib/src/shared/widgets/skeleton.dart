import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({required this.child, super.key});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.42,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 12,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    this.imageSize = 72,
    this.lines = const [0.62, 0.48, 0.78],
    super.key,
  });

  final double imageSize;
  final List<double> lines;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SkeletonBox(width: imageSize, height: imageSize, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < lines.length; i++) ...[
                    FractionallySizedBox(
                      widthFactor: lines[i],
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(
                        width: double.infinity,
                        height: i == 0 ? 18 : 12,
                        radius: 8,
                      ),
                    ),
                    if (i != lines.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

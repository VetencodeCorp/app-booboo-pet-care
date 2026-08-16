import 'package:flutter/material.dart';

class AnimatedEntry extends StatefulWidget {
  const AnimatedEntry({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 18),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : widget.offset / 100,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    required this.onTap,
    this.borderRadius = 16,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: _pressed ? 0.98 : 1,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: widget.child,
      ),
    );
  }
}

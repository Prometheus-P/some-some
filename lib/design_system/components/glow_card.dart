import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Card with animated border beam effect (Magic UI style)
class GlowCard extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool enableGlow;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.enableGlow = true,
  });

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glowColor = widget.glowColor ?? cs.primary;

    if (!widget.enableGlow) {
      return _buildCard(cs);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BorderBeamPainter(
            progress: _controller.value,
            color: glowColor,
            borderRadius: widget.borderRadius,
          ),
          child: _buildCard(cs),
        );
      },
    );
  }

  Widget _buildCard(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(widget.borderRadius - 2),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Custom painter for animated border beam effect
class BorderBeamPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderRadius;

  BorderBeamPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Calculate the beam position along the border
    final pathMetric = _getPathMetric(rrect);
    final beamLength = pathMetric.length * 0.15; // 15% of perimeter
    final beamStart = progress * pathMetric.length;

    // Create gradient shader for the beam
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw the glow
    for (var i = 0; i < 3; i++) {
      paint.color = color.withOpacity(0.3 - (i * 0.1));
      paint.strokeWidth = 2 + (i * 2);
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 + (i * 2));

      final path = pathMetric.extractPath(beamStart, beamStart + beamLength);
      canvas.drawPath(path, paint);
    }

    // Draw the core beam
    paint.color = color;
    paint.strokeWidth = 2;
    paint.maskFilter = null;

    final corePath = pathMetric.extractPath(beamStart, beamStart + beamLength);
    canvas.drawPath(corePath, paint);
  }

  PathMetric _getPathMetric(RRect rrect) {
    final path = Path()..addRRect(rrect);
    return path.computeMetrics().first;
  }

  @override
  bool shouldRepaint(covariant BorderBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Pulse animation wrapper
class PulseWrapper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const PulseWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
        );
  }
}

/// Floating animation wrapper
class FloatWrapper extends StatelessWidget {
  final Widget child;
  final double distance;
  final Duration duration;

  const FloatWrapper({
    super.key,
    required this.child,
    this.distance = 10,
    this.duration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -distance,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}

/// Sparkle effect overlay
class SparkleOverlay extends StatefulWidget {
  final Widget child;
  final int sparkleCount;

  const SparkleOverlay({
    super.key,
    required this.child,
    this.sparkleCount = 20,
  });

  @override
  State<SparkleOverlay> createState() => _SparkleOverlayState();
}

class _SparkleOverlayState extends State<SparkleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Sparkle> _sparkles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _sparkles = List.generate(widget.sparkleCount, (_) => _generateSparkle());
  }

  _Sparkle _generateSparkle() {
    return _Sparkle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      delay: _random.nextDouble(),
      size: 2 + _random.nextDouble() * 3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: SparklePainter(
                  sparkles: _sparkles,
                  progress: _controller.value,
                  color: cs.primary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Sparkle {
  final double x;
  final double y;
  final double delay;
  final double size;

  _Sparkle({
    required this.x,
    required this.y,
    required this.delay,
    required this.size,
  });
}

class SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double progress;
  final Color color;

  SparklePainter({
    required this.sparkles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (final sparkle in sparkles) {
      final phase = (progress + sparkle.delay) % 1.0;
      final opacity = math.sin(phase * math.pi);

      if (opacity > 0) {
        paint.color = color.withOpacity(opacity * 0.8);
        canvas.drawCircle(
          Offset(sparkle.x * size.width, sparkle.y * size.height),
          sparkle.size * opacity,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

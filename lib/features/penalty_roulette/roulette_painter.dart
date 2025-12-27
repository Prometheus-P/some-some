import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'penalty_data.dart';

/// 룰렛 휠 페인터
class RoulettePainter extends CustomPainter {
  final List<PenaltyItem> items;
  final double rotation; // 라디안
  final Color primaryColor;
  final Color secondaryColor;

  RoulettePainter({
    required this.items,
    required this.rotation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    final sweepAngle = 2 * pi / items.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Draw segments
    for (int i = 0; i < items.length; i++) {
      final startAngle = i * sweepAngle - pi / 2;
      _drawSegment(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle,
        items[i],
        i,
      );
    }

    canvas.restore();

    // Draw center circle (on top, doesn't rotate)
    _drawCenterCircle(canvas, center, radius * 0.18);

    // Draw outer glow ring
    _drawOuterRing(canvas, center, radius);
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    PenaltyItem item,
    int index,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Segment background with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = ui.Gradient.sweep(
      center,
      [
        item.color.withValues(alpha: 0.9),
        item.color.withValues(alpha: 0.7),
      ],
      [0.0, 1.0],
      TileMode.clamp,
      startAngle,
      startAngle + sweepAngle,
    );

    // Draw segment
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, startAngle, sweepAngle, false)
      ..close();

    // Solid color instead of gradient for cleaner look
    paint.shader = null;
    paint.color = item.color.withValues(alpha: 0.85);
    canvas.drawPath(path, paint);

    // Segment border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawPath(path, borderPaint);

    // Draw emoji
    final midAngle = startAngle + sweepAngle / 2;
    final emojiRadius = radius * 0.65;
    final emojiX = center.dx + cos(midAngle) * emojiRadius;
    final emojiY = center.dy + sin(midAngle) * emojiRadius;

    final textPainter = TextPainter(
      text: TextSpan(
        text: item.emoji,
        style: const TextStyle(fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(emojiX - textPainter.width / 2, emojiY - textPainter.height / 2),
    );
  }

  void _drawCenterCircle(Canvas canvas, Offset center, double radius) {
    // Outer glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius + 5, glowPaint);

    // Gradient background
    final gradientPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [primaryColor, secondaryColor],
      );
    canvas.drawCircle(center, radius, gradientPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(center - Offset(radius * 0.2, radius * 0.2), radius * 0.3, highlightPaint);

    // Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawOuterRing(Canvas canvas, Offset center, double radius) {
    // Glow effect
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = primaryColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius + 5, glowPaint);

    // Outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = ui.Gradient.sweep(
        center,
        [primaryColor, secondaryColor, primaryColor],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius + 2, ringPaint);
  }

  @override
  bool shouldRepaint(covariant RoulettePainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

/// 룰렛 포인터 (삼각형 화살표) 페인터
class RoulettePointerPainter extends CustomPainter {
  final Color color;
  final Color glowColor;

  RoulettePointerPainter({
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    const pointerHeight = 40.0;
    const pointerWidth = 30.0;

    // Glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final glowPath = Path()
      ..moveTo(center, pointerHeight + 5)
      ..lineTo(center - pointerWidth / 2, 0)
      ..lineTo(center + pointerWidth / 2, 0)
      ..close();
    canvas.drawPath(glowPath, glowPaint);

    // Pointer
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center, pointerHeight)
      ..lineTo(center - pointerWidth / 2, 0)
      ..lineTo(center + pointerWidth / 2, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

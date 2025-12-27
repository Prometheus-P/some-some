import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';

/// Animated gradient background (Magic UI style)
class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? primaryColors;
  final List<Color>? secondaryColors;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.primaryColors,
    this.secondaryColors,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimateGradient(
      primaryBegin: Alignment.topLeft,
      primaryEnd: Alignment.bottomRight,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      primaryColors: primaryColors ??
          [
            cs.surface,
            cs.surface,
            cs.primaryContainer.withOpacity(0.3),
          ],
      secondaryColors: secondaryColors ??
          [
            cs.surface,
            cs.secondaryContainer.withOpacity(0.3),
            cs.surface,
          ],
      duration: const Duration(seconds: 4),
      child: child,
    );
  }
}

/// Floating orb decoration (Magic UI style)
class FloatingOrb extends StatefulWidget {
  final double size;
  final Color color;
  final Offset position;
  final Duration duration;

  const FloatingOrb({
    super.key,
    this.size = 200,
    required this.color,
    required this.position,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(30, 20),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx + _offsetAnimation.value.dx,
          top: widget.position.dy + _offsetAnimation.value.dy,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(0.4),
                  widget.color.withOpacity(0.1),
                  widget.color.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Mesh gradient background with floating orbs
class MeshGradientBackground extends StatelessWidget {
  final Widget child;

  const MeshGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base dark background
        Container(color: cs.surface),
        // Floating orbs
        FloatingOrb(
          color: cs.primary,
          size: 300,
          position: Offset(-50, size.height * 0.1),
          duration: const Duration(seconds: 5),
        ),
        FloatingOrb(
          color: cs.secondary,
          size: 250,
          position: Offset(size.width - 100, size.height * 0.3),
          duration: const Duration(seconds: 6),
        ),
        FloatingOrb(
          color: cs.tertiary,
          size: 200,
          position: Offset(size.width * 0.3, size.height * 0.6),
          duration: const Duration(seconds: 4),
        ),
        // Content
        child,
      ],
    );
  }
}

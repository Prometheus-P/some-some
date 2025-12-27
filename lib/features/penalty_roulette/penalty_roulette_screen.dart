import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/deep_links/deep_link_service.dart';
import '../../core/haptics/haptics.dart';
import '../../core/settings/settings_service.dart';
import '../../core/share/share_card_builder.dart';
import '../../core/share/share_service.dart';
import '../../design_system/tds.dart';
import '../../design_system/components/animated_background.dart';
import '../../design_system/components/glass_button.dart';
import 'penalty_data.dart';
import 'roulette_painter.dart';

/// 복불복 룰렛 화면
class PenaltyRouletteScreen extends StatefulWidget {
  const PenaltyRouletteScreen({super.key});

  @override
  State<PenaltyRouletteScreen> createState() => _PenaltyRouletteScreenState();
}

class _PenaltyRouletteScreenState extends State<PenaltyRouletteScreen>
    with TickerProviderStateMixin {
  // Animation
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  // State
  bool _isSpinning = false;
  PenaltyItem? _selectedPenalty;
  final Random _random = Random();

  // Settings
  final SettingsService _settings = SettingsService();

  // Celebration
  late final ConfettiController _confettiController;

  // Roulette items (shuffled for variety)
  late List<PenaltyItem> _items;

  // Share
  final GlobalKey _resultShareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _items = List.from(defaultPenalties)..shuffle();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedPenalty = null;
    });

    if (_settings.hapticEnabled) Haptics.medium();

    // Calculate random stopping position
    // At least 5 full rotations + random offset
    final baseRotations = 5 + _random.nextInt(3);
    final randomOffset = _random.nextDouble() * 2 * pi;
    final totalRotation = baseRotations * 2 * pi + randomOffset;

    _spinAnimation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.forward(from: 0);
  }

  void _onSpinComplete() {
    // Calculate which segment is at the top (pointer position)
    final normalizedRotation = _spinAnimation.value % (2 * pi);
    final segmentAngle = 2 * pi / _items.length;

    // The pointer is at the top (-pi/2), so we need to find which segment is there
    // Rotation is clockwise, so we subtract from the total
    final pointerAngle = (2 * pi - normalizedRotation + pi / 2) % (2 * pi);
    final selectedIndex = (pointerAngle / segmentAngle).floor() % _items.length;

    setState(() {
      _isSpinning = false;
      _selectedPenalty = _items[selectedIndex];
    });

    if (_settings.hapticEnabled) Haptics.vibrate();
    _confettiController.play();
  }

  void _reset() {
    setState(() {
      _selectedPenalty = null;
      _items.shuffle();
    });
    _spinController.reset();
    if (_settings.hapticEnabled) Haptics.light();
  }

  void _shareResult() {
    if (_selectedPenalty == null) return;

    final penalty = _selectedPenalty!;
    final deepLink = DeepLinkService.createShareUrl(DeepLinkType.penaltyRoulette);

    final shareText = ShareCardUtils.getShareText(
      type: ShareCardType.penaltyRoulette,
      title: penalty.text,
      extraInfo: '강도 ${'🔥' * penalty.intensity}',
    );

    final fullShareText = '$shareText\n$deepLink';
    ShareService.shareWidget(_resultShareKey, text: fullShareText);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('복불복 룰렛', style: titleSmall(cs)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildGlassBackButton(cs),
      ),
      body: MeshGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    _selectedPenalty != null
                        ? '벌칙 당첨!'
                        : '룰렛을 돌려보세요',
                    style: titleMedium(cs),
                  )
                      .animate(
                        key: ValueKey(_selectedPenalty != null),
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    _selectedPenalty != null
                        ? '과연 할 수 있을까?'
                        : '어떤 벌칙이 나올까?',
                    style: bodyText(cs).copyWith(color: cs.onSurfaceVariant),
                  ),

                  const SizedBox(height: 30),

                  // Roulette Wheel
                  Expanded(
                    child: Center(
                      child: _buildRouletteWheel(cs),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Result Card or Spin Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _selectedPenalty != null
                        ? _buildResultCard(cs)
                        : _buildSpinButton(cs),
                  ),

                  const SizedBox(height: 30),
                ],
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [
                    cs.primary,
                    cs.secondary,
                    cs.tertiary,
                    Colors.amber,
                    Colors.white,
                  ],
                  emissionFrequency: 0.05,
                  numberOfParticles: 25,
                  gravity: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouletteWheel(ColorScheme cs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight) * 0.85;

        return SizedBox(
          width: size,
          height: size + 50, // Extra space for pointer
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wheel
              Positioned(
                top: 50,
                child: AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    return SizedBox(
                      width: size,
                      height: size,
                      child: CustomPaint(
                        painter: RoulettePainter(
                          items: _items,
                          rotation: _spinController.isAnimating
                              ? _spinAnimation.value
                              : (_spinController.isCompleted
                                  ? _spinAnimation.value
                                  : 0),
                          primaryColor: cs.primary,
                          secondaryColor: cs.secondary,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Pointer at top
              Positioned(
                top: 15,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CustomPaint(
                    painter: RoulettePointerPainter(
                      color: cs.primary,
                      glowColor: cs.primary,
                    ),
                  ),
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  )
                  .scaleY(
                    begin: 1.0,
                    end: 1.1,
                    duration: 500.ms,
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpinButton(ColorScheme cs) {
    return GlassButton(
      text: _isSpinning ? '돌리는 중...' : '돌리기!',
      icon: _isSpinning ? Icons.hourglass_top : Icons.casino_rounded,
      glowColor: cs.primary,
      onTap: _isSpinning ? () {} : _spin,
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildResultCard(ColorScheme cs) {
    final penalty = _selectedPenalty!;

    return RepaintBoundary(
      key: _resultShareKey,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: penalty.color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              Text(
                penalty.emoji,
                style: const TextStyle(fontSize: 48),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5)),

              const SizedBox(height: 12),

              // Penalty text
              Text(
                penalty.text,
                style: titleMedium(cs).copyWith(
                  color: penalty.color,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .shimmer(
                    delay: 600.ms,
                    duration: 1500.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),

              const SizedBox(height: 8),

              // Intensity indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final isActive = i < penalty.intensity;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      isActive ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isActive ? cs.primary : cs.onSurfaceVariant,
                    ),
                  );
                }),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: '다시 돌리기',
                      icon: Icons.refresh_rounded,
                      glowColor: cs.primary,
                      onTap: _reset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      text: '공유',
                      icon: Icons.share_rounded,
                      glowColor: cs.secondary,
                      onTap: _shareResult,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2)
        .scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildGlassBackButton(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: cs.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

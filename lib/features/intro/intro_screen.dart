import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design_system/tds.dart';
import '../../design_system/components/glass_button.dart';
import '../../design_system/components/animated_background.dart';
import '../../design_system/components/glow_card.dart';
import '../settings/settings_screen.dart';
import '../sticky_fingers/sticky_fingers_screen.dart';
import '../soul_sync/soul_sync_screen.dart';
import '../penalty_roulette/penalty_roulette_screen.dart';
import '../couple_mode/couple_mode_screen.dart';
import '../tutorial/tutorial_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const String _tutorialSeenKey = 'tutorial_seen';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_tutorialSeenKey) ?? false;
    if (!seen && mounted) {
      _showTutorial();
    }
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TutorialScreen(
          onComplete: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_tutorialSeenKey, true);
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
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

    return Scaffold(
      body: MeshGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top action buttons with glass effect
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildGlassIconButton(
                      icon: Icons.favorite_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CoupleModeScreen()),
                        );
                      },
                      tooltip: '우리의 기록',
                    ),
                    const SizedBox(width: 8),
                    _buildGlassIconButton(
                      icon: Icons.help_outline,
                      onTap: _showTutorial,
                      tooltip: '도움말',
                    ),
                    const SizedBox(width: 8),
                    _buildGlassIconButton(
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        );
                      },
                      tooltip: '설정',
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, curve: Curves.easeOut),

                const SizedBox(height: 20),

                // Animated Title with shimmer
                Text(
                  '너랑 나랑\n손끝 시그널',
                  style: titleBig(cs).copyWith(fontSize: 34),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideX(begin: -0.2, curve: Curves.easeOut)
                    .shimmer(
                      delay: 1000.ms,
                      duration: 1800.ms,
                      color: cs.primary.withValues(alpha: 0.3),
                    ),

                const SizedBox(height: 12),

                Text('진지함은 빼고,\n스킨십은 더하고!', style: bodyText(cs))
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideX(begin: -0.2, curve: Curves.easeOut),

                const Spacer(),

                // Animated Graphic Area with glow effect
                Center(
                  child: FloatWrapper(
                    distance: 15,
                    duration: const Duration(seconds: 3),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow rings
                            Transform.translate(
                              offset: Offset(
                                sin(_controller.value * 2 * pi) * 25,
                                0,
                              ),
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      cs.secondary.withValues(alpha: 0.4),
                                      cs.secondary.withValues(alpha: 0.1),
                                      cs.secondary.withValues(alpha: 0.0),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.secondary.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(
                                -sin(_controller.value * 2 * pi) * 25,
                                0,
                              ),
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      cs.primary.withValues(alpha: 0.4),
                                      cs.primary.withValues(alpha: 0.1),
                                      cs.primary.withValues(alpha: 0.0),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Heart emoji with pulse
                            const Text('💕', style: TextStyle(fontSize: 80))
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.1, 1.1),
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.easeInOut,
                                ),
                          ],
                        );
                      },
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 1000.ms, delay: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8)),

                const Spacer(),

                // Game Mode Buttons
                Center(
                  child: Column(
                    children: [
                      // Sticky Fingers Button
                      GlassButton(
                        text: '쫀드기 챌린지',
                        glowColor: cs.primary,
                        icon: Icons.touch_app_rounded,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StickyFingersScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Soul Sync Button
                      GlassButton(
                        text: '이심전심 텔레파시',
                        glowColor: cs.secondary,
                        icon: Icons.favorite_rounded,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SoulSyncScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Penalty Roulette Button
                      GlassButton(
                        text: '복불복 룰렛',
                        glowColor: cs.tertiary,
                        icon: Icons.casino_rounded,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PenaltyRouletteScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Practice Mode Button (smaller, subtle)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const StickyFingersScreen(isPracticeMode: true),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cs.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '혼자 연습해보기',
                                style: bodySmall(cs).copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 800.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOut),

                const SizedBox(height: 20),

                // Tagline with shimmer
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🍻', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '술자리',
                          style: bodySmall(cs),
                        ),
                        const SizedBox(width: 12),
                        const Text('☕', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '카페',
                          style: bodySmall(cs),
                        ),
                        const SizedBox(width: 12),
                        const Text('💕', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '썸 탈때',
                          style: bodySmall(cs),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 1000.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            icon,
            color: cs.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }
}

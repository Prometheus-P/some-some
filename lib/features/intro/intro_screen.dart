import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design_system/tds.dart';
import '../../design_system/components/toss_button.dart';
import '../../design_system/motion/fade_in_up.dart';
import '../settings/settings_screen.dart';
import '../sticky_fingers/sticky_fingers_screen.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _showTutorial,
                    icon: Icon(Icons.help_outline, color: cs.onSurfaceVariant),
                    tooltip: '도움말',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
                    tooltip: '설정',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // M3 Style Header
              FadeInUp(
                delay: 0,
                child: Text(
                  '너랑 나랑\n손끝 시그널',
                  style: titleBig(cs).copyWith(fontSize: 34),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: 200,
                child: Text('진지함은 빼고,\n스킨십은 더하고!', style: bodyText(cs)),
              ),

              const Spacer(),

              // Animated Graphic Area
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(
                            sin(_controller.value * 2 * pi) * 20,
                            0,
                          ),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: cs.secondary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(
                            -sin(_controller.value * 2 * pi) * 20,
                            0,
                          ),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const Text('💕', style: TextStyle(fontSize: 80)),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // M3 Style Button - 쫀드기 챌린지
              FadeInUp(
                delay: 400,
                child: TossButton(
                  text: '쫀드기 챌린지 시작하기',
                  color: cs.secondary,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StickyFingersScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: 600,
                child: Center(
                  child: Text(
                    '술자리 / 카페 / 썸 탈때 추천',
                    style: bodyText(cs).copyWith(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. GAME SCREEN (The Logic)
// -----------------------------------------------------------------------------

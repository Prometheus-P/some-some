import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/haptics/haptics.dart';
import '../../core/settings/settings_service.dart';
import '../../design_system/tds.dart';
import '../../design_system/components/animated_background.dart';

/// 설정 화면 with Magic UI
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('설정', style: titleSmall(cs)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildGlassBackButton(cs),
      ),
      body: MeshGradientBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _settings,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 8),

                  // 난이도 섹션
                  _buildSectionTitle(cs, '난이도', Icons.speed_rounded, 0),
                  const SizedBox(height: 12),
                  ...GameDifficulty.values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final diff = entry.value;
                    return _GlassDifficultyTile(
                      difficulty: diff,
                      isSelected: _settings.difficulty == diff,
                      onTap: () {
                        _settings.setDifficulty(diff);
                        Haptics.light();
                      },
                      delay: 100 + (index * 50),
                    );
                  }),

                  const SizedBox(height: 28),

                  // 사운드 & 햅틱 섹션
                  _buildSectionTitle(cs, '피드백', Icons.vibration_rounded, 200),
                  const SizedBox(height: 12),
                  _GlassSettingCard(
                    delay: 250,
                    child: Column(
                      children: [
                        _GlassSettingSwitch(
                          title: '사운드 효과',
                          subtitle: '게임 시작, 성공, 실패 효과음',
                          icon: Icons.volume_up_rounded,
                          value: _settings.soundEnabled,
                          activeColor: cs.primary,
                          onChanged: (v) {
                            _settings.setSoundEnabled(v);
                            Haptics.light();
                          },
                        ),
                        Divider(
                          color: cs.outline.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        _GlassSettingSwitch(
                          title: '진동 피드백',
                          subtitle: '햅틱 진동 효과',
                          icon: Icons.vibration_rounded,
                          value: _settings.hapticEnabled,
                          activeColor: cs.secondary,
                          onChanged: (v) {
                            _settings.setHapticEnabled(v);
                            if (v) Haptics.medium();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 앱 정보
                  _buildSectionTitle(cs, '정보', Icons.info_outline_rounded, 300),
                  const SizedBox(height: 12),
                  _GlassInfoCard(delay: 350),

                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
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

  Widget _buildSectionTitle(
      ColorScheme cs, String title, IconData icon, int delayMs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: cs.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(title, style: titleSmall(cs)),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delayMs), duration: 400.ms)
        .slideX(begin: -0.1);
  }
}

class _GlassDifficultyTile extends StatelessWidget {
  final GameDifficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  const _GlassDifficultyTile({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          cs.primary.withValues(alpha: 0.3),
                          cs.secondary.withValues(alpha: 0.2),
                        ],
                      )
                    : null,
                color: isSelected ? null : cs.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.5)
                      : cs.outline.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? cs.primary
                          : cs.surface.withValues(alpha: 0.5),
                      border: Border.all(
                        color: isSelected
                            ? cs.primary
                            : cs.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: cs.onPrimary, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          difficulty.label,
                          style: bodyBig(cs).copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          difficulty.description,
                          style: bodySmall(cs).copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${difficulty.duration.toInt()}초',
                        style: bodySmall(cs).copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.1);
  }
}

class _GlassSettingCard extends StatelessWidget {
  final Widget child;
  final int delay;

  const _GlassSettingCard({
    required this.child,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.1);
  }
}

class _GlassSettingSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _GlassSettingSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: 0.2)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? activeColor : cs.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: bodyText(cs)),
                Text(
                  subtitle,
                  style:
                      bodySmall(cs).copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _GlassInfoCard extends StatelessWidget {
  final int delay;

  const _GlassInfoCard({required this.delay});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.tag_rounded,
                label: '버전',
                value: '1.5.0',
                color: cs.primary,
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.person_rounded,
                label: '만든 사람',
                value: 'Prometheus-P',
                color: cs.secondary,
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.alternate_email_rounded,
                label: '인스타그램',
                value: '@somesome.app',
                color: cs.tertiary,
              ),
              const SizedBox(height: 20),
              // Made with love badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.2),
                      cs.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Made with', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    const Text('💕', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    const Text('in Korea', style: TextStyle(fontSize: 12)),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(
                    duration: 2.seconds,
                    color: cs.primary.withValues(alpha: 0.3),
                  ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.1);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Text(label, style: bodyText(cs)),
        const Spacer(),
        Text(
          value,
          style: bodyText(cs).copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

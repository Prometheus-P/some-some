import 'package:flutter/material.dart';

import '../../core/settings/settings_service.dart';
import '../../design_system/tds.dart';

/// 설정 화면
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
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 난이도 섹션
              Text('난이도', style: titleSmall(cs)),
              const SizedBox(height: 12),
              ...GameDifficulty.values.map((diff) => _DifficultyTile(
                    difficulty: diff,
                    isSelected: _settings.difficulty == diff,
                    onTap: () => _settings.setDifficulty(diff),
                  )),

              const SizedBox(height: 32),

              // 사운드 & 햅틱 섹션
              Text('피드백', style: titleSmall(cs)),
              const SizedBox(height: 12),
              _SettingSwitch(
                title: '사운드 효과',
                subtitle: '게임 시작, 성공, 실패 효과음',
                value: _settings.soundEnabled,
                onChanged: _settings.setSoundEnabled,
              ),
              const SizedBox(height: 8),
              _SettingSwitch(
                title: '진동 피드백',
                subtitle: '햅틱 진동 효과',
                value: _settings.hapticEnabled,
                onChanged: _settings.setHapticEnabled,
              ),

              const SizedBox(height: 32),

              // 앱 정보
              Text('정보', style: titleSmall(cs)),
              const SizedBox(height: 12),
              ListTile(
                title: Text('버전', style: bodyText(cs)),
                trailing: Text('1.2.0', style: bodySmall(cs)),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: Text('만든 사람', style: bodyText(cs)),
                trailing: Text('@somesome.app', style: bodySmall(cs)),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final GameDifficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
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
                          color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                        ),
                      ),
                      Text(
                        difficulty.description,
                        style: bodySmall(cs).copyWith(
                          color: isSelected
                              ? cs.onPrimaryContainer.withValues(alpha: 0.7)
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SwitchListTile(
      title: Text(title, style: bodyText(cs)),
      subtitle: Text(subtitle, style: bodySmall(cs)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

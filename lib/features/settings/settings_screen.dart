import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/haptics/haptics.dart';
import '../../core/premium/iap_service.dart';
import '../../core/premium/premium_service.dart';
import '../../core/premium/products.dart';
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
  final PremiumService _premiumService = PremiumService.instance;
  final IAPService _iapService = IAPService.instance;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _premiumService.initialize();
    await _iapService.initialize();
    if (mounted) setState(() {});
  }

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
            listenable: Listenable.merge([_settings, _premiumService]),
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 8),

                  // 프리미엄 섹션
                  _buildSectionTitle(
                      cs, '프리미엄', Icons.workspace_premium_rounded, 0),
                  const SizedBox(height: 12),
                  _GlassPremiumCard(
                    isPremium: _premiumService.isPremium,
                    onUpgrade: _showPremiumDialog,
                    onRestore: _restorePurchases,
                    delay: 50,
                  ),

                  const SizedBox(height: 28),

                  // 난이도 섹션
                  _buildSectionTitle(cs, '난이도', Icons.speed_rounded, 100),
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
                      delay: 150 + (index * 50),
                    );
                  }),

                  const SizedBox(height: 28),

                  // 사운드 & 햅틱 섹션
                  _buildSectionTitle(cs, '피드백', Icons.vibration_rounded, 300),
                  const SizedBox(height: 12),
                  _GlassSettingCard(
                    delay: 350,
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
                  _buildSectionTitle(cs, '정보', Icons.info_outline_rounded, 400),
                  const SizedBox(height: 12),
                  _GlassInfoCard(delay: 450),

                  // 디버그 섹션 (개발 모드에서만)
                  if (kDebugMode) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle(cs, '개발자', Icons.bug_report_rounded, 500),
                    const SizedBox(height: 12),
                    _GlassDebugCard(
                      premiumService: _premiumService,
                      delay: 550,
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        iapService: _iapService,
        premiumService: _premiumService,
      ),
    );
  }

  Future<void> _restorePurchases() async {
    final cs = Theme.of(context).colorScheme;

    await _iapService.restorePurchases();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _iapService.status == IAPStatus.error
                ? _iapService.errorMessage ?? '복원 실패'
                : '구매 복원 완료',
          ),
          backgroundColor:
              _iapService.status == IAPStatus.error ? cs.error : cs.primary,
        ),
      );
    }
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

/// 프리미엄 카드
class _GlassPremiumCard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;
  final VoidCallback onRestore;
  final int delay;

  const _GlassPremiumCard({
    required this.isPremium,
    required this.onUpgrade,
    required this.onRestore,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isPremium
                ? LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.3),
                      cs.secondary.withValues(alpha: 0.2),
                    ],
                  )
                : null,
            color: isPremium ? null : cs.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPremium
                  ? cs.primary.withValues(alpha: 0.5)
                  : cs.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withValues(alpha: 0.3),
                          cs.secondary.withValues(alpha: 0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPremium ? Icons.diamond_rounded : Icons.lock_rounded,
                      color: isPremium ? cs.primary : cs.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? '프리미엄 활성화됨' : '프리미엄 업그레이드',
                          style: bodyBig(cs).copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPremium ? cs.primary : cs.onSurface,
                          ),
                        ),
                        Text(
                          isPremium
                              ? '모든 콘텐츠를 이용할 수 있어요!'
                              : '더 많은 콘텐츠를 즐겨보세요',
                          style: bodySmall(cs).copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PRO',
                        style: bodySmall(cs).copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (!isPremium) ...[
                const SizedBox(height: 16),
                // 혜택 목록
                ...PremiumBenefits.benefits.take(3).map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(benefit.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefit.title,
                              style: bodySmall(cs),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onUpgrade,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.secondary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${ProductPrices.premiumUpgrade} 업그레이드',
                              style: bodyText(cs).copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onRestore,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '복원',
                          style: bodyText(cs).copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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

/// 프리미엄 바텀시트
class _PremiumBottomSheet extends StatelessWidget {
  final IAPService iapService;
  final PremiumService premiumService;

  const _PremiumBottomSheet({
    required this.iapService,
    required this.premiumService,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.2),
                  cs.secondary.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '썸썸 프리미엄',
                        style: titleMedium(cs).copyWith(color: cs.primary),
                      ),
                      Text(
                        '모든 콘텐츠를 영구적으로 이용하세요',
                        style: bodySmall(cs).copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 혜택 목록
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: PremiumBenefits.benefits.map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          benefit.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit.title,
                              style: bodyText(cs).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              benefit.description,
                              style: bodySmall(cs).copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // 구매 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListenableBuilder(
              listenable: iapService,
              builder: (context, _) {
                final isLoading = iapService.status == IAPStatus.purchasing;

                return GestureDetector(
                  onTap: isLoading
                      ? null
                      : () async {
                          await iapService.buyProduct(ProductIds.premiumUpgrade);
                          if (context.mounted &&
                              iapService.status == IAPStatus.success) {
                            Navigator.pop(context);
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          : Text(
                              '${ProductPrices.premiumUpgrade}에 업그레이드',
                              style: titleSmall(cs).copyWith(
                                color: cs.onPrimary,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // 안내 문구
          Text(
            '일회성 결제 · 구독 아님',
            style: bodySmall(cs).copyWith(color: cs.onSurfaceVariant),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

/// 디버그 카드
class _GlassDebugCard extends StatelessWidget {
  final PremiumService premiumService;
  final int delay;

  const _GlassDebugCard({
    required this.premiumService,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bug_report, color: cs.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '개발자 모드',
                    style: bodyText(cs).copyWith(color: cs.error),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DebugButton(
                      label: '프리미엄 토글',
                      onTap: () => premiumService.debugTogglePremium(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DebugButton(
                      label: '구매 초기화',
                      onTap: () => premiumService.debugResetPurchases(),
                    ),
                  ),
                ],
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

class _DebugButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DebugButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: bodySmall(cs).copyWith(color: cs.error),
          ),
        ),
      ),
    );
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
            activeTrackColor: activeColor,
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
                value: '2.0.0',
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Made with', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 4),
                    Text('💕', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text('in Korea', style: TextStyle(fontSize: 12)),
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

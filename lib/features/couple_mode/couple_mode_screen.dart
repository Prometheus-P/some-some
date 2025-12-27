import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/haptics/haptics.dart';
import '../../design_system/tds.dart';
import '../../design_system/components/animated_background.dart';
import '../../design_system/components/glass_button.dart';
import 'badge_data.dart';
import 'couple_service.dart';

/// 커플 모드 메인 화면
class CoupleModeScreen extends StatefulWidget {
  const CoupleModeScreen({super.key});

  @override
  State<CoupleModeScreen> createState() => _CoupleModeScreenState();
}

class _CoupleModeScreenState extends State<CoupleModeScreen> {
  final CoupleService _coupleService = CoupleService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _coupleService.initialize();
    await _coupleService.checkDayBadges();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        body: MeshGradientBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💕', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                CircularProgressIndicator(color: cs.primary),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('우리의 기록', style: titleSmall(cs)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildGlassBackButton(cs),
      ),
      body: MeshGradientBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _coupleService,
            builder: (context, _) {
              if (!_coupleService.hasCouple) {
                return _buildSetupScreen(cs);
              }
              return _buildMainScreen(cs);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSetupScreen(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome illustration
          const Text('💑', style: TextStyle(fontSize: 80))
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 24),

          Text(
            '우리의 이야기를\n시작해볼까요?',
            style: titleBig(cs),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 12),

          Text(
            '첫 손잡기 날짜를 기록하고\n함께한 시간을 추억해요',
            style: bodyText(cs).copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 40),

          GlassButton(
            text: '커플 등록하기',
            icon: Icons.favorite_rounded,
            glowColor: cs.primary,
            onTap: () => _showSetupDialog(cs),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildMainScreen(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // D-Day Card
          _buildDDayCard(cs),

          const SizedBox(height: 24),

          // Stats Card
          _buildStatsCard(cs),

          const SizedBox(height: 24),

          // Badges Section
          _buildBadgesSection(cs),

          const SizedBox(height: 24),

          // Actions
          _buildActionsSection(cs),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDDayCard(ColorScheme cs) {
    final days = _coupleService.daysSinceFirst;
    final firstDate = _coupleService.firstDate!;
    final dateStr =
        '${firstDate.year}.${firstDate.month.toString().padLeft(2, '0')}.${firstDate.day.toString().padLeft(2, '0')}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withValues(alpha: 0.3),
                cs.secondary.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Names
              if (_coupleService.myName != null ||
                  _coupleService.partnerName != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _coupleService.myName ?? '나',
                      style: bodyBig(cs).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('💕', style: TextStyle(fontSize: 20)),
                    ),
                    Text(
                      _coupleService.partnerName ?? '우리 자기',
                      style: bodyBig(cs).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

              if (_coupleService.myName != null ||
                  _coupleService.partnerName != null)
                const SizedBox(height: 16),

              // D-Day number
              Text(
                'D+$days',
                style: titleBig(cs).copyWith(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [cs.primary, cs.secondary],
                    ).createShader(const Rect.fromLTWH(0, 0, 150, 60)),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8))
                  .shimmer(
                    delay: 800.ms,
                    duration: 1500.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),

              const SizedBox(height: 8),

              // Start date
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      '첫 날: $dateStr',
                      style: bodySmall(cs).copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildStatsCard(ColorScheme cs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  cs,
                  icon: Icons.games_rounded,
                  label: '플레이 횟수',
                  value: '${_coupleService.playCount}회',
                  color: cs.secondary,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: cs.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  cs,
                  icon: Icons.emoji_events_rounded,
                  label: '획득 뱃지',
                  value: '${_coupleService.earnedBadges.length}개',
                  color: cs.tertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildStatItem(
    ColorScheme cs, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: titleSmall(cs).copyWith(color: color)),
        Text(
          label,
          style: bodySmall(cs).copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(ColorScheme cs) {
    final earnedBadges = _coupleService.earnedBadges
        .map((id) => getBadgeById(id))
        .whereType<CoupleBadge>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.tertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.workspace_premium_rounded,
                  color: cs.tertiary, size: 18),
            ),
            const SizedBox(width: 12),
            Text('획득한 뱃지', style: titleSmall(cs)),
          ],
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

        const SizedBox(height: 16),

        if (earnedBadges.isEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(
                      '아직 뱃지가 없어요',
                      style: bodyText(cs).copyWith(color: cs.onSurfaceVariant),
                    ),
                    Text(
                      '게임을 플레이하고 뱃지를 모아보세요!',
                      style: bodySmall(cs).copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms)
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: earnedBadges.asMap().entries.map((entry) {
              final index = entry.key;
              final badge = entry.value;
              return _buildBadgeItem(cs, badge, index);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBadgeItem(ColorScheme cs, CoupleBadge badge, int index) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(cs, badge),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: badge.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badge.color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(badge.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  badge.name,
                  style: bodySmall(cs).copyWith(
                    fontWeight: FontWeight.bold,
                    color: badge.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + index * 100), duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildActionsSection(ColorScheme cs) {
    return Column(
      children: [
        // Edit names button
        GestureDetector(
          onTap: () => _showEditNamesDialog(cs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: cs.primary, size: 20),
                    const SizedBox(width: 12),
                    Text('이름 수정하기', style: bodyText(cs)),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Reset button
        GestureDetector(
          onTap: () => _showResetConfirmDialog(cs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: cs.error, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '처음부터 다시하기',
                      style: bodyText(cs).copyWith(color: cs.error),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: cs.error),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  void _showSetupDialog(ColorScheme cs) {
    final myNameController = TextEditingController();
    final partnerNameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('커플 등록', style: titleMedium(cs)),
                const SizedBox(height: 20),

                // Date picker
                Text('첫 손잡기 날짜', style: bodySmall(cs)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: cs.primary),
                        const SizedBox(width: 12),
                        Text(
                          '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                          style: bodyText(cs),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // My name
                Text('내 이름 (선택)', style: bodySmall(cs)),
                const SizedBox(height: 8),
                TextField(
                  controller: myNameController,
                  decoration: InputDecoration(
                    hintText: '나',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Partner name
                Text('상대방 이름 (선택)', style: bodySmall(cs)),
                const SizedBox(height: 8),
                TextField(
                  controller: partnerNameController,
                  decoration: InputDecoration(
                    hintText: '우리 자기',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    text: '시작하기',
                    icon: Icons.favorite_rounded,
                    glowColor: cs.primary,
                    onTap: () async {
                      await _coupleService.startCouple(
                        date: selectedDate,
                        myName: myNameController.text.isEmpty
                            ? null
                            : myNameController.text,
                        partnerName: partnerNameController.text.isEmpty
                            ? null
                            : partnerNameController.text,
                      );
                      Haptics.medium();
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditNamesDialog(ColorScheme cs) {
    final myNameController =
        TextEditingController(text: _coupleService.myName ?? '');
    final partnerNameController =
        TextEditingController(text: _coupleService.partnerName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('이름 수정', style: titleMedium(cs)),
            const SizedBox(height: 20),

            Text('내 이름', style: bodySmall(cs)),
            const SizedBox(height: 8),
            TextField(
              controller: myNameController,
              decoration: InputDecoration(
                hintText: '나',
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text('상대방 이름', style: bodySmall(cs)),
            const SizedBox(height: 8),
            TextField(
              controller: partnerNameController,
              decoration: InputDecoration(
                hintText: '우리 자기',
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: GlassButton(
                text: '저장하기',
                icon: Icons.check_rounded,
                glowColor: cs.primary,
                onTap: () async {
                  await _coupleService.updateNames(
                    myName: myNameController.text.isEmpty
                        ? null
                        : myNameController.text,
                    partnerName: partnerNameController.text.isEmpty
                        ? null
                        : partnerNameController.text,
                  );
                  Haptics.light();
                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog(ColorScheme cs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('정말 리셋할까요?', style: titleSmall(cs)),
        content: Text(
          '모든 기록과 뱃지가 삭제됩니다.\n이 작업은 되돌릴 수 없어요.',
          style: bodyText(cs),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: bodyText(cs)),
          ),
          TextButton(
            onPressed: () async {
              await _coupleService.resetCouple();
              Haptics.heavy();
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              '리셋하기',
              style: bodyText(cs).copyWith(color: cs.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(ColorScheme cs, CoupleBadge badge) {
    Haptics.light();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: badge.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badge.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Text(badge.emoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: titleMedium(cs).copyWith(color: badge.color),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: bodyText(cs).copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기', style: bodyText(cs)),
            ),
          ),
        ],
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
}

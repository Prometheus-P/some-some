import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/haptics/haptics.dart';
import '../../core/settings/settings_service.dart';
import '../../core/share/share_service.dart';
import '../../core/sound/sound_service.dart';
import '../../design_system/tds.dart';
import '../../design_system/components/animated_background.dart';
import '../../design_system/components/glass_button.dart';
import '../couple_mode/couple_service.dart';

enum StickyGamePhase { idle, playing, success, fail }

class StickyFingersScreen extends StatefulWidget {
  /// 연습 모드 (1인 플레이)
  final bool isPracticeMode;

  const StickyFingersScreen({
    super.key,
    this.isPracticeMode = false,
  });

  @override
  State<StickyFingersScreen> createState() => _StickyFingersScreenState();
}

class _StickyFingersScreenState extends State<StickyFingersScreen>
    with TickerProviderStateMixin {
  // Paint-only state (avoid rebuilding the whole widget tree per frame)
  final Map<int, Offset> _pointers = {};
  late Offset _targetA;
  late Offset _targetB;
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  final ValueNotifier<StickyGamePhase> _phase =
      ValueNotifier<StickyGamePhase>(StickyGamePhase.idle);

  // Repaint ticker
  late final Ticker _ticker;

  // UI capture for sharing
  final GlobalKey _shareKey = GlobalKey();
  final GlobalKey _resultShareKey = GlobalKey();

  // Grace period timer for accidental lifts
  Timer? _graceTimer;
  static const Duration _graceDuration = Duration(milliseconds: 200);
  final ValueNotifier<bool> _isGracePeriod = ValueNotifier<bool>(false);

  // Failure reason tracking
  String? _failureReason;

  // Milestone tracking (50%, 80%)
  bool _reached50 = false;
  bool _reached80 = false;
  final ValueNotifier<String?> _milestoneText = ValueNotifier<String?>(null);

  // Best record
  double? _bestTime;
  bool _isNewRecord = false;
  static const String _bestTimeKey = 'best_time';

  // Sound & Celebration
  final SoundService _sound = SoundService();
  final SettingsService _settings = SettingsService();
  final CoupleService _coupleService = CoupleService();
  late final ConfettiController _confettiController;

  // Success animation
  final ValueNotifier<bool> _showSuccessAnimation = ValueNotifier<bool>(false);

  static const String _storeText = '@somesome.app';

  // Hardcoded result messages (v1.0.0 MVP)
  static const List<String> _successLines = ['천생연분!', '손맛 미쳤다', '이 정도면 커플 확정'];
  static const List<String> _failLines = ['띠로리~', '아슬아슬했다', '다음 판엔 된다'];

  // Internal time
  double _time = 0.0;

  // Tunables (from settings)
  double get _durationSec => _settings.difficulty.duration;
  double get _moveSpeed => _settings.difficulty.speed;
  static const double _targetRadius = 55.0;

  @override
  void initState() {
    super.initState();
    _targetA = const Offset(120, 260);
    _targetB = const Offset(240, 260);
    _ticker = createTicker(_gameLoop);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _sound.init();
    _loadBestTime();
    _coupleService.initialize();
  }

  Future<void> _loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_bestTimeKey);
    if (saved != null && mounted) {
      setState(() => _bestTime = saved);
    }
  }

  Future<void> _saveBestTime(double time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bestTimeKey, time);
  }

  @override
  void dispose() {
    _graceTimer?.cancel();
    _ticker.dispose();
    _progress.dispose();
    _phase.dispose();
    _isGracePeriod.dispose();
    _milestoneText.dispose();
    _showSuccessAnimation.dispose();
    _confettiController.dispose();
    _sound.stopHeartbeat();
    super.dispose();
  }

  void _start() {
    _pointers.clear();
    _time = 0.0;
    _progress.value = 0.0;
    _phase.value = StickyGamePhase.playing;
    _failureReason = null;
    _isGracePeriod.value = false;
    _reached50 = false;
    _reached80 = false;
    _isNewRecord = false;
    _milestoneText.value = null;
    _showSuccessAnimation.value = false;
    _ticker.start();
    if (_settings.hapticEnabled) Haptics.heavy();
    if (_settings.soundEnabled) {
      _sound.playStart();
      _sound.startHeartbeat();
    }
  }

  void _stop({required bool success, String? reason}) {
    _graceTimer?.cancel();
    _isGracePeriod.value = false;
    _ticker.stop();
    _sound.stopHeartbeat();
    _phase.value = success ? StickyGamePhase.success : StickyGamePhase.fail;
    if (!success && reason != null) {
      _failureReason = reason;
    }
    if (success) {
      final currentTime = _durationSec;
      if (_bestTime == null || currentTime > _bestTime!) {
        _isNewRecord = true;
        _bestTime = currentTime;
        _saveBestTime(currentTime);
      }
      _showSuccessAnimation.value = true;
      if (_settings.hapticEnabled) Haptics.vibrate();
      if (_settings.soundEnabled) _sound.playSuccess();
      _confettiController.play();

      // Track play count (not in practice mode)
      if (!widget.isPracticeMode) {
        _coupleService.incrementPlayCount();
      }
    } else {
      if (_settings.hapticEnabled) Haptics.heavy();
      if (_settings.soundEnabled) _sound.playFail();
    }
  }

  void _shareResult() {
    final resultText = _phase.value == StickyGamePhase.success
        ? '썸썸 쫀드기 챌린지 성공! 💕\n${_durationSec.toInt()}초 버텼어요!\n\n@somesome.app'
        : '썸썸 쫀드기 챌린지 도전! 💪\n다음엔 성공할 거야!\n\n@somesome.app';
    ShareService.shareWidget(_resultShareKey, text: resultText);
  }

  void _reset() {
    _graceTimer?.cancel();
    _pointers.clear();
    _time = 0.0;
    _progress.value = 0.0;
    _phase.value = StickyGamePhase.idle;
    _failureReason = null;
    _isGracePeriod.value = false;
    _reached50 = false;
    _reached80 = false;
    _isNewRecord = false;
    _milestoneText.value = null;
    _showSuccessAnimation.value = false;
    setState(() {});
  }

  void _showMilestone(String text) {
    _milestoneText.value = text;
    if (_settings.hapticEnabled) Haptics.medium();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_milestoneText.value == text) {
        _milestoneText.value = null;
      }
    });
  }

  bool _isHoldingBoth() => widget.isPracticeMode
      ? _pointers.isNotEmpty
      : _pointers.length >= 2;

  int get _requiredPointers => widget.isPracticeMode ? 1 : 2;

  void _gameLoop(Duration elapsed) {
    if (_phase.value != StickyGamePhase.playing) return;

    final dt = 1 / 60.0;
    _time += dt;

    final t = _time * _moveSpeed;
    final cx = MediaQuery.of(context).size.width / 2;
    final cy = MediaQuery.of(context).size.height * 0.40;

    final aX = cx + sin(t) * 120;
    final aY = cy + sin(t * 2) * 70;
    final bX = cx + sin(t + pi) * 120;
    final bY = cy + sin((t + pi) * 2) * 70;

    _targetA = Offset(aX, aY);
    _targetB = Offset(bX, bY);

    if (_isHoldingBoth()) {
      final points = _pointers.values.toList();
      bool ok;

      if (widget.isPracticeMode) {
        // Practice mode: only check target A (bear)
        final p1 = points[0];
        ok = (p1 - _targetA).distance <= _targetRadius;
      } else {
        // Normal mode: check both targets
        final p1 = points[0];
        final p2 = points[1];

        final okA = (p1 - _targetA).distance <= _targetRadius;
        final okB = (p2 - _targetB).distance <= _targetRadius;
        final okSwapA = (p2 - _targetA).distance <= _targetRadius;
        final okSwapB = (p1 - _targetB).distance <= _targetRadius;
        ok = (okA && okB) || (okSwapA && okSwapB);
      }

      if (ok) {
        final next = (_progress.value + dt / _durationSec).clamp(0.0, 1.0);
        _progress.value = next;
        _sound.setHeartbeatSpeed(next);

        if (!_reached50 && next >= 0.5) {
          _reached50 = true;
          _showMilestone('반이다! 💪');
        }
        if (!_reached80 && next >= 0.8) {
          _reached80 = true;
          _showMilestone('거의 다 왔어! 🔥');
        }

        if (next >= 1.0) {
          _stop(success: true);
        }
      } else {
        _progress.value = (_progress.value - dt * 0.35).clamp(0.0, 1.0);
      }
    } else {
      _progress.value = (_progress.value - dt * 0.35).clamp(0.0, 1.0);
    }
  }

  String _resultLine() {
    final rng = Random();
    if (_phase.value == StickyGamePhase.success) {
      return _successLines[rng.nextInt(_successLines.length)];
    }
    if (_phase.value == StickyGamePhase.fail) {
      return _failLines[rng.nextInt(_failLines.length)];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.isPracticeMode ? '연습 모드' : '쫀드기 챌린지',
          style: titleSmall(cs),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildGlassBackButton(cs),
      ),
      body: MeshGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Animated Glow Progress Bar
              _buildGlowProgressBar(cs),
              const SizedBox(height: 12),
              // Game Area
              Expanded(
                child: RepaintBoundary(
                  key: _shareKey,
                  child: _buildGameArea(cs),
                ),
              ),
              const SizedBox(height: 12),
              // Bottom Section
              _buildBottomSection(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBackButton(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.onSurface,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildGlowProgressBar(ColorScheme cs) {
    return ValueListenableBuilder<double>(
      valueListenable: _progress,
      builder: (context, v, _) => ValueListenableBuilder<bool>(
        valueListenable: _isGracePeriod,
        builder: (context, isGrace, _) {
          final color = isGrace ? Colors.amber : cs.primary;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      ),
                    ),
                    // Progress with gradient
                    FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isGrace
                                ? [Colors.amber, Colors.orange]
                                : [cs.primary, cs.secondary],
                          ),
                        ),
                      )
                          .animate(
                            target: v > 0.8 ? 1 : 0,
                            onPlay: (c) => c.repeat(reverse: true),
                          )
                          .shimmer(
                            duration: 800.ms,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameArea(ColorScheme cs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Game Canvas with Touch Handler
            Listener(
              onPointerDown: (e) {
                _graceTimer?.cancel();
                _graceTimer = null;
                _isGracePeriod.value = false;
                _pointers[e.pointer] = e.localPosition;
                if (_phase.value == StickyGamePhase.idle &&
                    _pointers.length >= _requiredPointers) {
                  _start();
                }
                setState(() {});
              },
              onPointerMove: (e) {
                _pointers[e.pointer] = e.localPosition;
              },
              onPointerUp: (e) => _handlePointerUp(e),
              onPointerCancel: (e) => _handlePointerUp(e),
              child: CustomPaint(
                painter: GamePainter(
                  repaint: _progress,
                  pointers: _pointers,
                  targetA: _targetA,
                  targetB: _targetB,
                  progress: _progress.value,
                  isPlaying: _phase.value == StickyGamePhase.playing,
                  primaryColor: cs.primary,
                  secondaryColor: cs.secondary,
                  tertiaryColor: cs.tertiary,
                  isPracticeMode: widget.isPracticeMode,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            // Exit/Stop Button
            Positioned(
              top: 12,
              right: 12,
              child: _buildGlassActionButton(cs),
            ),
            // Milestone Popup
            _buildMilestonePopup(cs),
            // Success Animation
            _buildSuccessAnimation(cs),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [cs.primary, cs.secondary, cs.tertiary, Colors.amber, Colors.white],
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.2,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handlePointerUp(PointerEvent e) {
    final liftedPos = _pointers[e.pointer];
    _pointers.remove(e.pointer);
    if (_phase.value == StickyGamePhase.playing) {
      String liftReason = widget.isPracticeMode
          ? '손가락이 떨어졌어요'
          : '손가락이 떨어졌어요';
      if (liftedPos != null && !widget.isPracticeMode) {
        final screenWidth = MediaQuery.of(context).size.width;
        liftReason = liftedPos.dx < screenWidth / 2
            ? '왼쪽 손가락이 떨어졌어요'
            : '오른쪽 손가락이 떨어졌어요';
      }
      _graceTimer?.cancel();
      _isGracePeriod.value = true;
      _graceTimer = Timer(_graceDuration, () {
        if (_pointers.length < _requiredPointers &&
            _phase.value == StickyGamePhase.playing) {
          _stop(success: false, reason: liftReason);
        }
      });
    }
    setState(() {});
  }

  Widget _buildGlassActionButton(ColorScheme cs) {
    return GestureDetector(
      onTap: () {
        if (_phase.value == StickyGamePhase.playing) {
          _stop(success: false);
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
            ),
            child: Text(
              _phase.value == StickyGamePhase.playing ? '그만하기' : '나가기',
              style: bodySmall(cs),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestonePopup(ColorScheme cs) {
    return ValueListenableBuilder<String?>(
      valueListenable: _milestoneText,
      builder: (context, text, _) {
        if (text == null) return const SizedBox.shrink();
        return Positioned.fill(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer.withValues(alpha: 0.9),
                          cs.secondaryContainer.withValues(alpha: 0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      text,
                      style: titleMedium(cs).copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessAnimation(ColorScheme cs) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showSuccessAnimation,
      builder: (context, show, _) {
        if (!show) return const SizedBox.shrink();
        return Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, _) {
              return Center(
                child: Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🐻❤️🐰',
                          style: TextStyle(fontSize: 60 + (value * 20)),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.1, 1.1),
                              duration: 500.ms,
                            ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                '완벽한 호흡!',
                                style: titleSmall(cs).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(ColorScheme cs) {
    return ValueListenableBuilder<StickyGamePhase>(
      valueListenable: _phase,
      builder: (context, ph, _) {
        final line = _resultLine();
        if (ph == StickyGamePhase.playing || ph == StickyGamePhase.idle) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
              ),
              child: Text(
                ph == StickyGamePhase.idle
                    ? widget.isPracticeMode
                        ? '곰 캐릭터에 손가락을 올리면 시작!'
                        : '두 손가락을 캐릭터에 올리면 시작!'
                    : widget.isPracticeMode
                        ? '${_durationSec.toInt()}초 버티면 성공! (연습 모드)'
                        : '${_durationSec.toInt()}초 버티면 성공. 손 떼면 실패.',
                style: bodyText(cs),
                textAlign: TextAlign.center,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1);
        }

        final success = ph == StickyGamePhase.success;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: RepaintBoundary(
            key: _resultShareKey,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: (success ? cs.primary : cs.error).withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        success ? '성공!' : '실패!',
                        style: titleBig(cs).copyWith(
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: success
                                  ? [cs.primary, cs.secondary]
                                  : [cs.error, Colors.orange],
                            ).createShader(const Rect.fromLTWH(0, 0, 100, 50)),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 8),
                      // New record badge
                      if (success && _isNewRecord)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                '신기록!',
                                style: bodySmall(cs).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.5)),
                      // Record display
                      if (success && _bestTime != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '기록: ${_durationSec.toInt()}초 | 최고: ${_bestTime!.toInt()}초',
                            style: bodySmall(cs).copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      if (!success && _failureReason != null)
                        Text(
                          _failureReason!,
                          style: bodySmall(cs).copyWith(color: Colors.amber),
                          textAlign: TextAlign.center,
                        ),
                      if (line.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(line, style: bodyBig(cs), textAlign: TextAlign.center),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('썸썸', style: bodySmall(cs).copyWith(color: cs.onSurfaceVariant)),
                          const SizedBox(width: 8),
                          Text(_storeText, style: bodySmall(cs).copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              text: '다시하기',
                              icon: Icons.replay_rounded,
                              glowColor: cs.primary,
                              onTap: _reset,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassButton(
                              text: '공유하기',
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
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2);
      },
    );
  }
}

class GamePainter extends CustomPainter {
  final Map<int, Offset> pointers;
  final Offset targetA;
  final Offset targetB;
  final double progress;
  final bool isPlaying;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final bool isPracticeMode;

  GamePainter({
    Listenable? repaint,
    required this.pointers,
    required this.targetA,
    required this.targetB,
    required this.progress,
    required this.isPlaying,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    this.isPracticeMode = false,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Connection Line with enhanced glow
    if (pointers.length >= 2) {
      final p1 = pointers.values.first;
      final p2 = pointers.values.last;

      // Outer glow
      for (var i = 3; i > 0; i--) {
        paint.color = primaryColor.withValues(alpha: 0.1 * i);
        paint.strokeWidth = 4 + (i * 6);
        paint.strokeCap = StrokeCap.round;
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, i * 3.0);
        canvas.drawLine(p1, p2, paint);
      }
      paint.maskFilter = null;

      // Core line
      paint.color = primaryColor;
      paint.strokeWidth = 3;
      canvas.drawLine(p1, p2, paint);

      final dist = (p1 - p2).distance;
      if (dist < 100) {
        _drawText(canvas, '어머! 닿겠어!', (p1 + p2) / 2 + const Offset(0, -40), tertiaryColor, 14, true);
      }
    }

    // Enhanced Characters
    _drawCharacter(canvas, targetA, '🐻', secondaryColor, progress);
    if (!isPracticeMode) {
      _drawCharacter(canvas, targetB, '🐰', primaryColor, progress);
    }

    // Touch points with pulse effect
    pointers.forEach((id, pos) {
      // Outer pulse
      final pulseRadius = 30 + (sin(progress * 10) * 5);
      paint.color = Colors.white.withValues(alpha: 0.2);
      canvas.drawCircle(pos, pulseRadius, paint);

      // Mid ring
      paint.color = Colors.white.withValues(alpha: 0.4);
      canvas.drawCircle(pos, 20, paint);

      // Core
      paint.color = Colors.white;
      canvas.drawCircle(pos, 8, paint);
    });
  }

  void _drawCharacter(Canvas canvas, Offset pos, String emoji, Color glowColor, double progress) {
    final paint = Paint();

    // Animated outer glow
    final glowSize = 50 + (sin(progress * 8) * 8);
    paint.color = glowColor.withValues(alpha: 0.3);
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(pos, glowSize, paint);

    // Inner glow
    paint.color = glowColor.withValues(alpha: 0.5);
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(pos, 35, paint);
    paint.maskFilter = null;

    // Ring
    paint.color = glowColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(pos, 38, paint);

    // Emoji
    final textSpan = TextSpan(text: emoji, style: const TextStyle(fontSize: 44));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawText(Canvas canvas, String text, Offset pos, Color color, double fontSize, bool bold) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

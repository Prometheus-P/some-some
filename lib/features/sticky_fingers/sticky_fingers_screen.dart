import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/haptics/haptics.dart';
import '../../design_system/tds.dart';

enum StickyGamePhase { idle, playing, success, fail }

class StickyFingersScreen extends StatefulWidget {
  const StickyFingersScreen({super.key});

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

  static const String _storeText = '@somesome.app';

  // Hardcoded result messages (v1.0.0 MVP)
  static const List<String> _successLines = ['천생연분!', '손맛 미쳤다', '이 정도면 커플 확정'];
  static const List<String> _failLines = ['띠로리~', '아슬아슬했다', '다음 판엔 된다'];

  // Internal time
  double _time = 0.0;

  // Tunables
  static const double _durationSec = 15.0;
  static const double _targetRadius = 34.0;
  static const double _moveSpeed = 1.0; // scales the curve speed

  @override
  void initState() {
    super.initState();
    _targetA = const Offset(120, 260);
    _targetB = const Offset(240, 260);
    _ticker = createTicker(_gameLoop);
  }

  @override
  void dispose() {
    _graceTimer?.cancel();
    _ticker.dispose();
    _progress.dispose();
    _phase.dispose();
    super.dispose();
  }

  void _start() {
    _pointers.clear();
    _time = 0.0;
    _progress.value = 0.0;
    _phase.value = StickyGamePhase.playing;
    _ticker.start();
    Haptics.heavy();
  }

  void _stop({required bool success}) {
    _graceTimer?.cancel();
    _ticker.stop();
    _phase.value = success ? StickyGamePhase.success : StickyGamePhase.fail;
    if (success) {
      Haptics.vibrate();
    } else {
      Haptics.heavy();
    }
  }

  void _reset() {
    _graceTimer?.cancel();
    _pointers.clear();
    _time = 0.0;
    _progress.value = 0.0;
    _phase.value = StickyGamePhase.idle;
    setState(() {});
  }

  bool _isHoldingBoth() => _pointers.length >= 2;

  void _gameLoop(Duration elapsed) {
    if (_phase.value != StickyGamePhase.playing) return;

    // Drive motion
    final dt = 1 / 60.0;
    _time += dt;

    // Infinity (8) curve with phase shift to make them cross
    final t = _time * _moveSpeed;
    final cx = MediaQuery.of(context).size.width / 2;
    final cy = MediaQuery.of(context).size.height * 0.40;

    final aX = cx + sin(t) * 120;
    final aY = cy + sin(t * 2) * 70;
    final bX = cx + sin(t + pi) * 120;
    final bY = cy + sin((t + pi) * 2) * 70;

    _targetA = Offset(aX, aY);
    _targetB = Offset(bX, bY);

    // Update progress only if both are held and within radius
    if (_isHoldingBoth()) {
      final points = _pointers.values.toList();
      final p1 = points[0];
      final p2 = points[1];

      final okA = (p1 - _targetA).distance <= _targetRadius;
      final okB = (p2 - _targetB).distance <= _targetRadius;
      final okSwapA = (p2 - _targetA).distance <= _targetRadius;
      final okSwapB = (p1 - _targetB).distance <= _targetRadius;
      final ok = (okA && okB) || (okSwapA && okSwapB);

      if (ok) {
        final next = (_progress.value + dt / _durationSec).clamp(0.0, 1.0);
        _progress.value = next;
        if (next >= 1.0) {
          _stop(success: true);
        }
      } else {
        // decay a bit (prevents "stuck" progress)
        _progress.value = (_progress.value - dt * 0.35).clamp(0.0, 1.0);
      }
    } else {
      // Grace period handled by touch events, not game loop
      // Progress decay only (no immediate fail from game loop)
      _progress.value = (_progress.value - dt * 0.35).clamp(0.0, 1.0);
    }

    // Only repaint the canvas via ticker; UI is ValueListenable-driven
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    // (Ticker triggers CustomPainter repaint through Listenable)
    // no setState per-frame; painter repaints via ticker & UI uses ValueNotifiers
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
      appBar: AppBar(
        title: const Text('쫀드기 챌린지'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (context, v, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: v),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RepaintBoundary(
                key: _shareKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Listener(
                      onPointerDown: (e) {
                        // Cancel any pending grace timer (finger returned)
                        _graceTimer?.cancel();
                        _graceTimer = null;

                        _pointers[e.pointer] = e.localPosition;
                        if (_phase.value == StickyGamePhase.idle &&
                            _pointers.length >= 2) {
                          _start();
                        }
                        setState(() {});
                      },
                      onPointerMove: (e) {
                        _pointers[e.pointer] = e.localPosition;
                      },
                      onPointerUp: (e) {
                        _pointers.remove(e.pointer);
                        if (_phase.value == StickyGamePhase.playing) {
                          // Start grace period instead of immediate fail
                          _graceTimer?.cancel();
                          _graceTimer = Timer(_graceDuration, () {
                            if (_pointers.length < 2 &&
                                _phase.value == StickyGamePhase.playing) {
                              _stop(success: false);
                            }
                          });
                        }
                        setState(() {});
                      },
                      onPointerCancel: (e) {
                        _pointers.remove(e.pointer);
                        if (_phase.value == StickyGamePhase.playing) {
                          // Start grace period for cancel events too
                          _graceTimer?.cancel();
                          _graceTimer = Timer(_graceDuration, () {
                            if (_pointers.length < 2 &&
                                _phase.value == StickyGamePhase.playing) {
                              _stop(success: false);
                            }
                          });
                        }
                        setState(() {});
                      },
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
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: FilledButton.tonal(
                            onPressed: () {
                              if (_phase.value == StickyGamePhase.playing) {
                                _stop(success: false);
                              } else {
                                Navigator.of(context).maybePop();
                              }
                            },
                            child: Text(_phase.value == StickyGamePhase.playing ? '그만하기' : '나가기'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<StickyGamePhase>(
              valueListenable: _phase,
              builder: (context, ph, _) {
                final line = _resultLine();
                if (ph == StickyGamePhase.playing || ph == StickyGamePhase.idle) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      ph == StickyGamePhase.idle
                          ? '두 손가락을 캐릭터에 올리면 시작!'
                          : '15초 버티면 성공. 손 떼면 실패.',
                      style: titleSmall(cs),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final success = ph == StickyGamePhase.success;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: RepaintBoundary(
                    key: _resultShareKey,
                    child: Column(
                      children: [
                        Text(
                          success ? '성공!' : '실패!',
                          style: titleBig(cs),
                        ),
                        const SizedBox(height: 6),
                        if (line.isNotEmpty)
                          Text(line, style: bodyBig(cs), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('썸썸', style: bodySmall(cs)),
                              const SizedBox(width: 8),
                              Text(_storeText, style: bodySmall(cs)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _reset,
                                child: const Text('다시하기'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () => Navigator.of(context).maybePop(),
                                child: const Text('나가기'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw Connection Line between Pointers (Red Thread of Fate)
    if (pointers.length >= 2) {
      final p1 = pointers.values.first;
      final p2 = pointers.values.last;

      // Glow Effect
      paint.color = primaryColor.withOpacity(0.3);
      paint.strokeWidth = 10;
      paint.strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, paint);

      // Core Line
      paint.color = primaryColor;
      paint.strokeWidth = 3;
      canvas.drawLine(p1, p2, paint);

      // Distance Text
      final dist = (p1 - p2).distance;
      if (dist < 100) {
        _drawText(
          canvas,
          '어머! 닿겠어!',
          (p1 + p2) / 2 + const Offset(0, -40),
          tertiaryColor,
          14,
          true,
        );
      }
    }

    // 2. Draw Targets (Bear & Rabbit)
    _drawCharacter(canvas, targetA, '🐻', secondaryColor);
    _drawCharacter(canvas, targetB, '🐰', primaryColor);

    // 3. Draw User Touches (Visual Feedback)
    pointers.forEach((id, pos) {
      paint.color = Colors.white.withOpacity(0.5);
      canvas.drawCircle(pos, 30, paint);
      paint.color = Colors.white;
      canvas.drawCircle(pos, 10, paint);
    });
  }

  void _drawCharacter(
    Canvas canvas,
    Offset pos,
    String emoji,
    Color glowColor,
  ) {
    final paint = Paint();

    // Glow
    paint.color = glowColor.withOpacity(0.4);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(pos, 40, paint);
    paint.maskFilter = null;

    // Ring
    paint.color = glowColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(pos, 35, paint);

    // Emoji
    final textSpan = TextSpan(
      text: emoji,
      style: const TextStyle(fontSize: 40),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color,
    double fontSize,
    bool bold,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Pretendard',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// 6. UTILS & COMPONENTS
// -----------------------------------------------------------------------------

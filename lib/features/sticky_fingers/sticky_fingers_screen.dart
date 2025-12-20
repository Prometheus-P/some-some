import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/haptics/haptics.dart';
import '../../core/app_links.dart';
import '../../core/packs/pack.dart';
import '../../core/packs/pack_loader.dart';
import '../../core/share/share_service.dart';
import '../../core/settings/settings_store.dart';
import '../../core/telemetry/analytics.dart';
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

  final SettingsStore _settings = SettingsStore();
  final Analytics _analytics = DebugAnalytics();

  double _sensitivity = 0.25;
  bool _batterySaver = false;

  static const String _storeText = AppLinks.storeText;

  // Content pack
  ContentPack? _pack;

  // Internal time
  double _time = 0.0;

  // Tunables
  static const double _durationSec = 15.0;
  static const double _targetRadius = 34.0;
  static const double _moveSpeed = 1.0; // scales the curve speed

  @override
  void initState() {
    super.initState();

    _analytics.log('app_open', {'screen': 'sticky_fingers'});

    // Load persisted settings
    () async {
      final s = await _settings.loadSensitivity();
      final b = await _settings.loadBatterySaver();
      if (!mounted) return;
      setState(() {
        _sensitivity = s;
        _batterySaver = b;
      });
    }();
    _targetA = const Offset(120, 260);
    _targetB = const Offset(240, 260);

    _ticker = createTicker(_gameLoop);

    // Load pack (non-blocking)
    PackLoader.loadDefault().then((p) {
      _analytics.log('pack_loaded', {'id': p.id, 'schema': p.schemaVersion});
      if (mounted) setState(() => _pack = p);
    });
  }

  @override
  void dispose() {
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
    _analytics.log(success ? 'finish_game' : 'fail_game', {'mode': 'sticky'});
    _ticker.stop();
    _phase.value = success ? StickyGamePhase.success : StickyGamePhase.fail;
    if (success) {
      Haptics.vibrate();
    } else {
      Haptics.heavy();
    }
  }

  void _reset() {
    _analytics.log('reset_game');
    _pointers.clear();
    _time = 0.0;
    _progress.value = 0.0;
    _phase.value = StickyGamePhase.idle;
    setState(() {}); // once
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
      // if they stop holding, fail quickly
      if (_progress.value > 0.08) {
        _analytics.log('fail_game', {});
                          _stop(success: false);
      }
    }

    // Only repaint the canvas via ticker; UI is ValueListenable-driven
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    // (Ticker triggers CustomPainter repaint through Listenable)
    // no setState per-frame; painter repaints via ticker & UI uses ValueNotifiers
  }

  String _resultLine() {
    final pack = _pack;
    if (pack == null) return '';
    final rng = Random();
    if (_phase.value == StickyGamePhase.success) {
      return pack.successLines[rng.nextInt(pack.successLines.length)];
    }
    if (_phase.value == StickyGamePhase.fail) {
      return pack.failLines[rng.nextInt(pack.failLines.length)];
    }
    return '';
  }

  Future<void> _share() async {
    _analytics.log('share_open', {'phase': _phase.value.toString()});
    final ctx = _resultShareKey.currentContext;
    if (ctx == null) return;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    await ShareService.shareRepaintBoundary(
      boundary: boundary,
      text: '썸썸 결과: ${_resultLine()} — $_storeText',
      pixelRatio: _batterySaver ? 2.0 : 3.0,
    );

    _analytics.log('share_success');
  }


  void _openSettings() {
    _analytics.log('settings_open');
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              spaceMedium,
              spaceXSmall,
              spaceMedium,
              spaceMedium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('민감도(접촉 강도)', style: titleSmall(Theme.of(context).colorScheme)),
                Slider(
                  value: _sensitivity,
                  onChanged: (v) async {
                    setState(() => _sensitivity = v);
                    await _settings.saveSensitivity(v);
                    _analytics.log('settings_sensitivity_change', {'v': v});
                  },
                ),
                const SizedBox(height: spaceXSmall),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('배터리 세이브 모드', style: bodyBig(Theme.of(context).colorScheme)),
                  subtitle: Text('이펙트를 줄여 발열/배터리를 아낍니다', style: bodySmall(Theme.of(context).colorScheme)),
                  value: _batterySaver,
                  onChanged: (v) async {
                    setState(() => _batterySaver = v);
                    await _settings.saveBatterySaver(v);
                    _analytics.log('settings_battery_saver_change', {'v': v});
                  },
                ),
                const SizedBox(height: spaceXSmall),
                const SizedBox(height: spaceSmall),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('개인정보처리방침', style: bodyBig(Theme.of(context).colorScheme)),
                  subtitle: Text(AppLinks.privacyPolicyUrl, style: bodySmall(Theme.of(context).colorScheme)),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openUrl(AppLinks.privacyPolicyUrl),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('고객지원', style: bodyBig(Theme.of(context).colorScheme)),
                  subtitle: Text(AppLinks.supportUrl, style: bodySmall(Theme.of(context).colorScheme)),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openUrl(AppLinks.supportUrl),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('스토어', style: bodyBig(Theme.of(context).colorScheme)),
                  subtitle: Text(AppLinks.storeUrl, style: bodySmall(Theme.of(context).colorScheme)),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openUrl(AppLinks.storeUrl),
                ),
                const SizedBox(height: spaceXSmall),
                Text('팁: 기본은 낮게. 원할 때만 올려.', style: bodySmall(Theme.of(context).colorScheme)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('쫀드기 챌린지'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: '설정',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: spaceXSmall),
            ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (context, v, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: spaceMedium),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: v),
                ),
              ),
            ),
            const SizedBox(height: spaceSmall),
            Expanded(
              child: RepaintBoundary(
                key: _shareKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Listener(
                      onPointerDown: (e) {
                        _pointers[e.pointer] = e.localPosition;
                        if (_phase.value == StickyGamePhase.idle &&
                            _pointers.length >= 2) {
                          _analytics.log('start_game', {'mode': 'sticky'});
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
                          _stop(success: false);
                        }
                        setState(() {});
                      },
                      onPointerCancel: (e) {
                        _pointers.remove(e.pointer);
                        if (_phase.value == StickyGamePhase.playing) {
                          _stop(success: false);
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
            const SizedBox(height: spaceSmall),
            ValueListenableBuilder<StickyGamePhase>(
              valueListenable: _phase,
              builder: (context, ph, _) {
                final line = _resultLine();
                if (ph == StickyGamePhase.playing || ph == StickyGamePhase.idle) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      spaceMedium,
                      0,
                      spaceMedium,
                      spaceMedium,
                    ),
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
                  padding: const EdgeInsets.fromLTRB(
                    spaceMedium,
                    0,
                    spaceMedium,
                    spaceMedium,
                  ),
                  child: RepaintBoundary(
                    key: _resultShareKey,
                    child: Column(
                      children: [
                        Text(
                          success ? '성공!' : '실패!',
                          style: titleBig(cs),
                        ),
                        const SizedBox(height: spaceXxSmall),
                        if (line.isNotEmpty)
                          Text(line, style: bodyBig(cs), textAlign: TextAlign.center),
                        const SizedBox(height: spaceSmall),
                        Padding(
                          padding: const EdgeInsets.only(bottom: spaceXSmall),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('썸썸', style: bodySmall(cs)),
                              const SizedBox(width: spaceXSmall),
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
                            const SizedBox(width: spaceXSmall),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: _share,
                                child: const Text('공유하기'),
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

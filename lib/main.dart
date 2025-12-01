import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ThumbSomeApp());
}

// -----------------------------------------------------------------------------
// 1. DESIGN SYSTEM (Toss Style + Kitsch)
// -----------------------------------------------------------------------------
class TDS {
  static const Color background = Color(0xFF17171C); // 토스 다크 모드 배경
  static const Color card = Color(0xFF202632); // 카드 배경
  static const Color primaryBlue = Color(0xFF0064FF); // 토스 블루
  static const Color kitschPink = Color(0xFFFF007F); // 썸썸 핑크
  static const Color kitschYellow = Color(0xFFFFD700); // 썸썸 옐로우
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8B95A1);
  static const Color danger = Color(0xFFF04452); // 에러/실패

  static const TextStyle titleBig = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textWhite,
    letterSpacing: -0.5,
    height: 1.3,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textWhite,
    letterSpacing: -0.5,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFFB0B8C1),
    letterSpacing: -0.2,
  );

  // 쫀득한 애니메이션 커브
  static const Curve spring = Curves.elasticOut;
}

// -----------------------------------------------------------------------------
// 2. MAIN APP
// -----------------------------------------------------------------------------
class ThumbSomeApp extends StatelessWidget {
  const ThumbSomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 상태바 투명 처리 (몰입감 증대)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thumb Some',
      theme: ThemeData(
        scaffoldBackgroundColor: TDS.background,
        fontFamily: 'Pretendard', // 있으면 좋고 없으면 시스템 폰트
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. INTRO SCREEN (Lobby)
// -----------------------------------------------------------------------------
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Toss Style Header
              FadeInUp(
                delay: 0,
                child: Text(
                  "너랑 나랑\n손끝 시그널",
                  style: TDS.titleBig.copyWith(fontSize: 34),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: 200,
                child: Text("진지함은 빼고,\n스킨십은 더하고!", style: TDS.body),
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
                              color: TDS.primaryBlue.withOpacity(0.2),
                              shape: BoxShape.circle,
                              blurRadius: 20,
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
                              color: TDS.kitschPink.withOpacity(0.2),
                              shape: BoxShape.circle,
                              blurRadius: 20,
                            ),
                          ),
                        ),
                        const Text("💕", style: TextStyle(fontSize: 80)),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // Toss Style Button
              FadeInUp(
                delay: 400,
                child: TossButton(
                  text: "쫀드기 챌린지 시작하기",
                  color: TDS.primaryBlue,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: 500,
                child: Center(
                  child: Text(
                    "술자리 / 카페 / 썸 탈때 추천",
                    style: TDS.body.copyWith(fontSize: 12),
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
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game State
  bool isPlaying = false;
  bool isGameOver = false;
  bool isSuccess = false;
  double progress = 0.0; // 0.0 ~ 1.0 (100%)

  // Touch Points
  final Map<int, Offset> _pointers = {};

  // Targets (Bear & Rabbit)
  late Offset targetA; // Blue Bear
  late Offset targetB; // Pink Rabbit

  // Physics & Animation
  late Ticker _ticker;
  double _time = 0.0;
  final double gameDuration = 15.0; // 15 seconds to win

  // Game Constants
  final double targetRadius = 45.0;
  final double touchTolerance = 60.0;

  @override
  void initState() {
    super.initState();
    // 초기 타겟 위치 (화면 중앙 부근)
    targetA = const Offset(100, 400);
    targetB = const Offset(300, 400);

    _ticker = createTicker(_gameLoop);
    // 화면 크기를 알 수 없으므로 시작 시점에 중앙 정렬은 build 이후 처리하거나 대략적인 값 사용
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      isPlaying = true;
      isGameOver = false;
      isSuccess = false;
      progress = 0.0;
      _time = 0.0;
    });
    _ticker.start();
    HapticFeedback.heavyImpact();
  }

  void _gameLoop(Duration elapsed) {
    if (!isPlaying) return;

    setState(() {
      // 1. Time Update
      double dt = 0.016; // approx 60fps
      _time += dt;
      progress = _time / gameDuration;

      if (progress >= 1.0) {
        _finishGame(true);
        return;
      }

      // 2. Move Targets (The "Sticky Fingers" Logic)
      // 시간이 갈수록 더 요란하게 움직임 (Sin/Cos 조합으로 8자 그리기 유도)
      Size size = MediaQuery.of(context).size;
      double centerX = size.width / 2;
      double centerY = size.height / 2;

      double intensity = 1.0 + (progress * 2.0); // 난이도 증가

      // Target A (Bear) 움직임
      targetA = Offset(
        centerX - 80 + sin(_time * 1.5) * 60 * intensity,
        centerY + cos(_time * 2.1) * 100 * intensity,
      );

      // Target B (Rabbit) 움직임 (반대 위상으로 꼬이게 만듦)
      targetB = Offset(
        centerX + 80 + cos(_time * 1.8) * 60 * intensity,
        centerY + sin(_time * 2.4) * 100 * intensity,
      );

      // 3. Collision Detection (놓쳤는지 확인)
      bool touchingA = false;
      bool touchingB = false;

      _pointers.forEach((id, pos) {
        if ((pos - targetA).distance < touchTolerance) touchingA = true;
        if ((pos - targetB).distance < touchTolerance) touchingB = true;
      });

      // 둘 다 잡고 있지 않으면 실패
      if ((!touchingA || !touchingB) && _time > 0.5) {
        // 시작 직후 0.5초는 봐줌
        _finishGame(false);
      } else {
        // 잘 잡고 있으면 햅틱 피드백 (심장 박동)
        if (_time % 1.0 < 0.05) {
          // 1초마다
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  void _finishGame(bool success) {
    _ticker.stop();
    setState(() {
      isPlaying = false;
      isGameOver = !success;
      isSuccess = success;
    });

    if (success) {
      HapticFeedback.vibrate();
    } else {
      // 실패 시 2번 퉁퉁
      HapticFeedback.heavyImpact();
      Future.delayed(
        const Duration(milliseconds: 200),
        () => HapticFeedback.heavyImpact(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Game Layer (Touch Listener)
          Positioned.fill(
            child: Listener(
              onPointerDown: (e) {
                setState(() => _pointers[e.pointer] = e.localPosition);
                if (!isPlaying &&
                    !isGameOver &&
                    !isSuccess &&
                    _pointers.length >= 2) {
                  _startGame();
                }
              },
              onPointerMove: (e) {
                setState(() => _pointers[e.pointer] = e.localPosition);
              },
              onPointerUp: (e) {
                setState(() => _pointers.remove(e.pointer));
              },
              onPointerCancel: (e) {
                setState(() => _pointers.remove(e.pointer));
              },
              child: Container(
                color: Colors.transparent, // Touch 영역 확보
                child: CustomPaint(
                  painter: GamePainter(
                    pointers: _pointers,
                    targetA: targetA,
                    targetB: targetB,
                    progress: progress,
                    isPlaying: isPlaying,
                  ),
                ),
              ),
            ),
          ),

          // 2. UI Layer (Top Status)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!isPlaying && !isGameOver && !isSuccess)
                  FadeInUp(
                    child: Column(
                      children: [
                        const Text("🐻", style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          "각자 캐릭터를\n꾹 눌러주세요",
                          textAlign: TextAlign.center,
                          style: TDS.titleMedium.copyWith(
                            color: TDS.kitschYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isPlaying)
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: TDS.titleBig.copyWith(
                      fontSize: 40,
                      color: TDS.textWhite.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),

          // 3. Result Overlay
          if (isGameOver) _buildFailOverlay(),
          if (isSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildFailOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("😱", style: TextStyle(fontSize: 80)),
              Text("띠로리~", style: TDS.titleBig.copyWith(color: TDS.danger)),
              const SizedBox(height: 10),
              const Text(
                "손을 놓쳐버렸어요!\n(벌칙: 서로 10초간 눈맞춤)",
                textAlign: TextAlign.center,
                style: TDS.body,
              ),
              const SizedBox(height: 30),
              TossButton(
                text: "다시 도전",
                color: TDS.danger,
                onTap: () {
                  setState(() {
                    isGameOver = false;
                    _pointers.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 80)),
              Text(
                "천생연분!",
                style: TDS.titleBig.copyWith(color: TDS.kitschPink),
              ),
              const SizedBox(height: 10),
              const Text(
                "이 정도면 사귀어야 하는 거 아님?",
                textAlign: TextAlign.center,
                style: TDS.body,
              ),
              const SizedBox(height: 30),
              TossButton(
                text: "다음 단계로",
                color: TDS.kitschPink,
                onTap: () {
                  setState(() {
                    isSuccess = false;
                    _pointers.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. PAINTER (High Performance Graphics)
// -----------------------------------------------------------------------------
class GamePainter extends CustomPainter {
  final Map<int, Offset> pointers;
  final Offset targetA;
  final Offset targetB;
  final double progress;
  final bool isPlaying;

  GamePainter({
    required this.pointers,
    required this.targetA,
    required this.targetB,
    required this.progress,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 1. Draw Connection Line between Pointers (Red Thread of Fate)
    if (pointers.length >= 2) {
      final p1 = pointers.values.first;
      final p2 = pointers.values.last;

      // Glow Effect
      paint.color = TDS.kitschPink.withOpacity(0.3);
      paint.strokeWidth = 10;
      paint.strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, paint);

      // Core Line
      paint.color = TDS.kitschPink;
      paint.strokeWidth = 3;
      canvas.drawLine(p1, p2, paint);

      // Distance Text
      final dist = (p1 - p2).distance;
      if (dist < 100) {
        _drawText(
          canvas,
          "어머! 닿겠어!",
          (p1 + p2) / 2 + const Offset(0, -40),
          TDS.kitschYellow,
          14,
          true,
        );
      }
    }

    // 2. Draw Targets (Bear & Rabbit)
    _drawCharacter(canvas, targetA, "🐻", TDS.primaryBlue);
    _drawCharacter(canvas, targetB, "🐰", TDS.kitschPink);

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
class TossButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const TossButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16), // Toss Corner Radius
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FadeInUp extends StatefulWidget {
  final Widget child;
  final int delay;

  const FadeInUp({super.key, required this.child, this.delay = 0});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: TDS.spring));
    _translate = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: TDS.spring));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: _translate.value,
        child: Opacity(opacity: _opacity.value, child: widget.child),
      ),
    );
  }
}

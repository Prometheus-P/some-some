import 'package:flutter/material.dart';

/// 공유 카드 타입
enum ShareCardType {
  soulSync,      // 이심전심 결과
  stickyFingers, // 쫀드기 성공
  penaltyRoulette, // 복불복 결과
  coupleStats,   // 커플 통계
}

/// 브랜딩된 공유 카드 빌더
class ShareCardBuilder extends StatelessWidget {
  final ShareCardType type;
  final String title;
  final String subtitle;
  final String emoji;
  final int? percent;
  final String? extraInfo;
  final Color primaryColor;
  final Color secondaryColor;

  const ShareCardBuilder({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.percent,
    this.extraInfo,
    this.primaryColor = const Color(0xFFFF007F),
    this.secondaryColor = const Color(0xFF7C3AED),
  });

  /// 이심전심 결과 카드
  factory ShareCardBuilder.soulSync({
    required int matchPercent,
    required String resultMessage,
    required int matchCount,
    required int totalQuestions,
  }) {
    String emoji;
    if (matchPercent >= 80) {
      emoji = '🎉';
    } else if (matchPercent >= 50) {
      emoji = '😊';
    } else {
      emoji = '😅';
    }

    return ShareCardBuilder(
      type: ShareCardType.soulSync,
      title: resultMessage,
      subtitle: '이심전심 텔레파시',
      emoji: emoji,
      percent: matchPercent,
      extraInfo: '$matchCount / $totalQuestions 일치',
      primaryColor: const Color(0xFFFF007F),
      secondaryColor: const Color(0xFF7C3AED),
    );
  }

  /// 쫀드기 성공 카드
  factory ShareCardBuilder.stickyFingers({
    required Duration duration,
    bool isPracticeMode = false,
  }) {
    final seconds = duration.inMilliseconds / 1000;
    return ShareCardBuilder(
      type: ShareCardType.stickyFingers,
      title: isPracticeMode ? '연습 성공!' : '챌린지 성공!',
      subtitle: '쫀드기 챌린지',
      emoji: '🎯',
      extraInfo: '${seconds.toStringAsFixed(1)}초 버티기 성공',
      primaryColor: const Color(0xFFFF6B9D),
      secondaryColor: const Color(0xFFFF007F),
    );
  }

  /// 복불복 결과 카드
  factory ShareCardBuilder.penaltyRoulette({
    required String penaltyText,
    required String penaltyEmoji,
    required int intensity,
  }) {
    return ShareCardBuilder(
      type: ShareCardType.penaltyRoulette,
      title: penaltyText,
      subtitle: '복불복 룰렛',
      emoji: penaltyEmoji,
      extraInfo: '강도 ${'🔥' * intensity}',
      primaryColor: const Color(0xFFFDAA5D),
      secondaryColor: const Color(0xFFE17055),
    );
  }

  /// 커플 통계 카드
  factory ShareCardBuilder.coupleStats({
    required int daysTogether,
    required int playCount,
    required int badgeCount,
    String? myName,
    String? partnerName,
  }) {
    return ShareCardBuilder(
      type: ShareCardType.coupleStats,
      title: 'D+$daysTogether',
      subtitle: '${myName ?? '나'} 💕 ${partnerName ?? '우리 자기'}',
      emoji: '💑',
      extraInfo: '플레이 $playCount회 · 뱃지 $badgeCount개',
      primaryColor: const Color(0xFFFF6B9D),
      secondaryColor: const Color(0xFF6C5CE7),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instagram Story 최적화 비율 (9:16)
    return Container(
      width: 360,
      height: 640,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            const Color(0xFF0f0f23),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background decoration
          _buildBackgroundDecoration(),

          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Emoji with glow
                _buildEmojiSection(),

                const SizedBox(height: 24),

                // Title
                _buildTitle(),

                const SizedBox(height: 12),

                // Percent (if available)
                if (percent != null) ...[
                  _buildPercentDisplay(),
                  const SizedBox(height: 16),
                ],

                // Extra info
                if (extraInfo != null) _buildExtraInfo(),

                const Spacer(flex: 3),

                // Branding footer
                _buildBrandingFooter(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        // Gradient orbs
        Positioned(
          top: 100,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.3),
                  primaryColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          right: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondaryColor.withValues(alpha: 0.3),
                  secondaryColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Mesh gradient effect
        Positioned.fill(
          child: CustomPaint(
            painter: _MeshGradientPainter(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryColor.withValues(alpha: 0.2),
            primaryColor.withValues(alpha: 0.0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 80),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Subtitle (game name)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Main title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [primaryColor, secondaryColor],
          ).createShader(bounds),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.2),
            secondaryColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = LinearGradient(
              colors: [primaryColor, secondaryColor],
            ).createShader(const Rect.fromLTWH(0, 0, 150, 60)),
        ),
      ),
    );
  }

  Widget _buildExtraInfo() {
    return Text(
      extraInfo!,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBrandingFooter() {
    return Column(
      children: [
        // Divider
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.5),
                secondaryColor.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 20),
        // App name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💕', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [primaryColor, secondaryColor],
              ).createShader(bounds),
              child: const Text(
                '썸썸',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Hashtag
        Text(
          '#썸썸챌린지 #SomeSome',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

/// 메쉬 그라데이션 배경 페인터
class _MeshGradientPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _MeshGradientPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Top-left blob
    paint.color = primaryColor.withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.15),
      120,
      paint,
    );

    // Center-right blob
    paint.color = secondaryColor.withValues(alpha: 0.12);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.4),
      100,
      paint,
    );

    // Bottom-center blob
    paint.color = primaryColor.withValues(alpha: 0.1);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.85),
      130,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 공유 카드 유틸리티
class ShareCardUtils {
  /// 해시태그 생성
  static String getHashtags(ShareCardType type) {
    switch (type) {
      case ShareCardType.soulSync:
        return '#썸썸챌린지 #이심전심 #텔레파시 #커플게임';
      case ShareCardType.stickyFingers:
        return '#썸썸챌린지 #쫀드기챌린지 #손잡기게임';
      case ShareCardType.penaltyRoulette:
        return '#썸썸챌린지 #복불복 #벌칙게임';
      case ShareCardType.coupleStats:
        return '#썸썸챌린지 #커플스타그램 #럽스타그램';
    }
  }

  /// 공유 텍스트 생성
  static String getShareText({
    required ShareCardType type,
    required String title,
    int? percent,
    String? extraInfo,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('썸썸 💕');
    buffer.writeln();

    switch (type) {
      case ShareCardType.soulSync:
        buffer.writeln('이심전심 텔레파시 결과');
        buffer.writeln('$title - $percent%');
        if (extraInfo != null) buffer.writeln(extraInfo);
        break;
      case ShareCardType.stickyFingers:
        buffer.writeln('쫀드기 챌린지 $title');
        if (extraInfo != null) buffer.writeln(extraInfo);
        break;
      case ShareCardType.penaltyRoulette:
        buffer.writeln('복불복 룰렛 결과');
        buffer.writeln(title);
        break;
      case ShareCardType.coupleStats:
        buffer.writeln(title);
        if (extraInfo != null) buffer.writeln(extraInfo);
        break;
    }

    buffer.writeln();
    buffer.writeln(getHashtags(type));

    return buffer.toString();
  }
}

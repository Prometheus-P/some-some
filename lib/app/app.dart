import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/deep_links/deep_link_service.dart';
import '../design_system/tds.dart';
import '../features/intro/intro_screen.dart';
import '../features/sticky_fingers/sticky_fingers_screen.dart';
import '../features/soul_sync/soul_sync_screen.dart';
import '../features/penalty_roulette/penalty_roulette_screen.dart';
import '../features/couple_mode/couple_mode_screen.dart';

class ThumbSomeApp extends StatefulWidget {
  const ThumbSomeApp({super.key});

  @override
  State<ThumbSomeApp> createState() => _ThumbSomeAppState();
}

class _ThumbSomeAppState extends State<ThumbSomeApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final DeepLinkService _deepLinkService = DeepLinkService.instance;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  Future<void> _initializeDeepLinks() async {
    await _deepLinkService.initialize();

    // 초기 링크가 있으면 처리
    if (_deepLinkService.initialLink != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLink(_deepLinkService.initialLink!);
      });
    }

    // 앱 실행 중 링크 수신 처리
    _deepLinkService.linkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(DeepLinkData data) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    switch (data.type) {
      case DeepLinkType.home:
        navigator.popUntil((route) => route.isFirst);
        break;
      case DeepLinkType.stickyFingers:
        navigator.push(
          MaterialPageRoute(builder: (_) => const StickyFingersScreen()),
        );
        break;
      case DeepLinkType.soulSync:
        navigator.push(
          MaterialPageRoute(builder: (_) => const SoulSyncScreen()),
        );
        break;
      case DeepLinkType.penaltyRoulette:
        navigator.push(
          MaterialPageRoute(builder: (_) => const PenaltyRouletteScreen()),
        );
        break;
      case DeepLinkType.coupleMode:
        navigator.push(
          MaterialPageRoute(builder: (_) => const CoupleModeScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Thumb Some',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        fontFamily: 'Pretendard',
      ),
      home: const IntroScreen(),
    );
  }
}

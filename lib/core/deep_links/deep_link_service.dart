import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// 딥링크 타입
enum DeepLinkType {
  home,
  stickyFingers,
  soulSync,
  penaltyRoulette,
  coupleMode,
}

/// 딥링크 데이터
class DeepLinkData {
  final DeepLinkType type;
  final Map<String, String> params;

  const DeepLinkData({
    required this.type,
    this.params = const {},
  });
}

/// 딥링크 서비스
///
/// URL 스킴: somesome://
///
/// 지원 경로:
/// - somesome://home - 홈 화면
/// - somesome://sticky-fingers - 쫀드기 챌린지
/// - somesome://soul-sync - 이심전심 텔레파시
/// - somesome://penalty-roulette - 복불복 룰렛
/// - somesome://couple - 커플 모드
class DeepLinkService {
  static DeepLinkService? _instance;
  static DeepLinkService get instance => _instance ??= DeepLinkService._();

  DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  final _linkController = StreamController<DeepLinkData>.broadcast();

  Stream<DeepLinkData> get linkStream => _linkController.stream;
  DeepLinkData? _initialLink;
  DeepLinkData? get initialLink => _initialLink;

  bool _initialized = false;

  /// 초기화
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 앱이 링크로 실행된 경우 초기 링크 처리
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _initialLink = _parseUri(initialUri);
        debugPrint('DeepLink: Initial link - $initialUri');
      }
    } catch (e) {
      debugPrint('DeepLink: Error getting initial link - $e');
    }

    // 앱 실행 중 링크 수신 처리
    _appLinks.uriLinkStream.listen((uri) {
      final data = _parseUri(uri);
      if (data != null) {
        _linkController.add(data);
        debugPrint('DeepLink: Received link - $uri');
      }
    });
  }

  /// URI 파싱
  DeepLinkData? _parseUri(Uri uri) {
    // somesome:// 스킴 확인
    if (uri.scheme != 'somesome') {
      // HTTPS 유니버설 링크도 지원
      if (uri.scheme != 'https' || uri.host != 'somesome.app') {
        return null;
      }
    }

    final path = uri.path.isEmpty ? uri.host : uri.path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    switch (cleanPath) {
      case '':
      case 'home':
        return const DeepLinkData(type: DeepLinkType.home);
      case 'sticky-fingers':
      case 'stickyfingers':
        return DeepLinkData(
          type: DeepLinkType.stickyFingers,
          params: Map.fromEntries(uri.queryParameters.entries),
        );
      case 'soul-sync':
      case 'soulsync':
        return DeepLinkData(
          type: DeepLinkType.soulSync,
          params: Map.fromEntries(uri.queryParameters.entries),
        );
      case 'penalty-roulette':
      case 'penaltyroulette':
      case 'roulette':
        return DeepLinkData(
          type: DeepLinkType.penaltyRoulette,
          params: Map.fromEntries(uri.queryParameters.entries),
        );
      case 'couple':
      case 'couple-mode':
        return DeepLinkData(
          type: DeepLinkType.coupleMode,
          params: Map.fromEntries(uri.queryParameters.entries),
        );
      default:
        debugPrint('DeepLink: Unknown path - $cleanPath');
        return const DeepLinkData(type: DeepLinkType.home);
    }
  }

  /// 공유용 딥링크 URL 생성
  static String createShareUrl(DeepLinkType type, {Map<String, String>? params}) {
    String path;
    switch (type) {
      case DeepLinkType.home:
        path = '';
        break;
      case DeepLinkType.stickyFingers:
        path = 'sticky-fingers';
        break;
      case DeepLinkType.soulSync:
        path = 'soul-sync';
        break;
      case DeepLinkType.penaltyRoulette:
        path = 'penalty-roulette';
        break;
      case DeepLinkType.coupleMode:
        path = 'couple';
        break;
    }

    final uri = Uri(
      scheme: 'https',
      host: 'somesome.app',
      path: path,
      queryParameters: params?.isNotEmpty == true ? params : null,
    );

    return uri.toString();
  }

  /// 앱 스토어 폴백 URL
  static String get appStoreUrl {
    // TODO: 실제 앱스토어 URL로 교체
    return 'https://somesome.app/download';
  }

  void dispose() {
    _linkController.close();
  }
}

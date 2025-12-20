import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._(); // Private constructor

  static final instance = RemoteConfigService._();

  final _remoteConfig = FirebaseRemoteConfig.instance;

  // C6: Add nullable list for local questions
  List<String>? _localQuestions;

  // Key for the remote config parameter
  static const _soulSyncQuestionsKey = 'soul_sync_questions';

  // T004: Hardcoded default questions as a fallback for remote config
  static const _defaultRemoteQuestions = [
    '첫 데이트는 활동적인 게 좋다',
    '연인 사이에 비밀은 없어야 한다',
    '기념일은 꼭 챙겨야 한다',
    '싸우면 먼저 연락해야 한다',
    '서로의 핸드폰을 볼 수 있어야 한다',
    '데이트 비용은 번갈아 내야 한다',
    '같은 취미가 있어야 한다',
    '자기 전에 통화해야 한다',
    '친구들에게 연애 사실을 알려야 한다',
    '여행은 둘이만 가야 한다',
  ];

  Future<void> init() async {
    // C6: Attempt to load local questions first
    try {
      final jsonString =
          await rootBundle.loadString('assets/packs/local_questions.json');
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      _localQuestions = decoded.map((e) => e.toString()).toList();
      // If local questions are loaded, we don't need to init remote config
      return;
    } catch (e) {
      // Failed to load local questions, proceed with Remote Config
      _localQuestions = null;
    }

    await _remoteConfig.ensureInitialized();
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 5),
    ));

    await _remoteConfig.setDefaults({
      _soulSyncQuestionsKey: jsonEncode(_defaultRemoteQuestions),
    });

    await _remoteConfig.fetchAndActivate();
  }

  List<String> get soulSyncQuestions {
    // C6: Prioritize local questions if they exist
    if (_localQuestions != null && _localQuestions!.isNotEmpty) {
      return _localQuestions!;
    }

    final jsonString = _remoteConfig.getString(_soulSyncQuestionsKey);
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      // If parsing fails, fall back to defaults
      return _defaultRemoteQuestions;
    }
  }
}

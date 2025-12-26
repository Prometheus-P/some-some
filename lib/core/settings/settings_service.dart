import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 게임 난이도
enum GameDifficulty {
  easy(duration: 10.0, speed: 0.8, label: '초급', description: '10초, 느린 속도'),
  medium(duration: 15.0, speed: 1.0, label: '중급', description: '15초, 보통 속도'),
  hard(duration: 20.0, speed: 1.3, label: '고급', description: '20초, 빠른 속도');

  final double duration;
  final double speed;
  final String label;
  final String description;

  const GameDifficulty({
    required this.duration,
    required this.speed,
    required this.label,
    required this.description,
  });
}

/// 설정 관리 서비스
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _difficultyKey = 'difficulty';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';

  SharedPreferences? _prefs;

  // 현재 설정 값
  GameDifficulty _difficulty = GameDifficulty.medium;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  GameDifficulty get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  /// 설정 초기화 (앱 시작 시 호출)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    final difficultyIndex = _prefs?.getInt(_difficultyKey) ?? 1;
    _difficulty = GameDifficulty.values[difficultyIndex.clamp(0, 2)];
    _soundEnabled = _prefs?.getBool(_soundEnabledKey) ?? true;
    _hapticEnabled = _prefs?.getBool(_hapticEnabledKey) ?? true;
    notifyListeners();
  }

  /// 난이도 변경
  Future<void> setDifficulty(GameDifficulty value) async {
    _difficulty = value;
    await _prefs?.setInt(_difficultyKey, value.index);
    notifyListeners();
  }

  /// 사운드 ON/OFF
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs?.setBool(_soundEnabledKey, value);
    notifyListeners();
  }

  /// 햅틱 ON/OFF
  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    await _prefs?.setBool(_hapticEnabledKey, value);
    notifyListeners();
  }
}

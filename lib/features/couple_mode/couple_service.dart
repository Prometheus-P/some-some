import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 커플 모드 데이터 서비스
class CoupleService extends ChangeNotifier {
  static final CoupleService _instance = CoupleService._();
  factory CoupleService() => _instance;
  CoupleService._();

  // Keys
  static const String _firstDateKey = 'couple_first_date';
  static const String _playCountKey = 'couple_play_count';
  static const String _badgesKey = 'couple_badges';
  static const String _partnerNameKey = 'couple_partner_name';
  static const String _myNameKey = 'couple_my_name';

  // State
  DateTime? _firstDate;
  int _playCount = 0;
  List<String> _earnedBadges = [];
  String? _partnerName;
  String? _myName;
  bool _initialized = false;

  // Getters
  DateTime? get firstDate => _firstDate;
  int get playCount => _playCount;
  List<String> get earnedBadges => List.unmodifiable(_earnedBadges);
  String? get partnerName => _partnerName;
  String? get myName => _myName;
  bool get isInitialized => _initialized;
  bool get hasCouple => _firstDate != null;

  /// D-Day 계산 (첫 날부터 며칠째인지)
  int get daysSinceFirst {
    if (_firstDate == null) return 0;
    return DateTime.now().difference(_firstDate!).inDays + 1;
  }

  /// 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load first date
    final firstDateStr = prefs.getString(_firstDateKey);
    if (firstDateStr != null) {
      _firstDate = DateTime.tryParse(firstDateStr);
    }

    // Load play count
    _playCount = prefs.getInt(_playCountKey) ?? 0;

    // Load badges
    _earnedBadges = prefs.getStringList(_badgesKey) ?? [];

    // Load names
    _partnerName = prefs.getString(_partnerNameKey);
    _myName = prefs.getString(_myNameKey);

    _initialized = true;
    notifyListeners();
  }

  /// 커플 시작 (첫 손잡기 날짜 설정)
  Future<void> startCouple({
    required DateTime date,
    String? myName,
    String? partnerName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _firstDate = date;
    await prefs.setString(_firstDateKey, date.toIso8601String());

    if (myName != null) {
      _myName = myName;
      await prefs.setString(_myNameKey, myName);
    }

    if (partnerName != null) {
      _partnerName = partnerName;
      await prefs.setString(_partnerNameKey, partnerName);
    }

    // 첫 번째 뱃지 자동 획득
    await _earnBadge('first_touch');

    notifyListeners();
  }

  /// 플레이 횟수 증가
  Future<void> incrementPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    _playCount++;
    await prefs.setInt(_playCountKey, _playCount);

    // 마일스톤 뱃지 체크
    await _checkMilestoneBadges();

    notifyListeners();
  }

  /// 마일스톤 뱃지 체크
  Future<void> _checkMilestoneBadges() async {
    if (_playCount >= 10 && !_earnedBadges.contains('play_10')) {
      await _earnBadge('play_10');
    }
    if (_playCount >= 50 && !_earnedBadges.contains('play_50')) {
      await _earnBadge('play_50');
    }
    if (_playCount >= 100 && !_earnedBadges.contains('play_100')) {
      await _earnBadge('play_100');
    }
  }

  /// D-Day 뱃지 체크 (앱 실행시 호출)
  Future<void> checkDayBadges() async {
    if (_firstDate == null) return;

    final days = daysSinceFirst;

    if (days >= 7 && !_earnedBadges.contains('day_7')) {
      await _earnBadge('day_7');
    }
    if (days >= 30 && !_earnedBadges.contains('day_30')) {
      await _earnBadge('day_30');
    }
    if (days >= 100 && !_earnedBadges.contains('day_100')) {
      await _earnBadge('day_100');
    }
    if (days >= 365 && !_earnedBadges.contains('day_365')) {
      await _earnBadge('day_365');
    }
  }

  /// 뱃지 획득
  Future<void> _earnBadge(String badgeId) async {
    if (_earnedBadges.contains(badgeId)) return;

    final prefs = await SharedPreferences.getInstance();
    _earnedBadges.add(badgeId);
    await prefs.setStringList(_badgesKey, _earnedBadges);
    notifyListeners();
  }

  /// 이름 업데이트
  Future<void> updateNames({String? myName, String? partnerName}) async {
    final prefs = await SharedPreferences.getInstance();

    if (myName != null) {
      _myName = myName;
      await prefs.setString(_myNameKey, myName);
    }

    if (partnerName != null) {
      _partnerName = partnerName;
      await prefs.setString(_partnerNameKey, partnerName);
    }

    notifyListeners();
  }

  /// 커플 리셋 (주의!)
  Future<void> resetCouple() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_firstDateKey);
    await prefs.remove(_playCountKey);
    await prefs.remove(_badgesKey);
    await prefs.remove(_partnerNameKey);
    await prefs.remove(_myNameKey);

    _firstDate = null;
    _playCount = 0;
    _earnedBadges = [];
    _partnerName = null;
    _myName = null;

    notifyListeners();
  }
}

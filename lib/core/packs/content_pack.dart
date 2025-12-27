/// 콘텐츠 팩 추상 클래스
/// Soul Sync 질문, 벌칙 등 동적 콘텐츠를 위한 기반 클래스
abstract class ContentPack {
  /// 팩 고유 ID
  String get id;

  /// 팩 이름 (UI 표시용)
  String get name;

  /// 팩 설명
  String get description;

  /// 프리미엄 여부
  bool get isPremium;

  /// 아이콘 (이모지)
  String get icon;
}

/// Soul Sync 질문 데이터
class SoulSyncQuestion {
  final String id;
  final String question;
  final String category;

  const SoulSyncQuestion({
    required this.id,
    required this.question,
    this.category = 'general',
  });
}

/// Soul Sync 질문 팩
abstract class SoulSyncPack extends ContentPack {
  /// 질문 목록
  List<SoulSyncQuestion> get questions;

  /// 랜덤하게 n개 질문 선택
  List<SoulSyncQuestion> getRandomQuestions(int count) {
    final shuffled = List<SoulSyncQuestion>.from(questions)..shuffle();
    return shuffled.take(count).toList();
  }
}

/// 벌칙 데이터 (향후 복불복 룰렛용)
class PenaltyItem {
  final String id;
  final String text;
  final int intensity; // 1-5 (약함-강함)

  const PenaltyItem({
    required this.id,
    required this.text,
    this.intensity = 3,
  });
}

/// 벌칙 팩 (향후 확장용)
abstract class PenaltyPack extends ContentPack {
  List<PenaltyItem> get penalties;
}

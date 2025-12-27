import 'dart:ui';

/// 커플 뱃지 데이터
class CoupleBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final BadgeCategory category;

  const CoupleBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.category,
  });
}

enum BadgeCategory {
  milestone,  // 첫 시작, 기념일
  play,       // 플레이 횟수
  special,    // 특별 이벤트
}

/// 모든 뱃지 정의
const Map<String, CoupleBadge> allBadges = {
  // 마일스톤 뱃지
  'first_touch': CoupleBadge(
    id: 'first_touch',
    name: '첫 손잡기',
    description: '우리의 시작을 기념해요',
    emoji: '💕',
    color: Color(0xFFFF6B9D),
    category: BadgeCategory.milestone,
  ),
  'day_7': CoupleBadge(
    id: 'day_7',
    name: '일주일 커플',
    description: '함께한 지 7일째!',
    emoji: '🌟',
    color: Color(0xFFFFD93D),
    category: BadgeCategory.milestone,
  ),
  'day_30': CoupleBadge(
    id: 'day_30',
    name: '한 달 커플',
    description: '함께한 지 30일째!',
    emoji: '🌙',
    color: Color(0xFF6C5CE7),
    category: BadgeCategory.milestone,
  ),
  'day_100': CoupleBadge(
    id: 'day_100',
    name: '100일 커플',
    description: '백일의 사랑!',
    emoji: '💯',
    color: Color(0xFFE84393),
    category: BadgeCategory.milestone,
  ),
  'day_365': CoupleBadge(
    id: 'day_365',
    name: '1년 커플',
    description: '사랑은 계속된다!',
    emoji: '💎',
    color: Color(0xFF00CEC9),
    category: BadgeCategory.milestone,
  ),

  // 플레이 횟수 뱃지
  'play_10': CoupleBadge(
    id: 'play_10',
    name: '썸썸 루키',
    description: '10번 플레이 달성!',
    emoji: '🎮',
    color: Color(0xFF74B9FF),
    category: BadgeCategory.play,
  ),
  'play_50': CoupleBadge(
    id: 'play_50',
    name: '썸썸 프로',
    description: '50번 플레이 달성!',
    emoji: '🏆',
    color: Color(0xFFFDAA5D),
    category: BadgeCategory.play,
  ),
  'play_100': CoupleBadge(
    id: 'play_100',
    name: '썸썸 마스터',
    description: '100번 플레이 달성!',
    emoji: '👑',
    color: Color(0xFFFF7675),
    category: BadgeCategory.play,
  ),

  // 특별 뱃지 (향후 확장용)
  'perfect_sync': CoupleBadge(
    id: 'perfect_sync',
    name: '완벽한 호흡',
    description: '이심전심 100% 달성!',
    emoji: '✨',
    color: Color(0xFFFD79A8),
    category: BadgeCategory.special,
  ),
  'sticky_master': CoupleBadge(
    id: 'sticky_master',
    name: '쫀득 장인',
    description: '쫀드기 챌린지 10연승!',
    emoji: '🔥',
    color: Color(0xFFE17055),
    category: BadgeCategory.special,
  ),
};

/// ID로 뱃지 가져오기
CoupleBadge? getBadgeById(String id) => allBadges[id];

/// 카테고리별 뱃지 가져오기
List<CoupleBadge> getBadgesByCategory(BadgeCategory category) {
  return allBadges.values.where((b) => b.category == category).toList();
}

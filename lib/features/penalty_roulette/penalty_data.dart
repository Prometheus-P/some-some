import 'dart:ui';

/// 벌칙 아이템 데이터
class PenaltyItem {
  final String id;
  final String text;
  final String emoji;
  final int intensity; // 1-5 (약함-강함)
  final Color color;

  const PenaltyItem({
    required this.id,
    required this.text,
    required this.emoji,
    this.intensity = 3,
    required this.color,
  });
}

/// 기본 벌칙 20개
const List<PenaltyItem> defaultPenalties = [
  // 가벼운 스킨십 (intensity 1-2)
  PenaltyItem(
    id: 'p01',
    text: '손바닥 하이파이브',
    emoji: '✋',
    intensity: 1,
    color: Color(0xFFFF6B6B),
  ),
  PenaltyItem(
    id: 'p02',
    text: '새끼손가락 걸기',
    emoji: '🤙',
    intensity: 1,
    color: Color(0xFF4ECDC4),
  ),
  PenaltyItem(
    id: 'p03',
    text: '주먹 인사',
    emoji: '👊',
    intensity: 1,
    color: Color(0xFFFFE66D),
  ),
  PenaltyItem(
    id: 'p04',
    text: '어깨 토닥토닥',
    emoji: '👋',
    intensity: 2,
    color: Color(0xFF95E1D3),
  ),

  // 눈 마주치기 (intensity 2-3)
  PenaltyItem(
    id: 'p05',
    text: '10초 눈 마주치기',
    emoji: '👀',
    intensity: 2,
    color: Color(0xFFF38181),
  ),
  PenaltyItem(
    id: 'p06',
    text: '눈싸움 (먼저 웃으면 짐)',
    emoji: '😐',
    intensity: 2,
    color: Color(0xFFAA96DA),
  ),
  PenaltyItem(
    id: 'p07',
    text: '윙크 3번 하기',
    emoji: '😉',
    intensity: 2,
    color: Color(0xFFFFCCCB),
  ),

  // 중간 스킨십 (intensity 3)
  PenaltyItem(
    id: 'p08',
    text: '손잡고 10초 버티기',
    emoji: '🤝',
    intensity: 3,
    color: Color(0xFFFF9F1C),
  ),
  PenaltyItem(
    id: 'p09',
    text: '상대방 볼 터치',
    emoji: '😊',
    intensity: 3,
    color: Color(0xFFE84A5F),
  ),
  PenaltyItem(
    id: 'p10',
    text: '머리 쓰다듬기',
    emoji: '🥰',
    intensity: 3,
    color: Color(0xFF2A363B),
  ),
  PenaltyItem(
    id: 'p11',
    text: '손등에 하트 그리기',
    emoji: '💕',
    intensity: 3,
    color: Color(0xFFFF69B4),
  ),
  PenaltyItem(
    id: 'p12',
    text: '손가락 깍지끼기',
    emoji: '🫶',
    intensity: 3,
    color: Color(0xFFFFA07A),
  ),

  // 말하기/행동 (intensity 2-3)
  PenaltyItem(
    id: 'p13',
    text: '칭찬 3가지 말하기',
    emoji: '💬',
    intensity: 2,
    color: Color(0xFF6C5CE7),
  ),
  PenaltyItem(
    id: 'p14',
    text: '첫인상 솔직히 말하기',
    emoji: '🗣️',
    intensity: 3,
    color: Color(0xFF00B894),
  ),
  PenaltyItem(
    id: 'p15',
    text: '애교 부리기',
    emoji: '🥺',
    intensity: 3,
    color: Color(0xFFFF85A2),
  ),
  PenaltyItem(
    id: 'p16',
    text: '상대방 별명 지어주기',
    emoji: '📝',
    intensity: 2,
    color: Color(0xFF74B9FF),
  ),

  // 조금 쎈 것 (intensity 4)
  PenaltyItem(
    id: 'p17',
    text: '이마 콕 찍기',
    emoji: '👆',
    intensity: 4,
    color: Color(0xFFD63031),
  ),
  PenaltyItem(
    id: 'p18',
    text: '팔짱 끼고 셀카',
    emoji: '📸',
    intensity: 4,
    color: Color(0xFFE17055),
  ),
  PenaltyItem(
    id: 'p19',
    text: '볼에 손 대고 5초',
    emoji: '☺️',
    intensity: 4,
    color: Color(0xFFFF7675),
  ),
  PenaltyItem(
    id: 'p20',
    text: '심장 소리 들려주기',
    emoji: '💓',
    intensity: 4,
    color: Color(0xFFE84393),
  ),
];

import '../content_pack.dart';

/// 기본 Soul Sync 질문 팩 (무료, 50개 질문)
class DefaultSoulSyncPack extends SoulSyncPack {
  @override
  String get id => 'default';

  @override
  String get name => '기본 질문팩';

  @override
  String get description => '썸 타는 두 사람을 위한 50가지 질문';

  @override
  bool get isPremium => false;

  @override
  String get icon => '💕';

  @override
  List<SoulSyncQuestion> get questions => _defaultQuestions;
}

const List<SoulSyncQuestion> _defaultQuestions = [
  // 취향 & 선호 (15개)
  SoulSyncQuestion(
    id: 'd01',
    question: '아침형 인간이다',
    category: 'lifestyle',
  ),
  SoulSyncQuestion(
    id: 'd02',
    question: '계획을 세우는 편이다',
    category: 'personality',
  ),
  SoulSyncQuestion(
    id: 'd03',
    question: '매운 음식을 좋아한다',
    category: 'food',
  ),
  SoulSyncQuestion(
    id: 'd04',
    question: '집에서 쉬는 게 더 좋다',
    category: 'lifestyle',
  ),
  SoulSyncQuestion(
    id: 'd05',
    question: '커피보다 차를 선호한다',
    category: 'food',
  ),
  SoulSyncQuestion(
    id: 'd06',
    question: '영화보다 드라마가 좋다',
    category: 'entertainment',
  ),
  SoulSyncQuestion(
    id: 'd07',
    question: '반려동물을 키우고 싶다',
    category: 'lifestyle',
  ),
  SoulSyncQuestion(
    id: 'd08',
    question: '도시보다 자연이 좋다',
    category: 'lifestyle',
  ),
  SoulSyncQuestion(
    id: 'd09',
    question: '책 읽는 것을 좋아한다',
    category: 'hobby',
  ),
  SoulSyncQuestion(
    id: 'd10',
    question: '운동을 규칙적으로 한다',
    category: 'lifestyle',
  ),
  SoulSyncQuestion(
    id: 'd11',
    question: '단 음식보다 짠 음식 파다',
    category: 'food',
  ),
  SoulSyncQuestion(
    id: 'd12',
    question: '혼자 여행도 좋다',
    category: 'travel',
  ),
  SoulSyncQuestion(
    id: 'd13',
    question: '새로운 음식 도전을 좋아한다',
    category: 'food',
  ),
  SoulSyncQuestion(
    id: 'd14',
    question: '정리정돈을 잘하는 편이다',
    category: 'lifestyle',
  ),
  SoulSyncQuestion(
    id: 'd15',
    question: '음악 없이는 못 산다',
    category: 'hobby',
  ),

  // 연애 & 관계 (15개)
  SoulSyncQuestion(
    id: 'd16',
    question: '매일 연락하는 게 좋다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd17',
    question: '스킨십에 적극적인 편이다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd18',
    question: '질투는 사랑의 표현이다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd19',
    question: '기념일을 중요하게 생각한다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd20',
    question: '애인에게 비밀은 없어야 한다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd21',
    question: '데이트 비용은 나눠 내는 게 맞다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd22',
    question: '연인의 친구들과도 친해지고 싶다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd23',
    question: '애인이 이성친구 만나는 건 괜찮다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd24',
    question: '싸우면 바로 풀어야 한다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd25',
    question: '서프라이즈를 좋아한다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd26',
    question: '애정표현은 적극적으로!',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd27',
    question: '결혼 전 동거는 필수다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd28',
    question: '연애할 때 친구도 중요하다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd29',
    question: '장거리 연애도 할 수 있다',
    category: 'relationship',
  ),
  SoulSyncQuestion(
    id: 'd30',
    question: '첫인상이 중요하다',
    category: 'relationship',
  ),

  // 가치관 & 미래 (10개)
  SoulSyncQuestion(
    id: 'd31',
    question: '돈보다 시간이 더 중요하다',
    category: 'values',
  ),
  SoulSyncQuestion(
    id: 'd32',
    question: '안정적인 삶을 원한다',
    category: 'values',
  ),
  SoulSyncQuestion(
    id: 'd33',
    question: '가족과 자주 연락한다',
    category: 'family',
  ),
  SoulSyncQuestion(
    id: 'd34',
    question: '아이를 갖고 싶다',
    category: 'future',
  ),
  SoulSyncQuestion(
    id: 'd35',
    question: '해외에서 살아보고 싶다',
    category: 'future',
  ),
  SoulSyncQuestion(
    id: 'd36',
    question: '성공의 기준은 행복이다',
    category: 'values',
  ),
  SoulSyncQuestion(
    id: 'd37',
    question: '일과 삶의 균형이 중요하다',
    category: 'values',
  ),
  SoulSyncQuestion(
    id: 'd38',
    question: '종교가 있다',
    category: 'values',
  ),
  SoulSyncQuestion(
    id: 'd39',
    question: '노후 준비를 하고 있다',
    category: 'future',
  ),
  SoulSyncQuestion(
    id: 'd40',
    question: '창업에 관심이 있다',
    category: 'future',
  ),

  // 재미 & 성격 (10개)
  SoulSyncQuestion(
    id: 'd41',
    question: '귀신/UFO를 믿는다',
    category: 'fun',
  ),
  SoulSyncQuestion(
    id: 'd42',
    question: '길치인 편이다',
    category: 'personality',
  ),
  SoulSyncQuestion(
    id: 'd43',
    question: '눈물이 많은 편이다',
    category: 'personality',
  ),
  SoulSyncQuestion(
    id: 'd44',
    question: '결정장애가 있다',
    category: 'personality',
  ),
  SoulSyncQuestion(
    id: 'd45',
    question: '늦잠 자는 게 행복이다',
    category: 'lifestyle',
  ),
  SoulSyncQuestion(
    id: 'd46',
    question: '술자리를 좋아한다',
    category: 'social',
  ),
  SoulSyncQuestion(
    id: 'd47',
    question: '첫사랑을 아직 기억한다',
    category: 'fun',
  ),
  SoulSyncQuestion(
    id: 'd48',
    question: '인스타 스토리를 자주 올린다',
    category: 'social',
  ),
  SoulSyncQuestion(
    id: 'd49',
    question: '게임을 좋아한다',
    category: 'hobby',
  ),
  SoulSyncQuestion(
    id: 'd50',
    question: '로또 1등 되면 일 그만둘 거다',
    category: 'fun',
  ),
];

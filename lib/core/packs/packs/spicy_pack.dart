import '../content_pack.dart';

/// 스파이시 질문 팩 (프리미엄)
///
/// 더 대담하고 로맨틱한 질문 50개
class SpicySoulSyncPack extends SoulSyncPack {
  @override
  String get id => 'spicy_soul_sync';

  @override
  String get name => '스파이시 질문';

  @override
  String get description => '더 대담한 질문으로 분위기 UP! 🔥';

  @override
  bool get isPremium => true;

  @override
  String get icon => '🔥';

  @override
  List<SoulSyncQuestion> get questions => _spicyQuestions;
}

const List<SoulSyncQuestion> _spicyQuestions = [
  // 스킨십 & 로맨스 (1-15)
  SoulSyncQuestion(
    id: 'spicy_1',
    question: '첫 키스는 분위기가 무르익었을 때?',
    category: '스킨십',
  ),
  SoulSyncQuestion(
    id: 'spicy_2',
    question: '손잡기 먼저 시도하는 편?',
    category: '스킨십',
  ),
  SoulSyncQuestion(
    id: 'spicy_3',
    question: '백허그 좋아해?',
    category: '스킨십',
  ),
  SoulSyncQuestion(
    id: 'spicy_4',
    question: '뽀뽀는 자주 하고 싶은 편?',
    category: '스킨십',
  ),
  SoulSyncQuestion(
    id: 'spicy_5',
    question: '공공장소 스킨십 괜찮아?',
    category: '스킨십',
  ),
  SoulSyncQuestion(
    id: 'spicy_6',
    question: '애교 부리는 거 좋아해?',
    category: '로맨스',
  ),
  SoulSyncQuestion(
    id: 'spicy_7',
    question: '이름 대신 애칭 부르고 싶어?',
    category: '로맨스',
  ),
  SoulSyncQuestion(
    id: 'spicy_8',
    question: '깜짝 선물 좋아해?',
    category: '로맨스',
  ),
  SoulSyncQuestion(
    id: 'spicy_9',
    question: '로맨틱한 편지 쓸 수 있어?',
    category: '로맨스',
  ),
  SoulSyncQuestion(
    id: 'spicy_10',
    question: '기념일 꼭 챙기는 타입?',
    category: '로맨스',
  ),
  SoulSyncQuestion(
    id: 'spicy_11',
    question: '집순이/집돌이 데이트도 좋아?',
    category: '데이트',
  ),
  SoulSyncQuestion(
    id: 'spicy_12',
    question: '여행 가면 같은 방 쓸 수 있어?',
    category: '데이트',
  ),
  SoulSyncQuestion(
    id: 'spicy_13',
    question: '술 마시면 더 솔직해져?',
    category: '성격',
  ),
  SoulSyncQuestion(
    id: 'spicy_14',
    question: '질투심 있는 편?',
    category: '성격',
  ),
  SoulSyncQuestion(
    id: 'spicy_15',
    question: '이성 친구 많아도 괜찮아?',
    category: '관계',
  ),

  // 관계 & 미래 (16-30)
  SoulSyncQuestion(
    id: 'spicy_16',
    question: '동거 생각 있어?',
    category: '미래',
  ),
  SoulSyncQuestion(
    id: 'spicy_17',
    question: '결혼 생각 있어?',
    category: '미래',
  ),
  SoulSyncQuestion(
    id: 'spicy_18',
    question: '아이 갖고 싶어?',
    category: '미래',
  ),
  SoulSyncQuestion(
    id: 'spicy_19',
    question: '부모님 소개 빨리 해도 괜찮아?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_20',
    question: 'SNS에 연애 공개해도 돼?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_21',
    question: '커플 아이템 좋아해?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_22',
    question: '매일 연락 해야 해?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_23',
    question: '자기 전 통화 필수?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_24',
    question: '싸우면 먼저 화해해?',
    category: '성격',
  ),
  SoulSyncQuestion(
    id: 'spicy_25',
    question: '상대 핸드폰 볼 수 있어?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_26',
    question: '비밀 없이 지낼 수 있어?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_27',
    question: '취미 같이 해야 해?',
    category: '라이프스타일',
  ),
  SoulSyncQuestion(
    id: 'spicy_28',
    question: '돈 관리 같이 해도 돼?',
    category: '미래',
  ),
  SoulSyncQuestion(
    id: 'spicy_29',
    question: '장거리 연애 할 수 있어?',
    category: '관계',
  ),
  SoulSyncQuestion(
    id: 'spicy_30',
    question: '상대 친구들이랑도 친해지고 싶어?',
    category: '관계',
  ),

  // 취향 & 솔직함 (31-50)
  SoulSyncQuestion(
    id: 'spicy_31',
    question: '첫인상에서 외모 중요해?',
    category: '솔직',
  ),
  SoulSyncQuestion(
    id: 'spicy_32',
    question: '전 연인 얘기해도 괜찮아?',
    category: '솔직',
  ),
  SoulSyncQuestion(
    id: 'spicy_33',
    question: '몸무게 물어봐도 돼?',
    category: '솔직',
  ),
  SoulSyncQuestion(
    id: 'spicy_34',
    question: '성형 해도 괜찮아?',
    category: '솔직',
  ),
  SoulSyncQuestion(
    id: 'spicy_35',
    question: '연봉 공개할 수 있어?',
    category: '솔직',
  ),
  SoulSyncQuestion(
    id: 'spicy_36',
    question: '잠자리 대화 할 수 있어?',
    category: '솔직',
  ),
  SoulSyncQuestion(
    id: 'spicy_37',
    question: '술자리에서 춤 출 수 있어?',
    category: '성격',
  ),
  SoulSyncQuestion(
    id: 'spicy_38',
    question: '노래방 가면 열정적으로 불러?',
    category: '성격',
  ),
  SoulSyncQuestion(
    id: 'spicy_39',
    question: '새벽 감성 있어?',
    category: '성격',
  ),
  SoulSyncQuestion(
    id: 'spicy_40',
    question: '롤러코스터 같이 탈 수 있어?',
    category: '데이트',
  ),
  SoulSyncQuestion(
    id: 'spicy_41',
    question: '무서운 영화 보면서 붙어있고 싶어?',
    category: '데이트',
  ),
  SoulSyncQuestion(
    id: 'spicy_42',
    question: '드라이브 데이트 좋아해?',
    category: '데이트',
  ),
  SoulSyncQuestion(
    id: 'spicy_43',
    question: '캠핑 가서 불 앞에서 얘기하고 싶어?',
    category: '데이트',
  ),
  SoulSyncQuestion(
    id: 'spicy_44',
    question: '새벽 편의점 데이트 해봤어?',
    category: '데이트',
  ),
  SoulSyncQuestion(
    id: 'spicy_45',
    question: '비 오는 날 우산 같이 써도 돼?',
    category: '로맨스',
  ),
  SoulSyncQuestion(
    id: 'spicy_46',
    question: '눈 오면 같이 걷고 싶어?',
    category: '로맨스',
  ),
  SoulSyncQuestion(
    id: 'spicy_47',
    question: '요리 같이 하고 싶어?',
    category: '라이프스타일',
  ),
  SoulSyncQuestion(
    id: 'spicy_48',
    question: '아침에 일어나면 뽀뽀해도 돼?',
    category: '스킨십',
  ),
  SoulSyncQuestion(
    id: 'spicy_49',
    question: '잠들기 전에 안아줘도 돼?',
    category: '스킨십',
  ),
  SoulSyncQuestion(
    id: 'spicy_50',
    question: '평생 같이 있어도 괜찮겠어?',
    category: '미래',
  ),
];

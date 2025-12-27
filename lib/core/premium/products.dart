/// 인앱 구매 상품 정의
///
/// App Store Connect / Google Play Console에서 동일한 ID로 상품 등록 필요

/// 프리미엄 상품 ID
class ProductIds {
  ProductIds._();

  /// 프리미엄 업그레이드 (일회성 구매)
  static const String premiumUpgrade = 'com.prometheusp.somesome.premium';

  /// 스파이시 질문 팩 (일회성 구매)
  static const String spicyPack = 'com.prometheusp.somesome.spicy_pack';

  /// 커플 테마 팩 (일회성 구매)
  static const String couplePack = 'com.prometheusp.somesome.couple_pack';

  /// 모든 상품 ID 목록
  static const Set<String> all = {
    premiumUpgrade,
    spicyPack,
    couplePack,
  };

  /// 비소모성 상품 (한 번 구매하면 영구 소유)
  static const Set<String> nonConsumables = {
    premiumUpgrade,
    spicyPack,
    couplePack,
  };
}

/// 프리미엄 혜택 정보
class PremiumBenefits {
  PremiumBenefits._();

  /// 프리미엄 혜택 목록
  static const List<PremiumBenefit> benefits = [
    PremiumBenefit(
      icon: '🔥',
      title: '스파이시 질문 50개',
      description: '더 대담한 질문으로 분위기 UP!',
    ),
    PremiumBenefit(
      icon: '🎰',
      title: '프리미엄 벌칙 20개',
      description: '더 재미있는 벌칙 모음',
    ),
    PremiumBenefit(
      icon: '🎨',
      title: '커스텀 캐릭터 5종',
      description: '쫀드기 게임 캐릭터 변경',
    ),
    PremiumBenefit(
      icon: '💎',
      title: '특별 뱃지',
      description: '프리미엄 전용 뱃지 해금',
    ),
  ];
}

/// 프리미엄 혜택 데이터
class PremiumBenefit {
  final String icon;
  final String title;
  final String description;

  const PremiumBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 상품 가격 정보 (표시용, 실제 가격은 스토어에서 가져옴)
class ProductPrices {
  ProductPrices._();

  static const String premiumUpgrade = '₩3,900';
  static const String spicyPack = '₩1,900';
  static const String couplePack = '₩1,900';
}

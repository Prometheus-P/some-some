import '../premium/premium_service.dart';
import 'content_pack.dart';
import 'packs/default_pack.dart';
import 'packs/spicy_pack.dart';

/// 콘텐츠 팩 로더 서비스
/// 싱글톤 패턴으로 전역에서 팩 접근 가능
class PackLoader {
  PackLoader._();
  static final PackLoader instance = PackLoader._();

  final PremiumService _premiumService = PremiumService.instance;

  /// 등록된 Soul Sync 팩들
  final List<SoulSyncPack> _soulSyncPacks = [];

  /// 등록된 벌칙 팩들 (향후 확장용)
  final List<PenaltyPack> _penaltyPacks = [];

  /// 초기화 여부
  bool _initialized = false;

  /// 초기화 - 앱 시작 시 호출
  Future<void> initialize() async {
    if (_initialized) return;

    // Premium 서비스 초기화
    await _premiumService.initialize();

    // 기본 팩 등록
    _soulSyncPacks.add(DefaultSoulSyncPack());

    // 스파이시 팩 등록 (프리미엄)
    _soulSyncPacks.add(SpicySoulSyncPack());

    _initialized = true;
  }

  /// 사용 가능한 모든 Soul Sync 팩
  List<SoulSyncPack> get soulSyncPacks => List.unmodifiable(_soulSyncPacks);

  /// 무료 Soul Sync 팩만
  List<SoulSyncPack> get freeSoulSyncPacks =>
      _soulSyncPacks.where((p) => !p.isPremium).toList();

  /// 프리미엄 Soul Sync 팩만
  List<SoulSyncPack> get premiumSoulSyncPacks =>
      _soulSyncPacks.where((p) => p.isPremium).toList();

  /// 사용자가 접근 가능한 팩들
  List<SoulSyncPack> get availableSoulSyncPacks {
    return _soulSyncPacks.where((pack) {
      if (!pack.isPremium) return true;
      return _premiumService.hasSpicyPack;
    }).toList();
  }

  /// ID로 Soul Sync 팩 찾기
  SoulSyncPack? getSoulSyncPack(String id) {
    try {
      return _soulSyncPacks.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 기본 Soul Sync 팩 (항상 존재)
  SoulSyncPack get defaultSoulSyncPack {
    return _soulSyncPacks.firstWhere(
      (p) => p.id == 'default',
      orElse: () => DefaultSoulSyncPack(),
    );
  }

  /// 스파이시 팩 (프리미엄)
  SoulSyncPack? get spicySoulSyncPack {
    if (!_premiumService.hasSpicyPack) return null;
    try {
      return _soulSyncPacks.firstWhere((p) => p.id == 'spicy_soul_sync');
    } catch (_) {
      return null;
    }
  }

  /// 팩이 잠금 해제되었는지 확인
  bool isPackUnlocked(String packId) {
    final pack = getSoulSyncPack(packId);
    if (pack == null) return false;
    if (!pack.isPremium) return true;
    return _premiumService.hasSpicyPack;
  }

  /// 벌칙 팩 관련 (향후 확장용)
  List<PenaltyPack> get penaltyPacks => List.unmodifiable(_penaltyPacks);

  /// 프리미엄 팩 등록 (구매 후 호출)
  void registerPack(ContentPack pack) {
    if (pack is SoulSyncPack && !_soulSyncPacks.any((p) => p.id == pack.id)) {
      _soulSyncPacks.add(pack);
    } else if (pack is PenaltyPack &&
        !_penaltyPacks.any((p) => p.id == pack.id)) {
      _penaltyPacks.add(pack);
    }
  }
}

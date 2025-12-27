import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'products.dart';

/// 프리미엄 상태 관리 서비스
///
/// 사용자의 프리미엄 구매 상태를 관리하고 저장합니다.
class PremiumService extends ChangeNotifier {
  static PremiumService? _instance;
  static PremiumService get instance => _instance ??= PremiumService._();

  PremiumService._();

  // Storage keys
  static const String _premiumKey = 'is_premium';
  static const String _spicyPackKey = 'has_spicy_pack';
  static const String _couplePackKey = 'has_couple_pack';
  static const String _purchasedProductsKey = 'purchased_products';

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Premium states
  bool _isPremium = false;
  bool _hasSpicyPack = false;
  bool _hasCouplePack = false;
  final Set<String> _purchasedProducts = {};

  // Getters
  bool get isPremium => _isPremium;
  bool get hasSpicyPack => _hasSpicyPack || _isPremium;
  bool get hasCouplePack => _hasCouplePack || _isPremium;
  bool get isInitialized => _isInitialized;
  Set<String> get purchasedProducts => Set.unmodifiable(_purchasedProducts);

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadPurchases();
    _isInitialized = true;
    notifyListeners();
  }

  /// 저장된 구매 정보 로드
  Future<void> _loadPurchases() async {
    _isPremium = _prefs?.getBool(_premiumKey) ?? false;
    _hasSpicyPack = _prefs?.getBool(_spicyPackKey) ?? false;
    _hasCouplePack = _prefs?.getBool(_couplePackKey) ?? false;

    final savedProducts = _prefs?.getStringList(_purchasedProductsKey) ?? [];
    _purchasedProducts.addAll(savedProducts);
  }

  /// 구매 정보 저장
  Future<void> _savePurchases() async {
    await _prefs?.setBool(_premiumKey, _isPremium);
    await _prefs?.setBool(_spicyPackKey, _hasSpicyPack);
    await _prefs?.setBool(_couplePackKey, _hasCouplePack);
    await _prefs?.setStringList(
      _purchasedProductsKey,
      _purchasedProducts.toList(),
    );
  }

  /// 상품 구매 완료 처리
  Future<void> handlePurchase(String productId) async {
    _purchasedProducts.add(productId);

    switch (productId) {
      case ProductIds.premiumUpgrade:
        _isPremium = true;
        break;
      case ProductIds.spicyPack:
        _hasSpicyPack = true;
        break;
      case ProductIds.couplePack:
        _hasCouplePack = true;
        break;
    }

    await _savePurchases();
    notifyListeners();
  }

  /// 구매 복원 처리
  Future<void> restorePurchases(Set<String> restoredProductIds) async {
    for (final productId in restoredProductIds) {
      await handlePurchase(productId);
    }
  }

  /// 특정 상품 구매 여부 확인
  bool hasPurchased(String productId) {
    if (_isPremium && ProductIds.nonConsumables.contains(productId)) {
      // 프리미엄은 모든 비소모성 상품 포함
      return true;
    }
    return _purchasedProducts.contains(productId);
  }

  /// 프리미엄 혜택 목록 가져오기
  List<PremiumBenefit> get benefits => PremiumBenefits.benefits;

  /// 디버그용: 프리미엄 상태 토글
  Future<void> debugTogglePremium() async {
    if (!kDebugMode) return;

    _isPremium = !_isPremium;
    if (_isPremium) {
      _purchasedProducts.add(ProductIds.premiumUpgrade);
    } else {
      _purchasedProducts.remove(ProductIds.premiumUpgrade);
    }

    await _savePurchases();
    notifyListeners();
  }

  /// 디버그용: 모든 구매 초기화
  Future<void> debugResetPurchases() async {
    if (!kDebugMode) return;

    _isPremium = false;
    _hasSpicyPack = false;
    _hasCouplePack = false;
    _purchasedProducts.clear();

    await _savePurchases();
    notifyListeners();
  }
}

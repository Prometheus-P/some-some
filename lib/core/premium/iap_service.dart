import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'premium_service.dart';
import 'products.dart';

/// 인앱 결제 상태
enum IAPStatus {
  idle,
  loading,
  purchasing,
  restoring,
  success,
  error,
}

/// 인앱 결제 서비스
///
/// App Store / Google Play 인앱 결제를 처리합니다.
class IAPService extends ChangeNotifier {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();

  IAPService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final PremiumService _premiumService = PremiumService.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;
  bool _isAvailable = false;

  IAPStatus _status = IAPStatus.idle;
  String? _errorMessage;
  final Map<String, ProductDetails> _products = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  IAPStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 스토어 사용 가능 여부 확인
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      _isInitialized = true;
      debugPrint('IAPService: Store not available');
      return;
    }

    // 구매 스트림 구독
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('IAPService: Purchase stream error - $error');
      },
    );

    // 상품 정보 로드
    await _loadProducts();

    _isInitialized = true;
    notifyListeners();
  }

  /// 상품 정보 로드
  Future<void> _loadProducts() async {
    _status = IAPStatus.loading;
    notifyListeners();

    try {
      final response = await _inAppPurchase.queryProductDetails(ProductIds.all);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAPService: Products not found - ${response.notFoundIDs}');
      }

      for (final product in response.productDetails) {
        _products[product.id] = product;
      }

      _status = IAPStatus.idle;
    } catch (e) {
      debugPrint('IAPService: Error loading products - $e');
      _status = IAPStatus.error;
      _errorMessage = '상품 정보를 불러올 수 없습니다.';
    }

    notifyListeners();
  }

  /// 구매 업데이트 처리
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  /// 개별 구매 처리
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        _status = IAPStatus.purchasing;
        notifyListeners();
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // 구매/복원 완료
        final valid = await _verifyPurchase(purchase);
        if (valid) {
          await _premiumService.handlePurchase(purchase.productID);
          _status = IAPStatus.success;
        } else {
          _status = IAPStatus.error;
          _errorMessage = '구매 검증에 실패했습니다.';
        }

        // 구매 완료 처리
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        notifyListeners();
        break;

      case PurchaseStatus.error:
        _status = IAPStatus.error;
        _errorMessage = purchase.error?.message ?? '결제 중 오류가 발생했습니다.';
        notifyListeners();
        break;

      case PurchaseStatus.canceled:
        _status = IAPStatus.idle;
        notifyListeners();
        break;
    }
  }

  /// 구매 검증 (서버 검증 필요시 여기에 구현)
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // TODO: 서버 측 영수증 검증 구현
    // 현재는 로컬에서만 검증
    return purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored;
  }

  /// 상품 구매
  Future<bool> buyProduct(String productId) async {
    if (!_isAvailable) {
      _errorMessage = '스토어를 사용할 수 없습니다.';
      _status = IAPStatus.error;
      notifyListeners();
      return false;
    }

    final product = _products[productId];
    if (product == null) {
      _errorMessage = '상품을 찾을 수 없습니다.';
      _status = IAPStatus.error;
      notifyListeners();
      return false;
    }

    _status = IAPStatus.purchasing;
    _errorMessage = null;
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);

      // 비소모성 상품 구매
      if (ProductIds.nonConsumables.contains(productId)) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }

      return true;
    } catch (e) {
      debugPrint('IAPService: Error buying product - $e');
      _status = IAPStatus.error;
      _errorMessage = '결제를 시작할 수 없습니다.';
      notifyListeners();
      return false;
    }
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _errorMessage = '스토어를 사용할 수 없습니다.';
      _status = IAPStatus.error;
      notifyListeners();
      return;
    }

    _status = IAPStatus.restoring;
    _errorMessage = null;
    notifyListeners();

    try {
      await _inAppPurchase.restorePurchases();

      // 복원 완료 후 상태 업데이트
      await Future.delayed(const Duration(seconds: 2));
      if (_status == IAPStatus.restoring) {
        _status = IAPStatus.idle;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('IAPService: Error restoring purchases - $e');
      _status = IAPStatus.error;
      _errorMessage = '구매 복원에 실패했습니다.';
      notifyListeners();
    }
  }

  /// 상품 가격 가져오기
  String? getProductPrice(String productId) {
    return _products[productId]?.price;
  }

  /// 상품 제목 가져오기
  String? getProductTitle(String productId) {
    return _products[productId]?.title;
  }

  /// 상태 초기화
  void resetStatus() {
    _status = IAPStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// 리소스 정리
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'api_service.dart';
import 'device_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final ApiService _apiService = ApiService(); // We'll need to create this later or mock for now

  // Products
  static const String premiumLifetime = 'premium_lifetime';
  static const Set<String> _kIds = {premiumLifetime};

  // Check if user is premium (Mock for now, should check SharedPreferences/Subscription)
  static bool get isPremium => false; 

  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        // Handle missing IDs
      }
      _products = response.productDetails;
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // Handle error
    });
  }

  Future<void> buyLifetime() async {
    if (!_isAvailable || _products.isEmpty) return;
    
    final ProductDetails productDetails = _products.firstWhere(
      (product) => product.id == premiumLifetime,
      orElse: () => _products.first,
    );
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            // Unlock premium content
          } else {
            // Handle invalid purchase
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final deviceId = await DeviceService().getDeviceId();
    
    // Call our backend to verify
    // Note: You need to implement verifyPurchase in ApiService
    // return await _apiService.verifyPurchase(
    //   deviceId: deviceId,
    //   token: purchaseDetails.verificationData.serverVerificationData,
    //   productId: purchaseDetails.productID,
    // );
    
    return true; // Mock for now until ApiService is updated
  }
}

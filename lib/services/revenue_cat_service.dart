import 'dart:async';

import 'package:aspire/services/log_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'revenue_cat_service.g.dart';

/// RevenueCat public API key (safe to expose)
const String _revenueCatApiKey = 'goog_YsWyoTpPIWRtLtbqiJgxgKRLyYE';

/// Entitlement identifier for premium features
const String premiumEntitlement = 'premium';

/// DEBUG: Set to true to bypass premium checks for testing
/// IMPORTANT: Set to false before release!
const bool _debugPremiumBypass = false;

/// RevenueCat service for handling subscriptions
class RevenueCatService {
  bool _isInitialized = false;
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      final config = PurchasesConfiguration(_revenueCatApiKey);
      await Purchases.configure(config);

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfoController.add(customerInfo);
      });

      _isInitialized = true;
      Log.i('RevenueCat initialized');
    } catch (e, stack) {
      Log.e('Failed to initialize RevenueCat', error: e, stackTrace: stack);
    }
  }

  /// Login user to RevenueCat (call after Firebase auth)
  Future<void> login(String userId) async {
    try {
      await Purchases.logIn(userId);
      Log.i('RevenueCat user logged in: $userId');
    } catch (e, stack) {
      Log.e('Failed to login to RevenueCat', error: e, stackTrace: stack);
    }
  }

  /// Logout user from RevenueCat
  Future<void> logout() async {
    try {
      await Purchases.logOut();
      Log.i('RevenueCat user logged out');
    } catch (e, stack) {
      Log.e('Failed to logout from RevenueCat', error: e, stackTrace: stack);
    }
  }

  /// Check if user has premium entitlement
  Future<bool> isPremium() async {
    // DEBUG: Bypass for testing premium features
    if (_debugPremiumBypass) return true;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[premiumEntitlement]?.isActive ??
          false;
    } catch (e, stack) {
      Log.e('Failed to check premium status', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Get available offerings (subscription packages)
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e, stack) {
      Log.e('Failed to get offerings', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      // ignore: deprecated_member_use
      final result = await Purchases.purchasePackage(package);
      final isPremiumNow =
          result.customerInfo.entitlements.all[premiumEntitlement]?.isActive ??
          false;
      Log.i('Purchase completed. Premium: $isPremiumNow');
      return isPremiumNow;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        Log.i('Purchase cancelled by user');
      } else {
        Log.e('Purchase failed: $e');
      }
      return false;
    } catch (e, stack) {
      Log.e('Purchase failed', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremiumNow =
          customerInfo.entitlements.all[premiumEntitlement]?.isActive ?? false;
      Log.i('Restore completed. Premium: $isPremiumNow');
      return isPremiumNow;
    } catch (e, stack) {
      Log.e('Restore failed', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Stream of customer info updates
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// Dispose the service
  void dispose() {
    _customerInfoController.close();
  }
}

@riverpod
RevenueCatService revenueCatService(Ref ref) {
  final service = RevenueCatService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider for premium status (reactive)
@riverpod
Stream<bool> isPremium(Ref ref) async* {
  final service = ref.watch(revenueCatServiceProvider);

  // Initial check
  yield await service.isPremium();

  // Listen to updates
  await for (final info in service.customerInfoStream) {
    yield info.entitlements.all[premiumEntitlement]?.isActive ?? false;
  }
}

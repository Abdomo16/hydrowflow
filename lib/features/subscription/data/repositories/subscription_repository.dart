import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionRepository {
  static const String _googleApiKey = 'goog_REPLACE_WITH_YOUR_GOOGLE_KEY';
  static const String _appleApiKey = 'appl_REPLACE_WITH_YOUR_APPLE_KEY';
  static const String _entitlementId = 'pro';

  bool _initialized = false;

  bool get isReady => _initialized;

  Future<void> initialize({String? appUserId}) async {
    if (_initialized) return;

    final apiKey = Platform.isIOS ? _appleApiKey : _googleApiKey;
    if (apiKey.contains('REPLACE_WITH')) {
      throw StateError('RevenueCat API key is not set');
    }

    await Purchases.setLogLevel(LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(apiKey));

    if (appUserId != null) {
      await Purchases.logIn(appUserId);
    }

    _initialized = true;
  }

  bool _isPro(CustomerInfo customer) =>
      customer.entitlements.all[_entitlementId]?.isActive ?? false;

  /// Calls [onChange] whenever RevenueCat reports a renewal, expiry or refund.
  void listen(void Function(bool isPro) onChange) {
    if (!_initialized) return;
    Purchases.addCustomerInfoUpdateListener((c) => onChange(_isPro(c)));
  }

  Future<bool> checkPro() async {
    try {
      if (!_initialized) return false;
      final customer = await Purchases.getCustomerInfo();
      return _isPro(customer);
    } catch (_) {
      return false;
    }
  }

  Future<List<Package>> loadPackages() async {
    if (!_initialized) return [];
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? [];
    return packages;
  }

  Future<bool> purchase(Package package) async {
    final result = await Purchases.purchasePackage(package);
    return _isPro(result);
  }

  Future<bool> restore() async {
    final customer = await Purchases.restorePurchases();
    return _isPro(customer);
  }

  Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (_) {
      // Not logged in to RevenueCat.
    }
    _initialized = false;
  }
}

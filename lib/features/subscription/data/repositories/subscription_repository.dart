import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionRepository {
  static const String _googleApiKey = 'goog_REPLACE_WITH_YOUR_GOOGLE_KEY';
  static const String _entitlementId = 'pro';

  bool _initialized = false;

  Future<void> initialize({String? appUserId}) async {
    if (_initialized) return;

    await Purchases.setLogLevel(LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(_googleApiKey));

    if (appUserId != null) {
      await Purchases.logIn(appUserId);
    }

    _initialized = true;
  }

  Future<bool> checkPro() async {
    try {
      if (!_initialized) return false;
      final customer = await Purchases.getCustomerInfo();
      return customer.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<Package>> loadPackages() async {
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? [];
    return packages;
  }

  Future<bool> purchase(Package package) async {
    final customer = await Purchases.purchasePackage(package);
    return customer.entitlements.all[_entitlementId]?.isActive ?? false;
  }

  Future<bool> restore() async {
    final customer = await Purchases.restorePurchases();
    return customer.entitlements.all[_entitlementId]?.isActive ?? false;
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

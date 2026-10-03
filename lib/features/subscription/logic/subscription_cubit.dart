import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../data/repositories/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository repository;

  List<Package> _packages = [];

  SubscriptionCubit(this.repository) : super(SubscriptionState.initial());

  Future<void> initialize({String? appUserId}) async {
    try {
      await repository.initialize(appUserId: appUserId);
      await refreshPro();
      await loadPackages();
    } catch (_) {
      // RevenueCat not configured yet; app runs in free mode.
    }
  }

  Future<void> refreshPro() async {
    final isPro = await repository.checkPro();
    emit(state.copyWith(isPro: isPro));
  }

  Future<void> loadPackages() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      _packages = await repository.loadPackages();
      emit(
        state.copyWith(
          loading: false,
          planLabels: _packages.map(_labelFor).toList(),
          packageIndexes: List.generate(_packages.length, (i) => i),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Could not load plans. Check your connection.',
        ),
      );
    }
  }

  Future<void> purchasePackage(int index) async {
    if (index < 0 || index >= _packages.length) return;

    emit(state.copyWith(purchasing: true, error: null));
    try {
      final isPro = await repository.purchase(_packages[index]);
      emit(state.copyWith(purchasing: false, isPro: isPro));
    } on PlatformException catch (e) {
      if (_isCancelled(e)) {
        emit(state.copyWith(purchasing: false));
        return;
      }
      emit(
        state.copyWith(
          purchasing: false,
          error: 'Purchase failed. Please try again.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          purchasing: false,
          error: 'Purchase failed. Please try again.',
        ),
      );
    }
  }

  Future<void> restorePurchases() async {
    emit(state.copyWith(purchasing: true, error: null));
    try {
      final isPro = await repository.restore();
      emit(
        state.copyWith(
          purchasing: false,
          isPro: isPro,
          error: isPro ? 'Purchases restored successfully!' : null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          purchasing: false,
          error: 'Could not restore purchases.',
        ),
      );
    }
  }

  String _labelFor(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return '${package.storeProduct.priceString} / month';
      case PackageType.annual:
        return '${package.storeProduct.priceString} / year';
      case PackageType.lifetime:
        return '${package.storeProduct.priceString} lifetime';
      default:
        return package.storeProduct.priceString;
    }
  }

  bool _isCancelled(PlatformException e) {
    return e.code == 'PURCHASE_CANCELLED_ERROR' ||
        e.details?['readableErrorCode'] == 'PURCHASE_CANCELLED_ERROR';
  }
}

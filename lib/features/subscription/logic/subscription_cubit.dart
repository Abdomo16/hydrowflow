import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  static const String _trialKey = 'premium_trial_until';
  static const Duration trialLength = Duration(hours: 24);

  final SubscriptionRepository repository;

  List<Package> _packages = [];
  Timer? _trialTimer;

  SubscriptionCubit(this.repository) : super(SubscriptionState.initial());

  /// Loads the saved trial and the RevenueCat status. Safe to call once at
  /// startup even when RevenueCat isn't configured (the app stays free).
  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_trialKey);
    if (saved != null) {
      final until = DateTime.fromMillisecondsSinceEpoch(saved);
      if (until.isAfter(DateTime.now())) {
        emit(state.copyWith(trialUntil: until));
        _scheduleTrialEnd(until);
      } else {
        await prefs.remove(_trialKey);
      }
    }

    if (!repository.isReady) return;
    repository.listen((isPro) {
      if (!isClosed && isPro != state.isPro) {
        emit(state.copyWith(isPro: isPro));
      }
    });
    await refreshPro();
  }

  Future<void> grantTrial() async {
    final until = DateTime.now().add(trialLength);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trialKey, until.millisecondsSinceEpoch);
    emit(state.copyWith(trialUntil: until));
    _scheduleTrialEnd(until);
  }

  void _scheduleTrialEnd(DateTime until) {
    _trialTimer?.cancel();
    _trialTimer = Timer(until.difference(DateTime.now()), () {
      if (!isClosed) emit(state.copyWith(clearTrial: true));
    });
  }

  /// Re-checks the trial after the app was suspended (timers don't run then).
  void checkTrialExpiry() {
    if (state.trialUntil != null && !state.trialActive) {
      emit(state.copyWith(clearTrial: true));
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
          error: isPro
              ? 'Purchases restored successfully!'
              : 'No previous purchase found.',
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

  @override
  Future<void> close() {
    _trialTimer?.cancel();
    return super.close();
  }
}

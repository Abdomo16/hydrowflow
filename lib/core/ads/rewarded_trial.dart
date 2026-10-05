import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrowflow/core/ads/ad_ids.dart';
import 'package:hydrowflow/core/ads/ad_service.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';

/// Optional rewarded video: watching it to the end unlocks Premium for 24h.
class RewardedTrial {
  static Future<bool> show(BuildContext context) async {
    final cubit = context.read<SubscriptionCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    if (!AdService.isSupported) return false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final ad = await _load();
    navigator.pop();

    if (ad == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No video available right now. Try again later.'),
        ),
      );
      return false;
    }

    final finished = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!finished.isCompleted) finished.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!finished.isCompleted) finished.complete(false);
      },
    );

    await ad.show(onUserEarnedReward: (_, _) => earned = true);

    final rewarded = await finished.future;
    if (rewarded) {
      await cubit.grantTrial();
      messenger.showSnackBar(
        const SnackBar(content: Text('Premium unlocked for 24 hours!')),
      );
    }
    return rewarded;
  }

  static Future<RewardedAd?> _load() {
    final result = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: result.complete,
        onAdFailedToLoad: (_) => result.complete(null),
      ),
    );
    return result.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => null,
    );
  }
}

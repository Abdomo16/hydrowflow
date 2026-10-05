import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrowflow/core/ads/ad_ids.dart';
import 'package:hydrowflow/core/ads/ad_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One full-screen ad per day at most, shown when the daily goal is reached.
class DailyInterstitial {
  static const String _lastShownKey = 'interstitial_last_shown';

  static InterstitialAd? _ad;
  static bool _loading = false;

  static String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<bool> _shownToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastShownKey) == _today();
  }

  /// Loads an ad in the background if one can still be shown today.
  static Future<void> preload() async {
    if (!AdService.isSupported || _ad != null || _loading) return;
    if (await _shownToday()) return;

    _loading = true;
    await InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          debugPrint('Interstitial failed to load: $error');
        },
      ),
    );
  }

  static Future<void> maybeShow() async {
    final ad = _ad;
    if (ad == null || await _shownToday()) return;
    _ad = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastShownKey, _today());

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, _) => ad.dispose(),
    );
    await ad.show();
  }
}

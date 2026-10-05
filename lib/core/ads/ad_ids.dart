import 'dart:io';

import 'package:flutter/foundation.dart';

/// Debug builds always use Google's test ad units, so tapping ads while
/// developing can't get the AdMob account flagged. Release builds use the
/// real units where they exist and fall back to test units otherwise.
class AdIds {
  // Real AdMob units (Android).
  static const String _androidBanner = 'ca-app-pub-1716159714785182/9647821465';
  static const String _androidInterstitial =
      'ca-app-pub-1716159714785182/4587066477';
  static const String _androidRewarded =
      'ca-app-pub-1716159714785182/5793260375';

  static String get banner => _pick(
    real: Platform.isAndroid ? _androidBanner : null,
    androidTest: 'ca-app-pub-3940256099942544/9214589741',
    iosTest: 'ca-app-pub-3940256099942544/2435281174',
  );

  static String get interstitial => _pick(
    real: Platform.isAndroid ? _androidInterstitial : null,
    androidTest: 'ca-app-pub-3940256099942544/1033173712',
    iosTest: 'ca-app-pub-3940256099942544/4411468910',
  );

  /// Rewarded interstitial unit (the "watch a video for 24h" trial).
  static String get rewarded => _pick(
    real: Platform.isAndroid ? _androidRewarded : null,
    androidTest: 'ca-app-pub-3940256099942544/5354046379',
    iosTest: 'ca-app-pub-3940256099942544/6978759866',
  );

  static String _pick({
    required String? real,
    required String androidTest,
    required String iosTest,
  }) {
    if (kReleaseMode && real != null) return real;
    return Platform.isIOS ? iosTest : androidTest;
  }
}

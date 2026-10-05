import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Starts the Mobile Ads SDK after asking for consent where required (UMP).
class AdService {
  static bool _started = false;
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  static Future<void> init() async {
    if (_started || !isSupported) return;
    _started = true;

    try {
      await _gatherConsent();
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdService.init failed: $e');
    }
  }

  static Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((_) {
          if (!done.isCompleted) done.complete();
        });
      },
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {},
    );
  }

  static Future<bool> get privacyOptionsRequired async =>
      await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  /// Lets users in the EU change their ad consent choice.
  static void showPrivacyOptions() {
    ConsentForm.showPrivacyOptionsForm((_) {});
  }
}

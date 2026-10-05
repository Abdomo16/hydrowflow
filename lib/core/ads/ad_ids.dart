import 'dart:io';

/// Google's public test ad units. Replace with your AdMob ad unit IDs before
/// release (and the App ID in AndroidManifest.xml / Info.plist).
class AdIds {
  static String get banner => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/2435281174'
      : 'ca-app-pub-3940256099942544/9214589741';

  static String get interstitial => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  static String get rewarded => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrowflow/core/ads/ad_ids.dart';
import 'package:hydrowflow/core/ads/ad_service.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';

/// Anchored adaptive banner for free users. Renders nothing for Premium.
class BannerAdBar extends StatelessWidget {
  const BannerAdBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.select<SubscriptionCubit, bool>(
      (c) => c.state.isPremium,
    );
    if (isPremium || !AdService.isSupported) return const SizedBox.shrink();
    return const _BannerSlot();
  }
}

class _BannerSlot extends StatefulWidget {
  const _BannerSlot();

  @override
  State<_BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<_BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Standard 320x50 banner: the smallest size, so it stays slimmer than
  /// the navigation bar.
  void _load() {
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();

    return ColoredBox(
      color: context.colors.navBar,
      child: Center(
        heightFactor: 1,
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}

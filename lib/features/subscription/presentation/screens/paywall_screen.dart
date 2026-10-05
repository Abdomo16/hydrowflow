import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/ads/rewarded_trial.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import '../../logic/subscription_cubit.dart';
import '../../logic/subscription_state.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().loadPackages();
  }

  @override
  Widget build(BuildContext context) => const _PaywallView();
}

class _PaywallView extends StatelessWidget {
  const _PaywallView();

  static List<(IconData, String, String)> get _proFeatures => [
    (
      Icons.block,
      'No Ads',
      'A clean app with no banners or videos.',
    ),
    (
      Icons.notifications_active_outlined,
      'Smart Reminders & All Sounds',
      'Reminders wait after each drink, stop when you hit your goal, '
          'any interval you like.',
    ),
    (
      Icons.insights_outlined,
      'Monthly Stats & History',
      'See every week of the month and your full drinking history.',
    ),
    (
      Icons.local_cafe_outlined,
      'Drink Types',
      'Log coffee, tea, juice, milk and more, each counted correctly.',
    ),
    if (Platform.isAndroid)
      (
        Icons.widgets_outlined,
        'Home Screen Widget',
        'See your progress and add a cup without opening the app.',
      ),
    (
      Icons.palette_outlined,
      'Color Themes',
      'Mint, Sunset, Lavender and Rose, in light and dark.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          if (state.isPremium) {
            Navigator.pop(context, true);
          }
        },
        listenWhen: (prev, curr) =>
            curr.error != null || (!prev.isPremium && curr.isPremium),
        builder: (context, state) {
          final cubit = context.read<SubscriptionCubit>();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFF5C542),
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'HydroFlow Premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock everything, stay hydrated everywhere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  for (final feature in _proFeatures)
                    _featureTile(colors, feature),

                  const SizedBox(height: 28),

                  if (state.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.planLabels.isEmpty)
                    Text(
                      'Plans are not available yet. Please try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    )
                  else
                    ...List.generate(state.planLabels.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state.purchasing
                                ? null
                                : () => cubit.purchasePackage(i),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              disabledBackgroundColor: colors.primary
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state.purchasing
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: colors.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    state.planLabels[i],
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 4),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: state.purchasing
                          ? null
                          : () => RewardedTrial.show(context),
                      icon: Icon(
                        Icons.play_circle_outline,
                        color: colors.primary,
                      ),
                      label: Text(
                        'Watch a video for 24h free',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed:
                        state.purchasing ? null : cubit.restorePurchases,
                    child: Text(
                      'Restore Purchases',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cancel anytime. Payment is charged to your app store account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _featureTile(AppColors colors, (IconData, String, String) feature) {
    final (icon, title, subtitle) = feature;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

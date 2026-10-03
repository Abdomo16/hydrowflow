import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../logic/subscription_cubit.dart';
import '../../logic/subscription_state.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubscriptionCubit(locator<SubscriptionRepository>())
        ..loadPackages(),
      child: const _PaywallView(),
    );
  }
}

class _PaywallView extends StatelessWidget {
  const _PaywallView();

  static const List<(IconData, String, String)> _proFeatures = [
    (
      Icons.cloud_sync_outlined,
      'Cloud Backup & Sync',
      'Your data is safe and follows you across devices.'
    ),
    (
      Icons.insights_outlined,
      'Advanced Statistics',
      'Monthly trends, yearly views, and deeper insights.'
    ),
    (
      Icons.local_drink_outlined,
      'Custom Drinks & Sizes',
      'Log coffee, tea, juice, and any custom cup size.'
    ),
    (
      Icons.notifications_active_outlined,
      'Unlimited Reminder Presets',
      'Custom schedules and sounds that fit your day.'
    ),
    (
      Icons.dashboard_customize_outlined,
      'Home Screen Widgets',
      'Track and log water without opening the app.'
    ),
    (
      Icons.file_download_outlined,
      'Export Your Data',
      'Download your full history as CSV anytime.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1621),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
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
          if (state.isPro) {
            Navigator.pop(context, true);
          }
        },
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
                  const Text(
                    'HydroFlow Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock everything, stay hydrated everywhere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  ..._proFeatures.map(_featureTile),

                  const SizedBox(height: 28),

                  if (state.loading)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2F8BEF)),
                    )
                  else if (state.planLabels.isEmpty)
                    const Text(
                      'Plans are not available yet. Please try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 13),
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
                              backgroundColor: const Color(0xFF2F8BEF),
                              disabledBackgroundColor: const Color(0xFF2F8BEF)
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state.purchasing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    state.planLabels[i],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),

                  TextButton(
                    onPressed:
                        state.purchasing ? null : cubit.restorePurchases,
                    child: const Text(
                      'Restore Purchases',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cancel anytime. Payment is charged to your app store account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, fontSize: 11),
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

  Widget _featureTile((IconData, String, String) feature) {
    final (icon, title, subtitle) = feature;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2633),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2F8BEF), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

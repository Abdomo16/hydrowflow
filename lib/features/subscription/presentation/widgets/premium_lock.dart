import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/ads/rewarded_trial.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/subscription/logic/pro_gate.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';

/// Shows [child] blurred behind an unlock card for free users.
class PremiumLock extends StatelessWidget {
  final Widget child;
  final String message;

  const PremiumLock({super.key, required this.child, required this.message});

  @override
  Widget build(BuildContext context) {
    final premium = context.select<SubscriptionCubit, bool>(
      (c) => c.state.isPremium,
    );
    if (premium) return child;

    final colors = context.colors;

    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: child,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProBadge(),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ProGate.showPaywallIfLocked(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Unlock with Premium',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => RewardedTrial.show(context),
                icon: Icon(Icons.play_circle_outline, color: colors.primary),
                label: Text(
                  'Watch a video for 24h free',
                  style: TextStyle(color: colors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

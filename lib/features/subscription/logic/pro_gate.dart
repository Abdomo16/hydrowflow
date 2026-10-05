import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/subscription_cubit.dart';
import '../logic/subscription_state.dart';
import '../presentation/screens/paywall_screen.dart';

/// Wrap any widget (button, tile, etc.) to require Premium.
/// If the user is not Premium, tapping shows the paywall instead.
class ProGate extends StatelessWidget {
  final Widget child;
  final VoidCallback? onProUnlocked;

  const ProGate({super.key, required this.child, this.onProUnlocked});

  static bool isPremium(BuildContext context) =>
      context.read<SubscriptionCubit>().state.isPremium;

  static Future<bool> showPaywallIfLocked(BuildContext context) async {
    if (isPremium(context)) return true;

    final unlocked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    return unlocked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (prev, curr) => prev.isPremium != curr.isPremium,
      builder: (context, state) {
        if (state.isPremium) return child;

        return GestureDetector(
          onTap: () async {
            final unlocked = await showPaywallIfLocked(context);
            if (unlocked && onProUnlocked != null) onProUnlocked!();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AbsorbPointer(child: child),
              const Positioned(
                top: 6,
                right: 8,
                child: ProBadge(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5C542), Color(0xFFE09B2D)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Color(0xFF1B2633),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

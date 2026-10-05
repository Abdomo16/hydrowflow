import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/hydration/data/models/drink_type.dart';
import 'package:hydrowflow/features/hydration/logic/hydration_cubit.dart';
import 'package:hydrowflow/features/settings/logic/settings_cubit.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';

class AddCupButton extends StatelessWidget {
  const AddCupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cupSizeMl = context.select<SettingsCubit, int>(
      (cubit) => cubit.state.settings.cupSizeMl,
    );
    final premium = context.select<SubscriptionCubit, bool>(
      (c) => c.state.isPremium,
    );
    final drink = context.select<HydrationCubit, DrinkType>(
      (c) => premium ? c.state.selectedDrink : DrinkType.water,
    );

    return SizedBox(
      width: 240,
      height: 66,
      child: ElevatedButton(
        onPressed: () => context.read<HydrationCubit>().addDrink(
          cupSizeMl,
          type: drink,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          elevation: 8,
          shadowColor: colors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              drink == DrinkType.water ? Icons.add_circle_outline : drink.icon,
              size: 24.5,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  drink == DrinkType.water
                      ? 'ADD DRINK'
                      : 'ADD ${drink.label.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  drink.hydrationFactor < 1
                      ? '$cupSizeMl ml · counts ${drink.hydrationMl(cupSizeMl)} ml'
                      : '$cupSizeMl ml',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

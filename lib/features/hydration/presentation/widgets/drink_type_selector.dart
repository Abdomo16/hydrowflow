import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/hydration/data/models/drink_type.dart';
import 'package:hydrowflow/features/hydration/logic/hydration_cubit.dart';
import 'package:hydrowflow/features/subscription/logic/pro_gate.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';

/// Horizontal drink chips above "Add Drink". Non-water drinks are Premium.
class DrinkTypeSelector extends StatelessWidget {
  const DrinkTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final premium = context.select<SubscriptionCubit, bool>(
      (c) => c.state.isPremium,
    );
    final selected = context.select<HydrationCubit, DrinkType>(
      (c) => premium ? c.state.selectedDrink : DrinkType.water,
    );

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: DrinkType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = DrinkType.values[index];
          final isSelected = type == selected;
          final locked = !premium && !type.isFree;

          return ChoiceChip(
            avatar: Icon(
              locked ? Icons.lock : type.icon,
              size: 16,
              color: isSelected ? colors.onPrimary : colors.primary,
            ),
            label: Text(type.label),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: colors.primary,
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? colors.primary : colors.border,
              ),
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? colors.onPrimary
                  : locked
                  ? colors.textMuted
                  : colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            onSelected: (_) async {
              final cubit = context.read<HydrationCubit>();
              if (locked && !await ProGate.showPaywallIfLocked(context)) {
                return;
              }
              cubit.selectDrink(type);
            },
          );
        },
      ),
    );
  }
}

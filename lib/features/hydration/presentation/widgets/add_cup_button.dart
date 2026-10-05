import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/hydration/logic/hydration_cubit.dart';
import 'package:hydrowflow/features/settings/logic/settings_cubit.dart';

class AddCupButton extends StatelessWidget {
  const AddCupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cupSizeMl = context.select<SettingsCubit, int>(
      (cubit) => cubit.state.settings.cupSizeMl,
    );

    return SizedBox(
      width: 220,
      height: 66,
      child: ElevatedButton(
        onPressed: () => context.read<HydrationCubit>().addDrink(cupSizeMl),
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
            const Icon(Icons.add_circle_outline, size: 24.5, color: Colors.white),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ADD DRINK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$cupSizeMl ml',
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

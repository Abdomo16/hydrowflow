import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/hydration/logic/hydration_cubit.dart';
import 'add_drink_bottom_sheet.dart';

class AddCupButton extends StatelessWidget {
  const AddCupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 66,
      child: ElevatedButton(
        onPressed: () => _showBottomSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F8BEF),
          elevation: 8,
          shadowColor: Colors.blue.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24.5, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'ADD DRINK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddDrinkBottomSheet(
        onAdd: (amountMl) {
          final cubit = context.read<HydrationCubit>();
          cubit.addDrink(amountMl);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $amountMl ml'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'UNDO',
                textColor: Colors.blue,
                onPressed: cubit.undoLast,
              ),
            ),
          );
        },
      ),
    );
  }
}

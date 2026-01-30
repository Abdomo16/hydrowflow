import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/hydration/logic/hydration_cubit.dart';

class AddCupButton extends StatelessWidget {
  const AddCupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 66,
      child: ElevatedButton(
        onPressed: () => context.read<HydrationCubit>().addCup(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2F8BEF),
          elevation: 8,
          shadowColor: Colors.blue.withOpacity(0.4),
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
              'ADD CUP',
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
}

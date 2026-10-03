import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubit extends Cubit<double> {
  AppCubit(super.initialGoal);

  void updateGoal(double newGoal) {
    emit(newGoal);
  }
}

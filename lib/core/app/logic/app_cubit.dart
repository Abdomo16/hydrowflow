import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubit extends Cubit<double> {
  AppCubit(double initialGoal) : super(initialGoal);

  void updateGoal(double newGoal) {
    emit(newGoal);
  }
}

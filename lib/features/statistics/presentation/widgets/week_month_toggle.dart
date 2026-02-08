import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/statistics_cubit.dart';
import '../../logic/statistics_state.dart';

class WeekMonthToggle extends StatelessWidget {
  const WeekMonthToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF16202A),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              _Tab(
                label: 'Week',
                selected: state.view == StatsView.week,
                onTap: () =>
                    context.read<StatisticsCubit>().changeView(StatsView.week),
              ),
              _Tab(
                label: 'Month',
                selected: state.view == StatsView.month,
                onTap: () =>
                    context.read<StatisticsCubit>().changeView(StatsView.month),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 19, 28, 37)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

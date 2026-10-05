import 'package:flutter/material.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/statistics_repository.dart';

/// Premium: every logged day grouped by month.
class HistoryScreen extends StatelessWidget {
  final int targetCups;

  const HistoryScreen({super.key, required this.targetCups});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<DayHistory>>(
        future: locator<StatisticsRepository>().getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final days = snapshot.data!;
          if (days.isEmpty) {
            return Center(
              child: Text(
                'No drinks logged yet.',
                style: TextStyle(color: colors.textSecondary),
              ),
            );
          }

          final items = <Object>[];
          String? currentMonth;
          for (final day in days) {
            final month = DateFormat('MMMM yyyy').format(day.date);
            if (month != currentMonth) {
              currentMonth = month;
              items.add(month);
            }
            items.add(day);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item is String) {
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 4 : 20, bottom: 8),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }
              return _DayTile(day: item as DayHistory, targetCups: targetCups);
            },
          );
        },
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final DayHistory day;
  final int targetCups;

  const _DayTile({required this.day, required this.targetCups});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reached = targetCups > 0 && day.cups >= targetCups;
    final progress = targetCups <= 0
        ? 0.0
        : (day.cups / targetCups).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            reached ? Icons.check_circle : Icons.water_drop_outlined,
            color: reached ? colors.success : colors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d').format(day.date),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: colors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(
                      reached ? colors.success : colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${day.totalMl} ml',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

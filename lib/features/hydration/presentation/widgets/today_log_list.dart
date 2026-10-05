import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/hydration/data/models/drink_type.dart';
import 'package:hydrowflow/features/hydration/data/models/hydration_log.dart';
import 'package:hydrowflow/features/hydration/logic/hydration_cubit.dart';
import 'package:hydrowflow/features/hydration/logic/hydration_state.dart';

class TodayLogList extends StatelessWidget {
  static const int previewCount = 3;

  final List<HydrationLog> logs;
  final void Function(int id) onDelete;

  const TodayLogList({
    super.key,
    required this.logs,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    final preview = logs.take(previewCount).toList();
    final hasMore = logs.length > previewCount;

    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Logs",
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            if (hasMore)
              TextButton(
                onPressed: () => _showAllLogs(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View all (${logs.length})',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final log in preview) ...[
          _LogTile(log: log, onDelete: onDelete),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _showAllLogs(BuildContext context) {
    final cubit = context.read<HydrationCubit>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AllLogsSheet(onDelete: onDelete),
      ),
    );
  }
}

class _AllLogsSheet extends StatelessWidget {
  final void Function(int id) onDelete;

  const _AllLogsSheet({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        final colors = context.colors;

        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: BlocConsumer<HydrationCubit, HydrationState>(
            listenWhen: (prev, curr) => curr.logs.isEmpty && !curr.loading,
            listener: (context, _) => Navigator.of(context).pop(),
            builder: (context, state) {
              final logs = state.logs;

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Logs",
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${logs.length} drinks · ${state.consumedMl} ml',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: logs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) =>
                          _LogTile(log: logs[index], onDelete: onDelete),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _LogTile extends StatelessWidget {
  final HydrationLog log;
  final void Function(int id) onDelete;

  const _LogTile({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = TimeOfDay.fromDateTime(log.createdAt).format(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(log.drinkType.icon, color: colors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.drinkType == DrinkType.water
                      ? '${log.amountMl} ml'
                      : '${log.drinkType.label} · ${log.amountMl} ml',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colors.danger),
            onPressed: () => onDelete(log.id!),
          ),
        ],
      ),
    );
  }
}

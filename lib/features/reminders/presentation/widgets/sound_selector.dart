import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/reminders/data/models/reminder_sound.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_state.dart';

class SoundSelector extends StatelessWidget {
  const SoundSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final sounds = ReminderSound.available;

    return BlocBuilder<ReminderCubit, ReminderState>(
      buildWhen: (prev, curr) => prev.settings.sound != curr.settings.sound,
      builder: (context, state) {
        final cubit = context.read<ReminderCubit>();

        final colors = context.colors;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sound',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final sound in sounds)
              _SoundTile(
                sound: sound,
                selected: state.settings.sound == sound.id,
                onSelect: () => cubit.changeSound(sound.id),
                onPreview: () => cubit.previewSound(sound.id),
              ),
            if (Platform.isIOS)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'On iPhone, reminders use your notification sound from iOS settings.',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SoundTile extends StatelessWidget {
  final ReminderSound sound;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const _SoundTile({
    required this.sound,
    required this.selected,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(left: 16, right: 4),
        decoration: BoxDecoration(
          color: selected ? colors.primarySoft : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? colors.primary : colors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sound.label,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
              ),
            ),
            IconButton(
              tooltip: 'Preview',
              onPressed: onPreview,
              icon: Icon(Icons.play_circle_outline, color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

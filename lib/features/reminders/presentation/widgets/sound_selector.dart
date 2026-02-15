import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_state.dart';

class SoundSelector extends StatefulWidget {
  const SoundSelector({super.key});

  @override
  State<SoundSelector> createState() => _SoundSelectorState();
}

class _SoundSelectorState extends State<SoundSelector> {
  bool expanded = false;

  static const sounds = [
    {'id': 'electric_water_flow', 'label': 'Electric Water Flow'},
    {'id': 'soft_electric_bell', 'label': 'Soft Electric Bell'},
    {'id': 'electric_minimal_ping', 'label': 'Electric Minimal Ping'},
    {'id': 'ultra_minimal_tech_pulse', 'label': 'Ultra Minimal Tech Pulse'},
    {'id': 'electric_fusion', 'label': 'Electric Fusion'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderCubit, ReminderState>(
      builder: (context, state) {
        final selectedSound = sounds.firstWhere(
          (s) => s['id'] == state.settings.sound,
          orElse: () => sounds.first,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  MAIN BUTTON
            GestureDetector(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16202A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedSound['label']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),

            // SOUND LIST
            if (expanded) ...[
              const SizedBox(height: 10),
              Column(
                children: sounds.map((sound) {
                  final selected = state.settings.sound == sound['id'];

                  return GestureDetector(
                    onTap: () {
                      context.read<ReminderCubit>().changeSound(sound['id']!);

                      setState(() {
                        expanded = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF223A55)
                            : const Color(0xFF1B2633),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? Colors.blue : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected ? Colors.blue : Colors.white54,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            sound['label']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}

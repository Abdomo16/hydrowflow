import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/onboarding_cubit.dart';

enum MetricType { height, weight }

class MetricCard extends StatefulWidget {
  final String label;
  final MetricType type;

  const MetricCard({super.key, required this.label, required this.type});

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            cursorColor: Colors.blue,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E2533),

              hintText: widget.type == MetricType.height ? '180' : '75',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed == null) return;

              if (widget.type == MetricType.height) {
                cubit.updateHeight(parsed);
              } else {
                cubit.updateWeight(parsed);
              }
            },
          ),
        ],
      ),
    );
  }
}

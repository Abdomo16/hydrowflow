import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
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
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isHeight => widget.type == MetricType.height;

  String? _validate(double? value) {
    if (value == null) return null;

    if (_isHeight) {
      if (value < 100 || value > 250) {
        return 'Height must be 100-250 cm';
      }
    } else {
      if (value < 30 || value > 250) {
        return 'Weight must be 30-250 kg';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final colors = context.colors;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            cursorColor: colors.primary,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surface,
              hintText: _isHeight ? '180' : '75',
              hintStyle: TextStyle(
                color: colors.textMuted,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              errorText: _errorText,
              errorStyle: const TextStyle(fontSize: 10),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed == null || parsed <= 0) {
                setState(() => _errorText = null);
                return;
              }

              final error = _validate(parsed);
              setState(() => _errorText = error);

              if (error != null) return;

              if (_isHeight) {
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

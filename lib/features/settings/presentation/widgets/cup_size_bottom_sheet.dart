import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/settings/data/models/settings_model.dart';

class CupSizeBottomSheet extends StatefulWidget {
  final int currentMl;
  final void Function(int amountMl) onSave;

  const CupSizeBottomSheet({
    super.key,
    required this.currentMl,
    required this.onSave,
  });

  @override
  State<CupSizeBottomSheet> createState() => _CupSizeBottomSheetState();
}

class _CupSizeBottomSheetState extends State<CupSizeBottomSheet> {
  final _customController = TextEditingController();
  int? _selectedMl;

  @override
  void initState() {
    super.initState();
    if (SettingsModel.cupSizePresetsMl.contains(widget.currentMl)) {
      _selectedMl = widget.currentMl;
    } else {
      _customController.text = widget.currentMl.toString();
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  int? get _amount => _selectedMl ?? int.tryParse(_customController.text);

  void _submit() {
    final amount = _amount;
    if (amount == null || amount <= 0) return;

    Navigator.pop(context);
    widget.onSave(amount);
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cup Size',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Each tap on "Add Drink" logs this amount. '
                'Drinks you already logged keep their size.',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: SettingsModel.cupSizePresetsMl.map((ml) {
                  final selected = _selectedMl == ml;
                  final isDefault = ml == SettingsModel.defaultCupSizeMl;
                  return ChoiceChip(
                    label: Text(isDefault ? '$ml ml (standard)' : '$ml ml'),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedMl = ml;
                        _customController.clear();
                      });
                    },
                    showCheckmark: false,
                    selectedColor: colors.primary,
                    backgroundColor: colors.surface,
                    side: BorderSide(
                      color: selected ? colors.primary : colors.border,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? colors.onPrimary : colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Custom size in ml',
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                  suffixText: 'ml',
                  suffixStyle: TextStyle(color: colors.textSecondary),
                ),
                onChanged: (_) => setState(() => _selectedMl = null),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: amount != null && amount > 0 ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    disabledBackgroundColor: colors.primary.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

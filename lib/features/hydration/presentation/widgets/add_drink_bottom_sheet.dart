import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddDrinkBottomSheet extends StatefulWidget {
  final void Function(int amountMl) onAdd;

  const AddDrinkBottomSheet({super.key, required this.onAdd});

  @override
  State<AddDrinkBottomSheet> createState() => _AddDrinkBottomSheetState();
}

class _AddDrinkBottomSheetState extends State<AddDrinkBottomSheet> {
  final _customController = TextEditingController();
  int? _selectedMl;

  static const List<int> _presets = [150, 250, 330, 500];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = _selectedMl ?? int.tryParse(_customController.text);
    if (amount == null || amount <= 0) return;

    Navigator.pop(context);
    widget.onAdd(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF16202A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Drink',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a preset or enter a custom amount',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _presets.map((ml) {
                final selected = _selectedMl == ml;
                return ChoiceChip(
                  label: Text('$ml ml'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedMl = ml;
                      _customController.clear();
                    });
                  },
                  selectedColor: const Color(0xFF2F8BEF),
                  backgroundColor: const Color(0xFF1B2633),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Custom amount in ml',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1B2633),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixText: 'ml',
                suffixStyle: const TextStyle(color: Colors.white54),
              ),
              onChanged: (_) => setState(() => _selectedMl = null),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedMl != null ||
                        (_customController.text.isNotEmpty &&
                            int.tryParse(_customController.text) != null)
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F8BEF),
                  disabledBackgroundColor: const Color(0xFF2F8BEF).withValues(
                    alpha: 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Add',
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
    );
  }
}

import 'package:flutter/material.dart';

class OptionDropdown extends StatelessWidget {
  final String? selectedOption;
  final ValueChanged<String?> onOptionSelected;

  const OptionDropdown({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedOption,
      hint: Text("Select answer"),
      decoration: const InputDecoration(labelText: 'Select Correct Answer'),
      items: ['1', '2', '3', '4'].map((options) {
        return DropdownMenuItem(
          value: options,
          child: Text(options),
        );
      }).toList(),
      onChanged: onOptionSelected,
    );
  }
}
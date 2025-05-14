import 'package:flutter/material.dart';

class TrashCanDropdown extends StatelessWidget {
  final String? selectedOption;
  final ValueChanged<String?> onOptionSelected;

  const TrashCanDropdown({
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
      items: ['Yellow bin', 'Blue bin', 'Green bin', 'Red bin', 'Brown bin'].map((options) {
        return DropdownMenuItem(
          value: options,
          child: Text(options),
        );
      }).toList(),
      onChanged: onOptionSelected,
    );
  }
}
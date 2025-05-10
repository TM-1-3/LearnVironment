import 'package:flutter/material.dart';

class AgeGroupDropdown extends StatelessWidget {
  final String selectedAge;
  final ValueChanged<String?> onAgeSelected;

  const AgeGroupDropdown({
    super.key,
    required this.selectedAge,
    required this.onAgeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedAge,
      decoration: const InputDecoration(labelText: 'Select Age Group'),
      items: ['12+', '10+', '8+', '6+'].map((age) {
        return DropdownMenuItem(
          value: age,
          child: Text(age),
        );
      }).toList(),
      onChanged: onAgeSelected,
    );
  }
}
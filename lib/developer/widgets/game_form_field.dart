import 'package:flutter/material.dart';

class GameFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;

  const GameFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.minLines,
    this.maxLines,
    this.keyboardType
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: validator ?? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      minLines: minLines ?? 1,
      maxLines: maxLines,
      keyboardType: keyboardType ?? TextInputType.text,
    );
  }
}
import 'package:flutter/material.dart';

class TrashObject {
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController tipController = TextEditingController();
  String? selectedOption;

  bool isEmpty() {
    return imageUrlController.text.trim().isEmpty ||
           tipController.text.trim().isEmpty ||
            selectedOption == null;
  }

  void dispose() {
    imageUrlController.dispose();
    tipController.dispose();
  }
}
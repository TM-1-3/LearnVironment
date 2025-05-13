import 'package:flutter/material.dart';

class TrashObject {
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController tipController = TextEditingController();

  bool isEmpty() {
    return imageUrlController.text.trim().isEmpty ||
           tipController.text.trim().isEmpty;
  }

  void dispose() {
    imageUrlController.dispose();
    tipController.dispose();
  }
}
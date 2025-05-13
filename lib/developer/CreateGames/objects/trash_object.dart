import 'package:flutter/material.dart';

class TrashObject {
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController tipController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  bool isEmpty() {
    return imageUrlController.text.trim().isEmpty ||
           tipController.text.trim().isEmpty ||
           answerController.text.trim().isEmpty;
  }
}
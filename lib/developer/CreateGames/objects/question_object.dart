import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/objects/option_object.dart';

class QuestionObject {
  TextEditingController questionController = TextEditingController();
  TextEditingController tipController = TextEditingController();
  OptionObject options = OptionObject();

  bool isEmpty() {
    return questionController.text.trim().isEmpty ||
           tipController.text.trim().isEmpty ||
           options.isEmpty();
  }

  void dispose() {
    questionController.dispose();
    tipController.dispose();
    options.dispose();
  }
}
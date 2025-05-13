import 'package:flutter/material.dart';

class OptionObject {
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();

  bool isEmpty() {
    return option1Controller.text.isEmpty ||
           option2Controller.text.isEmpty ||
           option3Controller.text.isEmpty ||
           option4Controller.text.isEmpty;
  }

  void dispose() {
    option1Controller.dispose();
    option2Controller.dispose();
    option3Controller.dispose();
    option4Controller.dispose();
  }
}
import 'package:flutter/material.dart';

class CreateQuizPage extends StatelessWidget {
  const CreateQuizPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz Game')),
      body: const Center(child: Text('Quiz Game Creator')),
    );
  }
}
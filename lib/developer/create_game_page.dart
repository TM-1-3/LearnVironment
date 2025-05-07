import 'package:flutter/material.dart';

class CreateGamePage extends StatelessWidget {
  const CreateGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game'),
      ),
      body: const Center(
        child: Text(
          'Create a New Game',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

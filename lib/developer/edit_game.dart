import 'package:flutter/material.dart';

class EditGame extends StatelessWidget {
  final String gameId;

  const EditGame({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Game'),
      ),
      body: Center(
        child: Text(
          gameId,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

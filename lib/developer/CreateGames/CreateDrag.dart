import 'package:flutter/material.dart';

class CreateDragPage extends StatelessWidget {
  const CreateDragPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Drag Game')),
      body: const Center(child: Text('Drag Game Creator')),
    );
  }
}
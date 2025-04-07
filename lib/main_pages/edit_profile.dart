import 'dart:io';
import 'package:flutter/material.dart';

class EditProfileWidget extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final Function(String, String) onSave;
  final Function pickImage;
  final File? imageFile;

  const EditProfileWidget({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.onSave,
    required this.pickImage,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            pickImage();
          },
          child: CircleAvatar(
            radius: 100,
            backgroundImage: imageFile != null
                ? FileImage(imageFile!)
                : AssetImage('assets/placeholder.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            String newUsername = usernameController.text.trim();
            String newEmail = emailController.text.trim();
            onSave(newUsername, newEmail);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
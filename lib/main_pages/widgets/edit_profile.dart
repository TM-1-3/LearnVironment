import 'dart:io';

import 'package:flutter/material.dart';

class EditProfileWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final DateTime? birthDate;
  final List<String> accountTypes;
  final String? selectedAccountType;
  final void Function(String name, String username, String email, DateTime? birthDate, String? accountType) onSave;
  final VoidCallback pickImage;
  final File? imageFile;
  final VoidCallback pickBirthDate;
  final ValueChanged<String?> onAccountTypeChanged;

  const EditProfileWidget({
    super.key,
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.onSave,
    required this.pickImage,
    required this.imageFile,
    required this.birthDate,
    required this.pickBirthDate,
    required this.accountTypes,
    required this.selectedAccountType,
    required this.onAccountTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: pickImage,
          child: CircleAvatar(
            radius: 100,
            backgroundImage: imageFile != null
                ? FileImage(imageFile!)
                : const AssetImage('assets/placeholder.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        GestureDetector(
          onTap: pickBirthDate,
          child: AbsorbPointer(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Birthdate',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: birthDate == null
                    ? ''
                    : '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedAccountType,
          decoration: const InputDecoration(labelText: 'Account Type'),
          items: accountTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: onAccountTypeChanged,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            onSave(
              nameController.text.trim(),
              usernameController.text.trim(),
              emailController.text.trim(),
              birthDate,
              selectedAccountType,
            );
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

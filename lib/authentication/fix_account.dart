import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FixAccountPage extends StatefulWidget {
  const FixAccountPage({super.key});

  @override
  State<FixAccountPage> createState() => _FixAccountPageState();
}

class _FixAccountPageState extends State<FixAccountPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Selected userType for the dropdown
  String? _selectedUserType;

  // Options for the dropdown menu
  final List<String> _userTypes = ['developer', 'student', 'teacher'];

  // Function to sign out the user
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // Replace with your login route
  }

  // Function to update or create the user's document in Firestore
  Future<void> updateUserType(String uid, String userType) async {
    try {
      final userDoc = firestore.collection('users').doc(uid);

      // Check if the document exists
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        // Update the existing document
        await userDoc.update({'role': userType});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User type updated successfully!')),
        );
      } else {
        // Create a new document with the uid and role
        await userDoc.set({'role': userType});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User type created successfully!')),
        );
      }

      // Redirect back to AuthGate
      Navigator.of(context).pushReplacementNamed('/auth_gate');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user type: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnVironment'), // App's default AppBar
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ups! It seems your account data is corrupted. Please select an appropriate account type from the dropdown menu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select your account type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedUserType,
              hint: const Text('Choose an account type'),
              items: _userTypes.map((String userType) {
                return DropdownMenuItem<String>(
                  value: userType,
                  child: Text(userType),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUserType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (user != null && _selectedUserType != null) {
                  updateUserType(user.uid, _selectedUserType!);
                } else {
                  // Show an error dialog if no selection is made
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Selection'),
                        content: const Text('Please select an account type before proceeding.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Save and Continue'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

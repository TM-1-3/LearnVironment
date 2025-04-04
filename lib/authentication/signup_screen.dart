import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedAccountType;
  final List<String> _accountTypes = ['developer', 'student', 'teacher'];

  void _showEmailVerificationDialog(User? user) {
    if (user == null) return; // Ensure user is not null

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal without action
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Your Email'),
          content: const Text(
            'A verification email has been sent to your email address. Please verify your email to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await user.reload(); // Reload user data to fetch the latest verification status
                if (user.emailVerified) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email verified for ${user
                          .email}! You can now log in.')),
                    );
                    Navigator.of(context).pushReplacementNamed('/login'); // Navigate to the login page
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(
                          'Email not verified yet. Please check your inbox.')),
                    );
                  }
                }
              },
              child: const Text('I Verified My Email'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await user.sendEmailVerification(); // Resend email verification
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          'Verification email resent to ${user.email}!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error resending verification email.')),
                    );
                  }
                }
              },
              child: const Text('Resend Email'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel and close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerUser() async {
    try {
      // Retrieve user input
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String username = _usernameController.text.trim();

      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || username.isEmpty || _selectedAccountType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
        return;
      }

      // Register the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the display name for the user in Firebase Authentication
      await userCredential.user?.updateDisplayName(username);

      // Save user information to Firestore
      await FirebaseFirestore.instance
          .collection('users') // Target the 'users' collection
          .doc(userCredential.user?.uid) // Use the user's UID as the document ID
          .set({
        'username': username,           // Set the username
        'role': _selectedAccountType,   // Set the account type/role
        'email': email,                 // (Optional) Save the email for reference
      });

      // Send the email verification
      await userCredential.user?.sendEmailVerification();

      // Inform the user the account was created and prompt them to verify
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Account created successfully! Please verify your email.')),
        );
      }

      // Open the email verification dialog
      _showEmailVerificationDialog(userCredential.user);
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during sign-up: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username Input Field
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: 16),
            // Email Input Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
              ),
            ),
            const SizedBox(height: 16),
            // Password Input Field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Confirm Password Input Field
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Account Type Dropdown
            DropdownButton<String>(
              value: _selectedAccountType,
              hint: const Text('Select Account Type'),
              items: _accountTypes.map((String accountType) {
                return DropdownMenuItem<String>(
                  value: accountType,
                  child: Text(
                    accountType,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal, // Ensure normal font weight
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAccountType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            // Register Button
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Register'),
            ),
            const SizedBox(height: 16),
            // Link to Login Page
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(
                  'Already have an account? Log in here.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  bool _isButtonEnabled = true; // Track button enabled/disabled state

  Future<void> _registerUser() async {
    try {
      // Retrieve user input
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String username = _usernameController.text.trim();

      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty ||
          username.isEmpty || _selectedAccountType == null) {
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

      // Disable the register button to prevent multiple clicks
      setState(() {
        _isButtonEnabled = false;
      });

      // Register the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
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
        'username': username, // Set the username
        'role': _selectedAccountType, // Set the account type/role
        'email': email, // (Optional) Save the email for reference
      });

      // Send the email verification
      await userCredential.user?.sendEmailVerification();

      // Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Account created successfully! Please verify your email.')),
        );
      }

      // Go to the next page
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth_gate');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code;

      switch (e.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          errorMessage = "Email already used. Use login page.";
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          errorMessage = "Wrong email/password combination.";
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          errorMessage = "No user found with this email.";
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          errorMessage = "User disabled.";
        case "ERROR_TOO_MANY_REQUESTS":
        case "ERROR_OPERATION_NOT_ALLOWED":
        case "operation-not-allowed":
          errorMessage = "Too many requests to log into this account.";
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          errorMessage = "Email address is invalid.";
        default:
          errorMessage = "Registering failed. Please try again.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      // Re-enable the button after the operation is complete
      setState(() {
        _isButtonEnabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: Image.asset('assets/icon.png'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedAccountType,
                hint: const Text('Select Account Type'),
                items: _accountTypes.map((String accountType) {
                  return DropdownMenuItem<String>(
                    value: accountType,
                    child: Text(accountType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAccountType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _registerUser : null,
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text(
                    'Already have an account? Log in here.',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

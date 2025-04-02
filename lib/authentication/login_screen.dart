import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/authentication/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleLogin() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in both fields.')),
        );
        return;
      }

      // Check if the email exists
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isEmpty) {
        // Email does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No account exists for this email. Please create an account.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
        return;
      }

      // Attempt to log in
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged in!')),
        );

        // Navigate to the home page (implement your home page logic here)
      } on FirebaseAuthException catch (loginError) {
        // Map Firebase error codes to user-friendly messages
        String errorMessage;
        switch (loginError.code) {
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
          case 'user-not-found':
            errorMessage = 'No account found for this email.';
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
          case 'too-many-requests':
            errorMessage = 'Too many login attempts. Please try again later.';
          default:
            errorMessage = 'An unexpected error occurred. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Icon at the top
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset('assets/placeholder.png'),
              ),
              const SizedBox(height: 20),
              // Welcome Message
              const Text(
                'Welcome to LearnVironment',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              // Registration Link
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Don’t have an account? Register here.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
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

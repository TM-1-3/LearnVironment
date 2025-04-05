import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseAuth auth;

  LoginScreen({super.key, FirebaseAuth? auth})
      : auth = auth ?? FirebaseAuth.instance;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Use the passed FirebaseAuth instance (or default to FirebaseAuth.instance)
  FirebaseAuth get _auth => widget.auth;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in both fields.')),
        );
        return;
      }

      // Directly attempt to log in
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged in!')),
        );
      }
      // Navigate to home page here if necessary

      // Clear the text fields after a successful login
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code;

      switch (e.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          errorMessage = "Email already used. Go to login page.";
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
          errorMessage = "Login failed. Please try again.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                aspectRatio: 2,
                child: Image.asset('assets/icon.png'),
              ),
              const SizedBox(height: 20),
              // Welcome Message
              const Text(
                'Welcome to LearnVironment',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
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
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              // Registration Link
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/signup');
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
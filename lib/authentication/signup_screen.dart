import 'package:flutter/material.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/firestore_service.dart';

class SignUpScreen extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  SignUpScreen({super.key, AuthService? authService, FirestoreService? firestoreService})
      : authService = authService ?? AuthService(),
        firestoreService = firestoreService ?? FirestoreService();

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthDate;

  String? _selectedAccountType;
  final List<String> _accountTypes = ['developer', 'student', 'teacher'];
  bool _isButtonEnabled = true;

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _registerUser() async {
    setState(() {
      _isButtonEnabled = false;
    });
    try {
      // Retrieve user input
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String username = _usernameController.text.trim();
      String name = _nameController.text.trim();

      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty ||
          username.isEmpty || name.isEmpty || _birthDate == null || _selectedAccountType == null) {
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

      String? uid = await widget.authService.registerUser(username: username, email: email, password: password);

      if (uid == null) {
        throw Exception("Error registering user");
      }

      await widget.firestoreService.registerUser(
        uid: uid,
        name: name,
        username: username,
        email: email,
        selectedAccountType: _selectedAccountType ?? '',
        birthDate: _birthDate!.toIso8601String(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Please verify your email.')),
        );
      }

      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _usernameController.clear();
      _nameController.clear();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth_gate');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
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
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                key: ValueKey('birthDate'),
                onTap: _pickBirthDate,
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Birthdate',
                      hintText: 'Select your birthdate',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _birthDate == null
                          ? ''
                          : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
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

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'authentication/auth_service.dart'; // Import AuthService

class ProfileScreen extends StatefulWidget {
  final AuthService authService; // Receive AuthService via constructor

  const ProfileScreen({super.key, required this.authService});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _isEditing = false;
  late TextEditingController usernameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    _loadImagePath();
    _loadUserProfile();
  }

  Future<void> _loadImagePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.jpg';
    final imageFile = File(imagePath);

    if (imageFile.existsSync()) {
      setState(() {
        _imagePath = imagePath;
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        usernameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _updateProfile(String newUsername, String newEmail) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorDialog("No user is logged in.");
        return;
      }

      if (newEmail != user.email) {
        await _updateEmail(user, newEmail);
      }

      if (newUsername != user.displayName) {
        await user.updateProfile(displayName: newUsername);
      }

      await user.reload();

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      _showErrorDialog("Error updating profile. Please try again.");
    }
  }

  Future<void> _updateEmail(User user, String newEmail) async {
    try {
      String password = await _promptForPassword();
      if (password.isEmpty) return;

      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);

      _showErrorDialog(
          "A verification email has been sent to your new email. Please verify it.");
    } catch (e) {
      _showErrorDialog(
          "Error updating email. Please check the email and try again.");
    }
  }

  Future<String> _promptForPassword() async {
    String password = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Reauthentication required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to confirm:'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                password = passwordController.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return password;
  }

  Future<void> _deleteAccount() async {
    try {
      await widget.authService
          .deleteAccount(); // Use AuthService for account deletion
      Navigator.of(context).pushReplacementNamed('/signup');
    } catch (e) {
      _showErrorDialog("Error deleting account. Please try again.");
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
              'This will permanently delete your account. Do you want to proceed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteAccount();
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.authService.signOut(); // Use AuthService for signing out
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      _showErrorDialog("Error signing out. Please try again.");
    }
  }

  Future<bool> _onWillPop() async {
    if (_isEditing) {
      return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
                'You have unsaved changes. Do you want to leave without saving?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          );
        },
      ) ?? false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      await _saveImageLocally(image);
    }
  }

  Future<void> _saveImageLocally(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_image.jpg';
      final localImage = File(imagePath);
      await localImage.writeAsBytes(await image.readAsBytes());
      setState(() {
        _imagePath = imagePath;
        _imageFile = localImage;
      });
    } catch (e) {
      print("Error saving image locally: $e");
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: !_isEditing
                    ? CircleAvatar(
                  radius: 100,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : user?.photoURL != null
                      ? NetworkImage(user?.photoURL ?? '')
                      : const AssetImage(
                      'assets/placeholder.png') as ImageProvider,
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              if (_isEditing) ...[
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateProfile(
                      usernameController.text.trim(),
                      emailController.text.trim(),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ],
              if (!_isEditing) ...[
                // Display the user's username
                Text(
                  user?.displayName ?? 'Username',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Display the user's email
                Text(
                  user?.email ?? 'Email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                // Sign Out button
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Sign Out'),
                ),
                const SizedBox(height: 20),
                // Delete Account button
                ElevatedButton.icon(
                  onPressed: _showDeleteAccountDialog,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
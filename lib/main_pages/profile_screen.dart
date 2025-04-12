import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learnvironment/main_pages/edit_profile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  final FirebaseAuth auth;

  ProfileScreen({
    super.key,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

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
    final imagePath = '${directory.path}/profile_image.jpg'; // Custom file name
    final imageFile = File(imagePath);

    if (imageFile.existsSync()) {
      setState(() {
        _imagePath = imagePath;
        _imageFile = imageFile; // Load the image file
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      setState(() {
        usernameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _updateProfile(String newUsername, String newEmail) async {
    try {
      User? user = widget.auth.currentUser;

      if (user == null) {
        _showErrorDialog("No user is logged in.", "Error");
        return;
      }

      // Only update the email if it has changed
      if (newEmail != user.email) {
        await _updateEmail(user, newEmail);  // Update the email in Firebase
      }

      // Update the username (display name) only if it has changed
      if (newUsername != user.displayName) {
        await user.updateProfile(displayName: newUsername);
      }

      // Reload the user to reflect the changes
      await user.reload();
      user = widget.auth.currentUser; // Get the updated user

      // After reloading, update the local controllers to reflect the changes
      setState(() {
        usernameController.text = user?.displayName ?? ''; // Update username
        emailController.text = user?.email ?? ''; // Update email in the UI
        _isEditing = false; // Exit edit mode
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved.')),
        );
      }

    } catch (e) {
      print("Error updating profile: $e");
      _showErrorDialog("Error updating profile. Please try again.", "Error");
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

      // Only update the email if the new email is different from the current one
      if (newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail); // Update email in Firebase
        print("Email updated successfully.");

        // Send verification email only if the email is not already verified
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          _showErrorDialog("A verification email has been sent to $newEmail. Please verify it.", "Warning");
        }
      }
    } catch (e) {
      print("Error updating email: $e");
      _showErrorDialog("Error updating email. Please check the email and try again.", "Error");
    }
  }


  Future<String> _promptForPassword() async {
    String password = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Re-authentication required'),
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
      await widget.auth.currentUser?.delete();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/signup');
      }
    } catch (e) {
      _showErrorDialog("Error deleting account. Please try again.", "Error");
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This will permanently delete your account. Do you want to proceed?'),
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
    await widget.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<bool?> _onWillPop() async {
    if (_isEditing) {
      return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text('You have unsaved changes. Do you want to leave without saving?'),
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
    return true; // Allow leaving if not editing
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message, String ctx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ctx),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser;

    return PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _onWillPop() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }},
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
              // Show profile image and info
              Center(
                child: !_isEditing
                    ? GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : user?.photoURL != null
                        ? NetworkImage(user?.photoURL ?? '')
                        : AssetImage('assets/placeholder.png') as ImageProvider,
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              if (_isEditing)
                EditProfileWidget(
                  usernameController: usernameController,
                  emailController: emailController,
                  onSave: (newUsername, newEmail) {
                    _updateProfile(newUsername, newEmail);
                  },
                  pickImage: _pickImage,
                  imageFile: _imageFile,
                ),
              if (!_isEditing) ...[
                Text(
                  user?.displayName ?? 'Username',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? 'Email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Sign Out'),
                ),
                const SizedBox(height: 20),
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

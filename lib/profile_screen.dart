import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final AuthService authService;

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

  // Function to load the profile image from local storage (if exists)
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

  // Function to load the user's profile (displayName and email)
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        usernameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
      });
    }
  }

  // Function to update the user's profile details (username, email)
  Future<void> _updateProfile(String newUsername, String newEmail) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("No user is logged in");
        _showErrorDialog("No user is logged in.");
        return;
      }

      // Only update the email if it is changed
      if (newEmail != user.email) {
        // Handle email update
        await _updateEmail(user, newEmail);
      }

      // Update the username (display name) only if changed
      if (newUsername != user.displayName) {
        await user.updateProfile(displayName: newUsername);
        print("Username updated successfully.");
      }

      // Reload the user to reflect the changes
      await user.reload();

      // After reloading, update the UI state to reflect the changes
      setState(() {
        _isEditing = false; // Exit edit mode
      });

      print("Profile updated successfully!");
    } catch (e) {
      print("Error updating profile: $e");
      _showErrorDialog("Error updating profile. Please try again.");
    }
  }

  // Function to update email (requires re-authentication if email is unverified)
  Future<void> _updateEmail(User user, String newEmail) async {
    try {
      // Ask for the user's password to reauthenticate
      String password = await _promptForPassword();
      if (password.isEmpty) return;

      // Perform reauthentication
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail); // Proceed with email update
      print("Email updated successfully.");

      // After updating the email, send the verification email
      await user.sendEmailVerification();
      print("Verification email sent to $newEmail");

      // You can then prompt the user to check their email
      _showErrorDialog("A verification email has been sent to your new email. Please verify it.");
    } catch (e) {
      print("Error updating email: $e");
      _showErrorDialog("Error updating email. Please check the email and try again.");
    }
  }

  // Function to prompt the user for their password
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

  // Function to handle account deletion
  Future<void> _deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  // Function to show the confirmation dialog for account deletion
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

  // Function to sign out the user
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  // Function to show a confirmation dialog before leaving if there are unsaved changes
  Future<bool> _onWillPop() async {
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
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

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      await _saveImageLocally(image);
    }
  }

  // Function to save the image locally
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

      print('Image saved locally at: $imagePath');
    } catch (e) {
      print("Error saving image locally: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopScope(
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
                    ? CircleAvatar(
                  radius: 100,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : user?.photoURL != null
                      ? NetworkImage(user?.photoURL ?? '')
                      : AssetImage('assets/placeholder.png')
                  as ImageProvider,
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

// EditProfileWidget class
class EditProfileWidget extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final Function(String, String) onSave;
  final Function pickImage;
  final File? imageFile;

  const EditProfileWidget({
    Key? key,
    required this.usernameController,
    required this.emailController,
    required this.onSave,
    required this.pickImage,
    this.imageFile,
  }) : super(key: key);

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
                : AssetImage('assets/default_profile_picture.png')
            as ImageProvider,
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

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/main_pages/widgets/edit_profile.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

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

  // Fetch the current user profile data from FirebaseAuth
  Future<void> _loadUserProfile() async {
    DataService dataService = Provider.of<DataService>(context, listen: false);
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    UserData? userData = await dataService.getUserData(
        await authService.getUid());
    if (userData != null) {
      setState(() {
        usernameController.text = userData.username;
        emailController.text = userData.email;
      });
    } else {
      _showErrorDialog("Error getting user", "Error");
    }
  }

  // Update profile (both email and display name)
  Future<void> _updateProfile(String newUsername, String newEmail) async {
    try {
      DataService dataService = Provider.of<DataService>(
          context, listen: false);
      AuthService authService = Provider.of<AuthService>(
          context, listen: false);
      UserData? userData = await dataService.getUserData(
          await authService.getUid());

      if (userData == null) {
        _showErrorDialog("No user is logged in.", "Error");
        return;
      }

      // Only update the email if it has changed
      if (newEmail != userData.email) {
        await _updateEmail(newEmail); // Update the email in Firebase
      }

      // Update the username (display name) only if it has changed
      if (newUsername != userData.username) {
        await _updateUsername(newUsername);
      }

      userData = await dataService.getUserData(await authService.getUid());
      setState(() {
        usernameController.text = userData?.username ?? ''; // Update username
        emailController.text = userData?.email ?? ''; // Update email in the UI
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

  // Update username
  Future<void> _updateUsername(newUsername) async {
    try {
      if (mounted) {
        DataService dataService = Provider.of<DataService>(context, listen: false);
        AuthService authService = Provider.of<AuthService>(context, listen: false);

        //Change data in dataService

        //Change data in authService
        authService.updateUsername(newUsername);
      }
    } catch (e) {
      print("Error updating email: $e");
      _showErrorDialog("Error updating username.", "Error");
    }
  }

  // Update email address
  Future<void> _updateEmail(String newEmail) async {
    try {
      String password = await _promptForPassword();
      if (password.isEmpty) return;

      if (mounted) {
        DataService dataService = Provider.of<DataService>(
            context, listen: false);
        AuthService authService = Provider.of<AuthService>(
            context, listen: false);

        //Change data in dataService

        //Change data in authService
        authService.updateEmail(newEmail, password);
      }
    } catch (e) {
      print("Error updating email: $e");
      _showErrorDialog(
          "Error updating email. Please check the email and try again.",
          "Error");
    }
    _showErrorDialog(
        "A verification email has been sent to $newEmail. Please verify it.",
        "Warning");
  }

  // Prompt for password to confirm email change
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

  // Delete account function
  Future<void> _deleteAccount() async {
    try {
      DataService dataService = Provider.of<DataService>(context, listen: false);
      AuthService authService = Provider.of<AuthService>(context, listen: false);
      String uid = await authService.getUid();

      //Delete account in authService
      await authService.deleteAccount();
      //Delete account from Firestore and cache using dataService
      await dataService.deleteAccount(uid);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/signup');
      }
    } catch (e) {
      _showErrorDialog("Error deleting account. Please try again.", "Error");
    }
  }

  // Show the confirmation dialog before deleting account
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

  // Sign out the user
  Future<void> _signOut() async {
    UserCacheService userCacheService = Provider.of<UserCacheService>(context, listen: false);
    AuthService authService = Provider.of<AuthService>(context, listen: false);

    //Delete the cache
    await userCacheService.clearUserCache();

    //sign-out
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // Handle the back button press with unsaved changes warning
  Future<bool?> _onWillPop() async {
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
    return true; // Allow leaving if not editing
  }

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Show error dialogs
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

  // Pick profile image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      await _saveImageLocally(image);
    }
  }

  // Save selected image locally
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
    DataService dataService = Provider.of<DataService>(context, listen: false);
    AuthService authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<UserData?>(
      future: authService.getUid().then((uid) => dataService.getUserData(uid)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading user data."));
        }

        final userData = snapshot.data;

        return Scaffold(
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
                      ? GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/placeholder.png'),
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
                    userData?.username ?? 'Username',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData?.email ?? 'Email',
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
        );
      },
    );
  }
}
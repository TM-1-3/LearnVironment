import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final AuthService authService;

  const ProfileScreen({super.key, required this.authService});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      // Upload the image to Firebase Storage
      await _uploadImageToFirebase(image);
    }
  }

  // Function to upload image to Firebase Storage
  Future<void> _uploadImageToFirebase(XFile image) async {
    try {
      // Create a unique filename for the image
      String fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the image to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(image.path));

      // Get the download URL of the uploaded image
      String downloadURL = await ref.getDownloadURL();

      // Optionally, update the user's profile photo URL in Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadURL);
        setState(() {
          user.reload(); // Refresh the user data after updating
        });
      }
    } catch (e) {
      print("Error uploading image: $e");
      // Handle any errors (e.g., network issues)
    }
  }

  // Function to handle account deletion
  Future<void> _deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : user?.photoURL != null
                  ? NetworkImage(user?.photoURL ?? '')
                  : AssetImage('assets/placeholder.png') as ImageProvider,
              radius: 30,
            ),
            title: Text(user?.displayName ?? 'John Doe'),
            subtitle: Text(user?.email ?? 'john.doe@example.com'),
            onTap: _pickImage, // Allow user to pick a new profile picture
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await widget.authService.signOut();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Account'),
            onTap: () async {
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

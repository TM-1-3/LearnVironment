import 'package:flutter/material.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/main_pages/edit_profile_screen.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Fetch the current user profile data from FirebaseAuth
  Future<void> _loadUserProfile() async {
    DataService dataService = Provider.of<DataService>(context, listen: false);
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    UserData? userData = await dataService.getUserData(userId: await authService.getUid());

    if (userData == null) {
      _showErrorDialog("Error getting user", "Error");
    }
    print("[PROFILE] User data loaded with success.");
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
      await dataService.deleteAccount(uid: uid);

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

  @override
  Widget build(BuildContext context) {
    DataService dataService = Provider.of<DataService>(context, listen: false);
    AuthService authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<UserData?>(
      future: authService.getUid().then((uid) => dataService.getUserData(userId: uid)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading user data."));
        }

        final userData = snapshot.data;
        if (userData == null) {
          throw Exception("No user loged in");
        }

        return Scaffold(
            appBar: AppBar(
              title: const Text('User Profile'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/auth_gate');
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditProfilePage(userData: userData)));
                  },
                ),
              ],
            ),
            body: Center(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 20),
                    Text(
                      userData.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userData.username,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userData.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Birthdate: ${userData.birthdate.year}-${userData.birthdate.month.toString().padLeft(2, '0')}-${userData.birthdate.day.toString().padLeft(2, '0')}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Account Type: ${userData.role}',
                      textAlign: TextAlign.center,
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
              ),
            ),
        );
      },
    );
  }
}
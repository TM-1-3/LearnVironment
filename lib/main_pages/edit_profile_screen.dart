import 'package:flutter/material.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/main_pages/profile_screen.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  final UserData userData;

  EditProfilePage({
    required this.userData,
    super.key,
  });

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  bool _isSaved = true;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController imgController;
  late DateTime _birthDate;
  late String _selectedAccountType;
  final List<String> _accountTypes = ['developer', 'student', 'teacher'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData.name);
    usernameController = TextEditingController(text: widget.userData.username);
    emailController = TextEditingController(text: widget.userData.email);
    String temp = widget.userData.img;
    if (temp == "assets/placeholder.png") {
      temp = "";
    }
    imgController = TextEditingController(text: temp);
    _birthDate = widget.userData.birthdate;
    _selectedAccountType = widget.userData.role;

    nameController.addListener(_onTextChanged);
    usernameController.addListener(_onTextChanged);
    emailController.addListener(_onTextChanged);
    imgController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_isSaved) {
      setState(() {
        _isSaved = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    imgController.dispose();
    super.dispose();
  }

  Future<bool> _validateImage(String imageUrl) async {
    http.Response res;
    try {
      res = await http.get(Uri.parse(imageUrl));
    } catch (e) {
      return false;
    }
    if (res.statusCode != 200) return false;
    Map<String, dynamic> data = res.headers;
    if (data['content-type'] == 'image/jpeg' || data['content-type'] == 'image/png' || data['content-type'] == 'image/gif') {
      return true;
    } else {
      return false;
    }
  }

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
        _isSaved = false;
      });
    }
  }

  Future<void> _updateProfile({
  required String name,
  required String username,
  required String email,
  required DateTime birthDate,
  required String accountType,
  required String img,
  required String uid}) async {
    try {
      DataService dataService = Provider.of<DataService>(context, listen: false);
      AuthService authService = Provider.of<AuthService>(context, listen: false);
      UserData? userData = await dataService.getUserData(userId: uid);

      if (userData == null) {
        _showErrorDialog("No user is logged in.", "Error");
        return;
      }

      if (email != userData.email) {
        try {
          String password = await _promptForPassword();
          if (password.isEmpty) throw Exception("Empty Password.");

          if (mounted) {
            authService.updateEmail(newEmail: email, password: password);
          }
        } catch (e) {
          print("Error updating email: $e");
          _showErrorDialog("Error updating email. Please check the email and try again.", "Error");
        }
        _showErrorDialog("A verification email has been sent to $email. Please verify it.", "Warning");
      }

      if (username != userData.username) {
        try {
          if (mounted) {
            authService.updateUsername(newUsername: username);
          }
        } catch (e) {
          print("Error updating email: $e");
          _showErrorDialog("Error updating username.", "Error");
        }
      }

      if (!await _validateImage(img)) {
        img = "assets/placeholder.png";
      }

      await dataService.updateUserProfile(
        uid: uid,
        name: name,
        username: username,
        email: email,
        birthDate: birthDate.toIso8601String(),
        role: accountType,
        img: img
      );

      setState(() {
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved.')),
        );
      }

      nameController.clear();
      usernameController.clear();
      emailController.clear();
      imgController.clear();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
      }
    } catch (e) {
      print("Error updating profile: $e");
      _showErrorDialog("Error updating profile. Please try again.", "Error");
    }
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

  Future<bool?> _onWillPop() async {
    if (!_isSaved) {
      return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
                'You have unsaved changes. Do you want to leave without saving?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          );
        },
      ) ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isSaved,
      onPopInvokedWithResult: (didPop, result) async {
        if (!_isSaved && !didPop) {
          final shouldLeave = await _onWillPop();
          if (shouldLeave! && context.mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),
    Column(
      children: [
        TextField(
          controller: imgController,
          decoration: const InputDecoration(labelText: 'Profile Image URL')
        ),
        const SizedBox(height: 20),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        GestureDetector(
          key: Key("birthDate"),
          onTap: _pickBirthDate,
          child: AbsorbPointer(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Birthdate',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: '${_birthDate.year}-${_birthDate.month.toString().padLeft(2, '0')}-${_birthDate.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedAccountType,
          decoration: const InputDecoration(labelText: 'Account Type'),
          items: _accountTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedAccountType = newValue;
                _isSaved = false;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _updateProfile(
              name: nameController.text.trim(),
              username: usernameController.text.trim(),
              email: emailController.text.trim(),
              birthDate: _birthDate,
              accountType: _selectedAccountType,
              img: imgController.text.trim(),
              uid: widget.userData.id
            );
          },
          child: const Text('Save Changes'),
        ),
      ],
          ),
        ]),
      ),
    ));
  }
}
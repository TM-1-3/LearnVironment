import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learnvironment/main_pages/game_data.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'authentication/auth_service.dart';

class BinScreen extends StatefulWidget {
  final GameData gameData;

  const BinScreen({super.key, required this.gameData});

  @override
  BinScreenState createState() => BinScreenState();
}

class BinScreenState extends State<BinScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  List<Widget> draggableImages = [];

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    _loadImagePath();
    _initializeDraggableImages();
  }

  Future<void> _loadImagePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/placeholder.png';
      final imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        setState(() {
          _imageFile = imageFile;
        });
      }
    } catch (e) {
      print("Error loading image: $e");
    }
  }

  void _initializeDraggableImages() {
    draggableImages = List.generate(3, (index) => _buildDraggableImage(index));
  }

  Widget _buildDraggableImage(int index) {
    return Draggable<int>(
      data: index,
      feedback: CircleAvatar(
        radius: 45,
        backgroundImage: AssetImage('assets/placeholder.png'),
      ),
      childWhenDragging: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage('assets/placeholder.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async => !_isEditing,
      child: Scaffold(
        appBar: AppBar(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : user?.photoURL != null
                ? NetworkImage(user?.photoURL ?? '')
                : AssetImage('assets/placeholder.png') as ImageProvider,
          ),
          title: Text('Recycling Bin'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => CircleAvatar(
                radius: 150,
                backgroundImage: AssetImage('assets/green_bin.png'),
              )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) => CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/placeholder.png'),
              )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: draggableImages,
            ),
          ],
        ),
      ),
    );
  }
}

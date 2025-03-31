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
  Map<int, Offset> trashPositions = {};

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    _loadImagePath();
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

  Widget _buildDraggableTrash(int index) {
    return Draggable<int>(
      data: index,
      feedback: Image.asset('assets/trash1.png', width: 80),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Image.asset('assets/trash1.png', width: 80),
      ),
      onDraggableCanceled: (velocity, offset) {
        setState(() => trashPositions[index] = offset);
      },
      child: Positioned(
        left: trashPositions[index]?.dx ?? 0,
        top: trashPositions[index]?.dy ?? 0,
        child: Image.asset('assets/trash1.png', width: 80),
      ),
    );
  }

  Widget _buildBinRow(List<String> assets) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: assets.map((path) => Image.asset(path, width: 100)).toList(),
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
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : user?.photoURL != null
                ? NetworkImage(user?.photoURL ?? '')
                : AssetImage('assets/placeholder.png'),
          ),
          title: Text('Recycling Bin'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBinRow(['assets/green_bin.png', 'assets/green_bin.png', 'assets/blue_bin.png']),
            _buildBinRow(['assets/brown_bin.png', 'assets/red_bin.png']),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, _buildDraggableTrash),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) => _buildDraggableTrash(index + 3)),
            ),
          ],
        ),
      ),
    );
  }
}
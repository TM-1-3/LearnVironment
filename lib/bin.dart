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
  bool isBlueBinOpen = false;

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
            // First Row: 3 Bins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/green_bin.png', width: 100),
                DragTarget<String>(
                  onWillAccept: (data) {
                    setState(() => isBlueBinOpen = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => isBlueBinOpen = false);
                  },
                  onAccept: (data) {
                    setState(() => isBlueBinOpen = false);
                  },
                  builder: (context, candidateData, rejectedData) => Image.asset(
                    isBlueBinOpen ? 'assets/open_blue_bin.png' : 'assets/blue_bin.png',
                    width: 100,
                  ),
                ),
                Image.asset('assets/green_bin.png', width: 100),
              ],
            ),

            // Second Row: 2 Bins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/brown_bin.png', width: 100),
                Image.asset('assets/red_bin.png', width: 100),
              ],
            ),

            // Third Row: 3 Trash
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => Draggable<String>(
                data: 'trash',
                feedback: Image.asset('assets/trash1.png', width: 80),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: Image.asset('assets/trash1.png', width: 80),
                ),
                child: Image.asset('assets/trash1.png', width: 80),
              )),
            ),

            // Fourth Row: 2 Trash
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) => Draggable<String>(
                data: 'trash',
                feedback: Image.asset('assets/trash1.png', width: 80),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: Image.asset('assets/trash1.png', width: 80),
                ),
                child: Image.asset('assets/trash1.png', width: 80),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

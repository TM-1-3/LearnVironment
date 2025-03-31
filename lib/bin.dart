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

  // Bin States
  bool isBlueBinOpen = false;
  bool isGreenBinOpen = false;
  bool isYellowBinOpen = false;
  bool isBrownBinOpen = false;
  bool isRedBinOpen = false;

  // List to track trash items
  List<String> trashItems = ["trash1", "trash2", "trash3", "trash4", "trash5"];

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

  void removeTrashItem(String item) {
    setState(() {
      trashItems.remove(item);
    });
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
                DragTarget<String>(
                  onWillAccept: (data) {
                    setState(() => isGreenBinOpen = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => isGreenBinOpen = false);
                  },
                  onAccept: (data) {
                    removeTrashItem(data!);
                    setState(() => isGreenBinOpen = false);
                  },
                  builder: (_, __, ___) => Image.asset(
                    isGreenBinOpen ? 'assets/open_green_bin.png' : 'assets/green_bin.png',
                    width: 100,
                  ),
                ),
                DragTarget<String>(
                  onWillAccept: (data) {
                    setState(() => isBlueBinOpen = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => isBlueBinOpen = false);
                  },
                  onAccept: (data) {
                    removeTrashItem(data!);
                    setState(() => isBlueBinOpen = false);
                  },
                  builder: (_, __, ___) => Image.asset(
                    isBlueBinOpen ? 'assets/open_blue_bin.png' : 'assets/blue_bin.png',
                    width: 100,
                  ),
                ),
                DragTarget<String>(
                  onWillAccept: (data) {
                    setState(() => isYellowBinOpen = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => isYellowBinOpen = false);
                  },
                  onAccept: (data) {
                    removeTrashItem(data!);
                    setState(() => isYellowBinOpen = false);
                  },
                  builder: (_, __, ___) => Image.asset(
                    isYellowBinOpen ? 'assets/open_yellow_bin.png' : 'assets/green_bin.png',
                    width: 100,
                  ),
                ),
              ],
            ),

            // Second Row: 2 Bins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DragTarget<String>(
                  onWillAccept: (data) {
                    setState(() => isBrownBinOpen = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => isBrownBinOpen = false);
                  },
                  onAccept: (data) {
                    removeTrashItem(data!);
                    setState(() => isBrownBinOpen = false);
                  },
                  builder: (_, __, ___) => Image.asset(
                    isBrownBinOpen ? 'assets/open_brown_bin.png' : 'assets/brown_bin.png',
                    width: 100,
                  ),
                ),
                DragTarget<String>(
                  onWillAccept: (data) {
                    setState(() => isRedBinOpen = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => isRedBinOpen = false);
                  },
                  onAccept: (data) {
                    removeTrashItem(data!);
                    setState(() => isRedBinOpen = false);
                  },
                  builder: (_, __, ___) => Image.asset(
                    isRedBinOpen ? 'assets/open_red_bin.png' : 'assets/red_bin.png',
                    width: 100,
                  ),
                ),
              ],
            ),

            // Third & Fourth Rows: Draggable Trash
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: trashItems
                  .map((item) => Draggable<String>(
                data: item,
                feedback: Image.asset('assets/trash1.png', width: 80),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: Image.asset('assets/trash1.png', width: 80),
                ),
                child: Image.asset('assets/trash1.png', width: 80),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

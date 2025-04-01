import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'auth_service.dart';

class BinScreen extends StatefulWidget {
  final AuthService authService;

  const BinScreen({super.key, required this.authService});

  @override
  BinScreenState createState() => BinScreenState();
}

class BinScreenState extends State<BinScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  late TextEditingController usernameController;
  late TextEditingController emailController;

  // Bin states stored in a Map
  Map<String, bool> binStates = {
    "blue": false,
    "green": false,
    "yellow": false,
    "brown": false,
    "red": false,
  };

  bool showIcon = false;
  bool rightAnswer = true;
  Offset iconPosition = Offset(0, 0);

  // Trash items mapped to their correct bin
  Map<String, String> trashItems = {
    "trash1": "brown",
    "trash2": "red",
    "trash3": "yellow",
    "trash4": "blue",
  };

  Map<String, String> remainingTrashItems = {
    "trash5": "green",
    "trash6": "blue",
    "trash7": "red",
    "trash8": "green",
    "trash9": "yellow",
    "trash10": "brown",
  };

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

  void removeTrashItem(String item, String bin, Offset position) {
    setState(() {
      // Check if the item was placed in the correct bin
      rightAnswer = trashItems[item] == bin;
      iconPosition = position;
      showIcon = true;

      trashItems.remove(item);

      if (remainingTrashItems.isNotEmpty) {
        // Get the first available item from the remainingTrashItems
        String nextItem = remainingTrashItems.keys.first;
        trashItems[nextItem] = remainingTrashItems[nextItem]!;
        remainingTrashItems.remove(nextItem);
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        showIcon = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async => !_isEditing,
      child: Scaffold(
        appBar: AppBar(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10), // Adjust the radius for roundness
            child: _imageFile != null
                ? Image.file(_imageFile!, width: 40, height: 40, fit: BoxFit.cover)
                : user?.photoURL != null
                ? Image.network(user?.photoURL ?? '', width: 40, height: 40, fit: BoxFit.cover)
                : Image.asset('assets/widget.png', width: 40, height: 40, fit: BoxFit.cover),
          ),
          title: Text('Recycling Bin'),
        ),
    body: LayoutBuilder(
    builder: (context, constraints) {
    // Calculate positions based on layout constraints
    Offset greenPosition = Offset(constraints.maxWidth * 0.2, constraints.maxHeight * 0.2);
    Offset bluePosition = Offset(constraints.maxWidth * 0.6, constraints.maxHeight * 0.2);
    Offset yellowPosition = Offset(constraints.maxWidth * 0.4, constraints.maxHeight * 0.4);
    Offset brownPosition = Offset(constraints.maxWidth * 0.2, constraints.maxHeight * 0.6);
    Offset redPosition = Offset(constraints.maxWidth * 0.6, constraints.maxHeight * 0.6);

      return Stack(
      children: [
      Column(
      children: [
      // First Row: 2 Bins
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      binWidget('green', greenPosition),
      binWidget('blue', bluePosition),
      ],
      ),
      // Second Row: 1 Bin
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      binWidget('yellow', yellowPosition),
      ],
      ),
      // Third Row: 2 Bins
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      binWidget('brown', brownPosition),
      binWidget('red', redPosition),
      ],
      ),

      // Draggable Trash
      Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: trashItems.keys
          .map((item) => Draggable<String>(
      data: item,
      feedback: Image.asset('assets/$item.png', width: 80, height: 80),
      childWhenDragging: Opacity(
      opacity: 0.5,
      child: Image.asset('assets/$item.png', width: 80, height: 80),
      ),
      child: Image.asset('assets/$item.png', width: 80, height: 80),
      ))
          .toList(),
      ),
      ],
      ),

            // Feedback icon
            if (showIcon)
              Positioned(
                left: iconPosition.dx,
                top: iconPosition.dy,
                child: Image.asset(
                  rightAnswer ? 'assets/right.png' : 'assets/wrong.png',
                  width: 50,
                  height: 50,
                ),
              ),
          ],
        );
    },
    ),
      ),
    );
  }

  Widget binWidget(String color, Offset binPosition) {
    return DragTarget<String>(
      onWillAccept: (data) {
        setState(() => binStates[color] = true);
        return true;
      },
      onLeave: (data) {
        setState(() => binStates[color] = false);
      },
      onAcceptWithDetails: (details) {
        removeTrashItem(details.data, color, binPosition);
        setState(() => binStates[color] = false);
      },
      builder: (_, __, ___) => Image.asset(
        binStates[color]! ? 'assets/open_${color}_bin.png' : 'assets/${color}_bin.png',
        width: 150,
      ),
    );
  }
}

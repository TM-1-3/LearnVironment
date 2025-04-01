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

  // List to track trash items
  List<String> trashItems = ["trash1", "trash2", "trash3", "trash4", "trash5"];
  List<String> remainingTrashItems = ["trash6", "trash7", "trash8", "trash9", "trash10"];

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

  void removeTrashItem(String item, Offset position) {
    setState(() {
      trashItems.remove(item);
      iconPosition = position;
      showIcon = true;
      rightAnswer = true;

      if (remainingTrashItems.isNotEmpty) {
        trashItems.add(remainingTrashItems.removeAt(0));
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
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // First Row: 3 Bins
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    binWidget('green', (data, position) => removeTrashItem(data!, position)),
                    binWidget('blue', (data, position) => removeTrashItem(data!, position)),
                    binWidget('yellow', (data, position) => removeTrashItem(data!, position)),
                  ],
                ),

                // Second Row: 2 Bins
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    binWidget('brown', (data, position) => removeTrashItem(data!, position)),
                    binWidget('red', (data, position) => removeTrashItem(data!, position)),
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
                    feedback: Image.asset('assets/$item.png', width: 80),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: Image.asset('assets/$item.png', width: 80),
                    ),
                    child: Image.asset('assets/$item.png', width: 80),
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
        ),
      ),
    );
  }

  Widget binWidget(String color, Function(String?, Offset) onAccept) {
    return DragTarget<String>(
      onWillAccept: (data) {
        setState(() => binStates[color] = true);
        return true;
      },
      onLeave: (data) {
        setState(() => binStates[color] = false);
      },
      onAcceptWithDetails: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset position = box.globalToLocal(details.offset);
        onAccept(details.data, position);
        setState(() => binStates[color] = false);
      },
      builder: (_, __, ___) => Image.asset(
        binStates[color]! ? 'assets/open_${color}_bin.png' : 'assets/${color}_bin.png',
        width: 100,
      ),
    );
  }
}

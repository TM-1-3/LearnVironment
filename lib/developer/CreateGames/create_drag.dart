import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnvironment/developer/CreateGames/trash_object.dart';
import 'package:learnvironment/developer/widgets/age_dropdown.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';
import 'package:learnvironment/developer/widgets/tag_selection.dart';
import 'package:learnvironment/developer/widgets/trash_object_form.dart';


class CreateDragPage extends StatefulWidget {
  const CreateDragPage({super.key});

  @override
  State<CreateDragPage> createState() => _CreateDragPageState();
}

class _CreateDragPageState extends State<CreateDragPage> {
  bool _isSaved = false;
  final _formKey = GlobalKey<FormState>();

  final List<String> ageOptions = ['12+', '10+', '8+', '6+'];
  String selectedAge = '12+';
  late List<String> selectedTags = [];

  final TextEditingController gameLogoController = TextEditingController();
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameDescriptionController = TextEditingController();
  final TextEditingController gameBibliographyController = TextEditingController();

  late List<TrashObject> trashObjects = [];
  late List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    trashObjects = List.generate(4, (_) => TrashObject());
    isExpandedList = List.generate(trashObjects.length, (_) => true);
  }

  @override
  void dispose() {
    gameLogoController.dispose();
    gameNameController.dispose();
    gameDescriptionController.dispose();
    gameBibliographyController.dispose();
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


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String gameLogo = gameLogoController.text.trim();
      final String gameName = gameNameController.text.trim();
      final String gameDescription = gameDescriptionController.text.trim();
      final String gameBibliography = gameBibliographyController.text.trim();
      final List<String> tags = selectedTags;
      final String gameTemplate = 'drag';
      final Map<String, String> tips = {};
      final Map<String, String> correctAnswers = {};

      tags.insert(0, selectedAge); //Add age to tags

      int index = 0;
      for (var object in trashObjects) {
        final key = object.imageUrlController.text.trim();
        final tip = object.tipController.text.trim();
        final answer = object.answerController.text.trim();

        //Validate image
        bool isValidImage = await _validateImage(key);
        if (!isValidImage) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please use a valid image URL in Object $index'),
                backgroundColor: Colors.red,
              ),
            );
          }
          object.imageUrlController.text = "";
          return;
        }

        if (key.isNotEmpty && tip.isNotEmpty && answer.isNotEmpty) {
          tips[key] = tip;
          correctAnswers[key] = answer;
        }
        index++;
      }

      // Validate Logo
      if (gameLogo.isNotEmpty) {
        bool isValidImage = await _validateImage(gameLogo);
        if (!isValidImage) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please use a valid image URL for the Logo'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            gameLogoController.text = "";
          });
          return;
        }
      } else {
        gameLogo = "assets/placeholder.png";
      }

      //Create the game and add it to database

    }
  }

  void updateExpansionState(int index, bool expanded) {
    setState(() {
      isExpandedList[index] = expanded;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Drag Game')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameFormField(
                controller: gameLogoController,
                label: 'Logo URL',
                validator: (value) {return null;},
              ),
              GameFormField(
                controller: gameNameController,
                label: 'Name'
              ),
              GameFormField(
                  controller: gameDescriptionController,
                  label: 'Description',
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
              ),
              GameFormField(
                controller: gameBibliographyController,
                label: 'Bibliography',
                maxLines: 10,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              TagSelection(
                selectedTags: selectedTags,
                onTagsUpdated: (updatedTags) {
                  setState(() {
                    selectedTags = updatedTags;
                  });
                },
              ),
              const SizedBox(height: 16),
              AgeGroupDropdown(
                selectedAge: selectedAge,
                onAgeSelected: (value) {
                  if (value != null) {
                    setState(() {
                      selectedAge = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text(
                  'Trash Objects',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: true,
                onExpansionChanged: (expanded) {
                  if (!expanded) {
                    var isEmpty = false;
                    for (var object in trashObjects) {
                      isEmpty = isEmpty ||
                          object.imageUrlController.text.trim().isEmpty ||
                          object.tipController.text.trim().isEmpty ||
                          object.answerController.text.trim().isEmpty;
                    }
                    if (isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all fields for all Objects'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                backgroundColor: Colors.green.shade100,
                collapsedBackgroundColor: Colors.green.shade200,
                textColor: Colors.green.shade800,
                iconColor: Colors.green.shade800,
                collapsedTextColor: Colors.green.shade900,
                collapsedIconColor: Colors.green.shade900,
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                children: [...List.generate(trashObjects.length, (index) {
                  return TrashObjectForm(
                    isExpandedList: isExpandedList,
                    trashObject: trashObjects[index],
                    index: index,
                    onRemove: (removedIndex) {
                      setState(() {
                        trashObjects.removeAt(removedIndex);
                        isExpandedList.removeAt(removedIndex);
                      });
                    },
                    onIsExpandedList: (expandedList) {
                      setState(() {
                        isExpandedList = expandedList;
                      });
                    },
                  );
                }),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        trashObjects.add(TrashObject());
                        isExpandedList.add(true);
                      });
                    },
                    child: const Text('Add New Object'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Center(child: ElevatedButton(onPressed: _submitForm, child: const Text('Create Game'))),
            ],
          ),
        ),
      ),
    );
  }
}

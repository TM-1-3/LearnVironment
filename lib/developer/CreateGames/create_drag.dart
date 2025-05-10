import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnvironment/developer/widgets/game_form_field.dart';

class TrashObject {
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController tipController = TextEditingController();
  TextEditingController answerController = TextEditingController();
}

class CreateDragPage extends StatefulWidget {
  const CreateDragPage({super.key});

  @override
  State<CreateDragPage> createState() => _CreateDragPageState();
}

class _CreateDragPageState extends State<CreateDragPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> ageOptions = ['12+', '10+', '8+', '6+'];
  String selectedAge = '12+';

  final TextEditingController gameLogoController = TextEditingController();
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameDescriptionController = TextEditingController();
  final TextEditingController gameBibliographyController = TextEditingController();
  final TextEditingController gameTemplateController = TextEditingController();

  late List<TrashObject> trashObjects = [];
  late List<bool> isExpandedList = [];

  final List<String> availableTags = ['Recycling', 'Strategy', 'Citizenship'];
  final List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    trashObjects = List.generate(4, (_) => TrashObject());
    isExpandedList = List.generate(trashObjects.length, (_) => true);
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

              const SizedBox(height: 16),
              const Text('Select Tags', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: availableTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedTags.add(tag);
                        } else {
                          selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAge,
                decoration: const InputDecoration(labelText: 'Select Age Group'),
                items: ageOptions.map((age) {
                  return DropdownMenuItem(
                    value: age,
                    child: Text(age),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedAge = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),
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
                final object = trashObjects[index];
                return ExpansionTile(
                  title: Text('Object ${index + 1}'),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isExpandedList[index] = expanded;
                    });
                    if (!expanded) {
                      final object = trashObjects[index];
                      final isEmpty = object.imageUrlController.text.trim().isEmpty ||
                          object.tipController.text.trim().isEmpty ||
                          object.answerController.text.trim().isEmpty;

                      if (isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all fields for Object ${index + 1}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  initiallyExpanded: isExpandedList[index],
                  backgroundColor: Colors.green.shade50,
                  collapsedBackgroundColor: Colors.green.shade100,
                  textColor: Colors.green.shade700,
                  iconColor: Colors.green.shade700,
                  collapsedTextColor: Colors.green.shade900,
                  collapsedIconColor: Colors.green.shade900,
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  children: [
                    TextFormField(
                      controller: object.imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: object.tipController,
                      decoration: const InputDecoration(labelText: 'Tip'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: object.answerController,
                      decoration: const InputDecoration(labelText: 'Correct Answer'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    if (trashObjects.length > 4)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              trashObjects.removeAt(index);
                            });
                          },
                          child: const Text('Remove'),
                        ),
                      ),
                    const Divider(),
                  ],
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

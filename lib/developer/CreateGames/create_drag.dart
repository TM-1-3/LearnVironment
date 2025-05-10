import 'package:flutter/material.dart';

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

  final Map<String, String> tips = {};
  final Map<String, String> correctAnswers = {};

  List<TrashObject> trashObjects = List.generate(4, (_) => TrashObject());

  final List<String> availableTags = ['Recycling', 'Strategy', 'Citizenship'];
  final List<String> selectedTags = [];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String gameLogo = gameLogoController.text.trim();
      final String gameName = gameNameController.text.trim();
      final String gameDescription = gameDescriptionController.text.trim();
      final String gameBibliography = gameBibliographyController.text.trim();
      final List<String> tags = selectedTags;
      final String gameTemplate = 'drag';
      tags.insert(0, selectedAge);

      for (var object in trashObjects) {
        final key = object.imageUrlController.text.trim();
        final tip = object.tipController.text.trim();
        final answer = object.answerController.text.trim();

        if (key.isNotEmpty && tip.isNotEmpty && answer.isNotEmpty) {
          tips[key] = tip;
          correctAnswers[key] = answer;
        }
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
              TextFormField(controller: gameLogoController, decoration: const InputDecoration(labelText: 'Logo URL')),
              TextFormField(controller: gameNameController, decoration: const InputDecoration(labelText: 'Name')),
              TextFormField(
                controller: gameDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 1,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
              ),
              TextFormField(
                controller: gameBibliographyController,
                decoration: const InputDecoration(labelText: 'Bibliography'),
                minLines: 1,
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
                    ),
                    TextFormField(
                      controller: object.tipController,
                      decoration: const InputDecoration(labelText: 'Tip'),
                    ),
                    TextFormField(
                      controller: object.answerController,
                      decoration: const InputDecoration(labelText: 'Correct Answer'),
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

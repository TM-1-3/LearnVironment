import 'package:flutter/material.dart';

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

  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController tipValueController = TextEditingController();
  final TextEditingController answerValueController = TextEditingController();

  final List<String> availableTags = ['Recycling', 'Strategy', 'Citizenship'];
  final List<String> selectedTags = [];

  void _addTipAndAnswer() {
    final key = imageUrlController.text.trim();
    final tip = tipValueController.text.trim();
    final answer = answerValueController.text.trim();

    if (key.isNotEmpty && tip.isNotEmpty && answer.isNotEmpty) {
      setState(() {
        tips[key] = tip;
        correctAnswers[key] = answer;
        imageUrlController.clear();
        tipValueController.clear();
        answerValueController.clear();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String gameLogo = gameLogoController.text.trim();
      final String gameName = gameNameController.text.trim();
      final String gameDescription = gameDescriptionController.text.trim();
      final String gameBibliography = gameBibliographyController.text.trim();
      final List<String> tags = selectedTags;
      final String gameTemplate = 'drag';
      tags.insert(0, selectedAge);

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
              TextFormField(controller: gameLogoController, decoration: const InputDecoration(labelText: 'Game Logo URL')),
              TextFormField(controller: gameNameController, decoration: const InputDecoration(labelText: 'Game Name')),
              TextFormField(controller: gameDescriptionController, decoration: const InputDecoration(labelText: 'Game Description')),
              TextFormField(controller: gameBibliographyController, decoration: const InputDecoration(labelText: 'Game Bibliography')),

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

              const SizedBox(height: 24),
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
                  setState(() {
                    if (value != null) {
                      setState(() {
                        selectedAge = value;
                      });
                    }
                  });
                }
              ),

              const SizedBox(height: 24),
              const Text('Add Object to Put in Trash Cans', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
              TextFormField(controller: tipValueController, decoration: const InputDecoration(labelText: 'Tip')),
              TextFormField(controller: answerValueController, decoration: const InputDecoration(labelText: 'Correct Answer')),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _addTipAndAnswer, child: const Text('Create Object')),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: const Text('Create Game')),
            ],
          ),
        ),
      ),
    );
  }
}

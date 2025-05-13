import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnvironment/developer/CreateGames/objects/option_object.dart';
import 'package:learnvironment/developer/CreateGames/objects/question_object.dart';
import 'package:learnvironment/developer/widgets/dropdown/age_dropdown.dart';
import 'package:learnvironment/developer/widgets/dropdown/tag_selection.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';
import 'package:learnvironment/developer/widgets/forms/question_object_form.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  bool _isSaved = false;
  final _formKey = GlobalKey<FormState>();

  final List<String> ageOptions = ['12+', '10+', '8+', '6+'];
  String selectedAge = '12+';
  late List<String> selectedTags = [];

  final TextEditingController gameLogoController = TextEditingController();
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameDescriptionController = TextEditingController();
  final TextEditingController gameBibliographyController = TextEditingController();

  late List<QuestionObject> questionObjects = [];
  late List<OptionObject> optionObjects = [];
  late List<bool> isExpandedList = [];
  late List<bool> isExpandedListOpt = [];

  @override
  void initState() {
    super.initState();
    questionObjects = List.generate(5, (_) => QuestionObject());
    optionObjects = List.generate(5, (_) => OptionObject());
    isExpandedList = List.generate(questionObjects.length, (_) => true);
    isExpandedListOpt = List.generate(optionObjects.length, (_) => true);
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
    if (data['content-type'] == 'image/jpeg' ||
        data['content-type'] == 'image/png' ||
        data['content-type'] == 'image/gif') {
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
      final String gameTemplate = 'quiz';
      final Map<String, String> tips = {};
      final Map<String, String> correctAnswers = {};
      final Map<String, List<String>> questionsAndOptions = {};

      tags.insert(0, selectedAge); //Add age to tags

      int index = 0;
      for (var object in questionObjects) {
        final key = object.questionController.text.trim();
        final tip = object.tipController.text.trim();
        final answer = object.answerController.text.trim();

        if (key.isNotEmpty && tip.isNotEmpty && answer.isNotEmpty) {
          tips[key] = tip;
          correctAnswers[key] = answer;

          final opt1 = object.options.option1Controller.text.trim();
          final opt2 = object.options.option2Controller.text.trim();
          final opt3 = object.options.option3Controller.text.trim();
          final opt4 = object.options.option4Controller.text.trim();
          questionsAndOptions[key] = [opt1, opt2, opt3, opt4];
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

      //Navigate to auth_service and display SnackBar

      setState(() {
        _isSaved = true;
      });
    }
  }

  void updateExpansionState(int index, bool expanded) {
    setState(() {
      isExpandedList[index] = expanded;
    });
  }

  Future<bool?> _onWillPop() async {
    if (!_isSaved) {
      return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
                'You have unsaved changes. Do you want to leave without saving?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          );
        },
      ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: _isSaved,
        onPopInvokedWithResult: (didPop, result) async {
          if (!_isSaved && !didPop) {
            final shouldLeave = await _onWillPop();
            if (shouldLeave! && context.mounted) {
              Navigator.of(context).pushReplacementNamed('/auth_gate');
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Create Quiz Game')),
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
                    validator: (value) {
                      return null;
                    },
                  ),
                  GameFormField(controller: gameNameController, label: 'Name'),
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
                      'QuestionsTrash Objects',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    onExpansionChanged: (expanded) {
                      if (!expanded) {
                        var isEmpty = false;
                        for (var object in questionObjects) {
                          isEmpty = isEmpty || object.isEmpty();
                        }
                        if (isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Please fill in all fields for all Objects'),
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
                    childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    children: [
                      ...List.generate(questionObjects.length, (index) {
                        return QuestionObjectForm(
                          isExpandedList: isExpandedList,
                          isExpandedListOpt: isExpandedListOpt,
                          questionObject: questionObjects[index],
                          optionObject: optionObjects[index],
                          index: index,
                          onRemove: (removedIndex) {
                            setState(() {
                              questionObjects.removeAt(removedIndex);
                              optionObjects.removeAt(removedIndex);
                              isExpandedList.removeAt(removedIndex);
                              isExpandedListOpt.removeAt(removedIndex);
                            });
                          },
                          onIsExpandedList: (expandedList) {
                            setState(() {
                              isExpandedList = expandedList;
                            });
                          },
                          onIsExpandedListOpt: (expandedList) {
                            setState(() {
                              isExpandedListOpt = expandedList;
                            });
                          },
                        );
                      }),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            questionObjects.add(QuestionObject());
                            optionObjects.add(OptionObject());
                            isExpandedList.add(true);
                            isExpandedListOpt.add(true);
                          });
                        },
                        child: const Text('Add New Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                      child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Create Game')
                      )
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

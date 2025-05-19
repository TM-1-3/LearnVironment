import 'package:flutter/material.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:provider/provider.dart';

class CreateAssignmentPage extends StatefulWidget {
  final String gameId;

  CreateAssignmentPage({
    required this.gameId,
    super.key,
  });

  @override
  CreateAssignmentPageState createState() => CreateAssignmentPageState();
}

class CreateAssignmentPageState extends State<CreateAssignmentPage> {
  bool _isSaved = true;
  late TextEditingController titleController;
  late DateTime _dueDate;
  late String _selectedClass;
  late List<String> _classes = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    _selectedClass = '';
    _dueDate = DateTime.now();
    _loadClasses();

    titleController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_isSaved) {
      setState(() {
        _isSaved = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    DateTime currentDateTime = DateTime.now();
      DateTime oneYearLater = currentDateTime.add(Duration(days: 365));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: currentDateTime,
      lastDate: oneYearLater,
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        _isSaved = false;
      });
    }
  }

  Future<void> _createAssignment({
  required String title,
  required DateTime dueDate,
  required String turma,
  required String gameid}) async {
    try {
      DataService dataService = Provider.of<DataService>(context, listen: false);
      await dataService.createAssignment(title: title, dueDate: dueDate, turma: turma, gameId: gameid);

      setState(() {
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved.')),
        );
      }

      titleController.clear();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth_gate');
      }
    } catch (e) {
      print("Error creating assignment: $e");
      _showErrorDialog("Error creating assignment.", "Error");
    }
  }

  void _showErrorDialog(String message, String ctx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ctx),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadClasses() async {
    try {
      DataService dataService = Provider.of<DataService>(context, listen: false);
      AuthService authService = Provider.of<AuthService>(context, listen: false);
      UserData? userData = await dataService.getUserData(userId: await authService.getUid());
      if (userData == null) {
        _showErrorDialog("No user is logged in.", "Error");
        return;
      }
      setState(() {
        _classes = userData.tClasses;
      });
    } catch (e) {
      print("Failed to load Classes");
      rethrow;
    }
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
      ) ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context){
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
        appBar: AppBar(
          title: const Text('Create Assignment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldLeave = await _onWillPop();
              if (shouldLeave! && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      key: const Key("dueDate"),
                      onTap: _pickDueDate,
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedClass.isEmpty ? null : _selectedClass,
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: _classes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedClass = newValue;
                            _isSaved = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _createAssignment(
                            title: titleController.text.trim(),
                            dueDate: _dueDate,
                            turma: _selectedClass,
                            gameid: widget.gameId,
                          );
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              )
            ]),
      ),
    ));
  }
}
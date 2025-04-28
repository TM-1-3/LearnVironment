import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnvironment/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/subject_data.dart';
import '../services/data_service.dart';

class CreateSubjectPage extends StatefulWidget {
  const CreateSubjectPage({super.key});

  @override
  State<CreateSubjectPage> createState() => _CreateSubjectPageState();
}

class _CreateSubjectPageState extends State<CreateSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _logoController = TextEditingController();
  bool _isLoading = false;

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

  Future<void> _createSubject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final subjectId = const Uuid().v4();

      String value = _logoController.text.trim();

      if (!await _validateImage(value)) {
        value = "assets/placeholder.png";
      }

      final newSubject = SubjectData(
        subjectId: subjectId,
        subjectLogo: value,
        subjectName: _nameController.text.trim(),
        students: [],
        teacher: await authService.getUid(),
      );

      // Save to Firestore
      await dataService.addSubject(subject: newSubject);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject created successfully!')),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subject created successful')),
          );
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('[CreateSubjectPage] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create subject: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Subject")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _logoController,
                decoration: const InputDecoration(labelText: 'Logo URL'),
                validator: (value) {
                  if (value!.isEmpty) {
                    value = "assets/placeholder.png";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createSubject,
                key: Key("button"),
                child: const Text('Create Subject')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
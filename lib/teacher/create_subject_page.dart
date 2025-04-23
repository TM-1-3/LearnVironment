import 'package:flutter/material.dart';
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

  Future<void> _createSubject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final subjectId = const Uuid().v4();

      final newSubject = SubjectData(
        subjectId: subjectId,
        subjectLogo: _logoController.text.trim(),
        subjectName: _nameController.text.trim(),
        students: [],
        teacher: '',
      );

      // Save to Firestore
      await dataService.firestoreService.addSubjectData(newSubject);

      // Cache it
      await dataService.subjectCacheService.cacheSubjectData(newSubject);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject created successfully!')),
        );
        Navigator.pop(context);
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter a logo URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createSubject,
                child: const Text('Create Subject'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

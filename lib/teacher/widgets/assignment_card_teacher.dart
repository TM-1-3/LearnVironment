import 'package:flutter/material.dart';

class AssignmentCardTeacher extends StatelessWidget {
  final String assignmentTitle;
  final String assignmentId;
  final Future<void> Function(String assignmentId) loadAssignment;

  const AssignmentCardTeacher({
    super.key,
    required this.assignmentTitle,
    required this.assignmentId,
    required this.loadAssignment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        key: Key('assignmentCard_$assignmentId'),
        onTap: () async => await loadAssignment(assignmentId),
        child: Container(
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // Center content
                  children: [
                    Center( // Center the assignment title
                      child: Text(
                        assignmentTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
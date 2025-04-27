import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String imagePath;
  final String subjectName;
  final String subjectId;
  final Future<void> Function(String gameId) loadSubject;

  const SubjectCard({
    super.key,
    required this.imagePath,
    required this.subjectName,
    required this.subjectId,
    required this.loadSubject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        key: Key('subjectCard_$subjectId'),
        onTap: () async => await loadSubject(subjectId),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 5,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: SizedBox(
                  height: 150, // Fixed height for the image
                  width: double.infinity,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover, // Cover the container but keep aspect ratio
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        subjectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

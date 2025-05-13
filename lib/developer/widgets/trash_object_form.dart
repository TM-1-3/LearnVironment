import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/objects/trash_object.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

class TrashObjectForm extends StatelessWidget {
  final TrashObject trashObject;
  final int index;
  final ValueChanged<int> onRemove;
  final ValueChanged<List<bool>> onIsExpandedList;
  final List<bool> isExpandedList;

  const TrashObjectForm({
    super.key,
    required this.trashObject,
    required this.index,
    required this.onRemove,
    required this.onIsExpandedList,
    required this.isExpandedList,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Object ${index + 1}'),
        onExpansionChanged: (expanded) {
          onIsExpandedList(List.from(isExpandedList)..[index] = expanded);
          isExpandedList[index] = expanded;
        if (!expanded) {
          final isEmpty = trashObject.imageUrlController.text.trim().isEmpty ||
              trashObject.tipController.text.trim().isEmpty ||
              trashObject.answerController.text.trim().isEmpty;

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
        GameFormField(
          controller: trashObject.imageUrlController,
          label: 'Image URL',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        GameFormField(
          controller: trashObject.tipController,
          label: 'Tip',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        GameFormField(
          controller: trashObject.answerController,
          label: 'Correct Answer',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        if (index >= 4)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onRemove(index),
              child: const Text('Remove'),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/trash_object.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

class QuestionObjectForm extends StatelessWidget {
  final QuestionObject questionObject;
  final int index;
  final ValueChanged<int> onRemove;
  final ValueChanged<List<bool>> onIsExpandedList;
  final List<bool> isExpandedList;

  const QuestionObjectForm({
    super.key,
    required this.questionObject,
    required this.index,
    required this.onRemove,
    required this.onIsExpandedList,
    required this.isExpandedList,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Question ${index + 1}'),
        onExpansionChanged: (expanded) {
          onIsExpandedList(List.from(isExpandedList)..[index] = expanded);
          isExpandedList[index] = expanded;
        if (!expanded) {
          final isEmpty = questionObject.questionController.text.trim().isEmpty ||
              questionObject.tipController.text.trim().isEmpty ||
              questionObject.answerController.text.trim().isEmpty ||
              questionObject.options.isEmpty();

          if (isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill in all fields for Question ${index + 1}'),
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
          controller: questionObject.questionController,
          label: 'Question',
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
        //Answer ?????? Number corresponding to the correct option
        if (index >= 5)
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

import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/objects/option_object.dart';
import 'package:learnvironment/developer/CreateGames/objects/question_object.dart';
import 'package:learnvironment/developer/widgets/dropdown/option_dropdown.dart';
import 'package:learnvironment/developer/widgets/forms/options_object_form.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

class QuestionObjectForm extends StatelessWidget {
  final QuestionObject questionObject;
  final OptionObject optionObject;
  final int index;
  final ValueChanged<int> onRemove;
  final ValueChanged<List<bool>> onIsExpandedList;
  final ValueChanged<List<bool>> onIsExpandedListOpt;
  final List<bool> isExpandedList;
  final List<bool> isExpandedListOpt;

  const QuestionObjectForm({
    super.key,
    required this.questionObject,
    required this.index,
    required this.onRemove,
    required this.onIsExpandedList,
    required this.isExpandedList,
    required this.optionObject,
    required this.onIsExpandedListOpt,
    required this.isExpandedListOpt,
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
          controller: questionObject.tipController,
          label: 'Tip',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        OptionsObjectForm(optionObject: optionObject, index: index, onIsExpandedList: onIsExpandedListOpt, isExpandedList: isExpandedListOpt),
        OptionDropdown(selectedOption: selectedOption, onOptionSelected: onOptionSelected),
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

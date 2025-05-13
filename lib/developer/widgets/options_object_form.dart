import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/objects/option_object.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

class OptionsObjectForm extends StatelessWidget {
  final OptionObject optionObject;
  final int index;
  final ValueChanged<int> onRemove;
  final ValueChanged<List<bool>> onIsExpandedList;
  final List<bool> isExpandedList;

  const OptionsObjectForm({
    super.key,
    required this.optionObject,
    required this.index,
    required this.onRemove,
    required this.onIsExpandedList,
    required this.isExpandedList,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Options for Question number ${index + 1}'),
      onExpansionChanged: (expanded) {
        onIsExpandedList(List.from(isExpandedList)..[index] = expanded);
        isExpandedList[index] = expanded;
        if (!expanded) {
          if (optionObject.isEmpty()) {
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
          controller: optionObject.option1Controller,
          label: 'Option 1',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        GameFormField(
          controller: optionObject.option2Controller,
          label: 'Option 2',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        GameFormField(
          controller: optionObject.option3Controller,
          label: 'Option 3',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        GameFormField(
          controller: optionObject.option4Controller,
          label: 'Option 4',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        )
      ]
    );
  }
}

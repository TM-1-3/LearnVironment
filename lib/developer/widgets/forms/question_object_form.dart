import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/objects/question_object.dart';
import 'package:learnvironment/developer/widgets/dropdown/option_dropdown.dart';
import 'package:learnvironment/developer/widgets/forms/options_object_form.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

class QuestionObjectForm extends StatefulWidget {
  final QuestionObject questionObject;
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
    required this.onIsExpandedListOpt,
    required this.isExpandedListOpt,
  });

  @override
  State<QuestionObjectForm> createState() => _QuestionObjectFormState();
}

class _QuestionObjectFormState extends State<QuestionObjectForm> {
  late String? selectedOption;
  late List<bool> isExpandedListOpt;
  late List<bool> isExpandedList;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.questionObject.selectedOption;
    isExpandedListOpt = widget.isExpandedListOpt;
    isExpandedList = widget.isExpandedList;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Question ${widget.index + 1}'),
      onExpansionChanged: (expanded) {
        widget.onIsExpandedList(List.from(isExpandedList)..[widget.index] = expanded);
        isExpandedList[widget.index] = expanded;
        if (!expanded) {
          final isEmpty = widget.questionObject.questionController.text.trim().isEmpty ||
              widget.questionObject.tipController.text.trim().isEmpty ||
              widget.questionObject.options.isEmpty();

          if (isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill in all fields for Question ${widget.index + 1}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      initiallyExpanded: isExpandedList[widget.index],
      backgroundColor: Colors.green.shade50,
      collapsedBackgroundColor: Colors.green.shade100,
      textColor: Colors.green.shade700,
      iconColor: Colors.green.shade700,
      collapsedTextColor: Colors.green.shade900,
      collapsedIconColor: Colors.green.shade900,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        GameFormField(
          controller: widget.questionObject.questionController,
          label: 'Question',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        GameFormField(
          controller: widget.questionObject.tipController,
          label: 'Tip',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        OptionsObjectForm(
          optionObject: widget.questionObject.options,
          index: widget.index,
          onIsExpandedList: (expandedList) {
            setState(() {
              isExpandedListOpt = expandedList;
            });
            widget.onIsExpandedListOpt(expandedList);
          },
          isExpandedList: isExpandedListOpt,
        ),
        OptionDropdown(
          selectedOption: selectedOption,
          onOptionSelected: (String? value) {
              setState(() {
                selectedOption = value;
                widget.questionObject.selectedOption = value;
              });
          },
        ),
        if (widget.index >= 5)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => widget.onRemove(widget.index),
              child: const Text('Remove'),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

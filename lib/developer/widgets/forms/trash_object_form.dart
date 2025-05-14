import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/objects/trash_object.dart';
import 'package:learnvironment/developer/widgets/dropdown/trash_can_dropdown.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

class TrashObjectForm extends StatefulWidget {
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
    required this.isExpandedList
  });

  @override
  State<TrashObjectForm> createState() => _TrashObjectFormState();
}

class _TrashObjectFormState extends State<TrashObjectForm> {
  late String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Object ${widget.index + 1}'),
        onExpansionChanged: (expanded) {
          widget.onIsExpandedList(List.from(widget.isExpandedList)..[widget.index] = expanded);
          widget.isExpandedList[widget.index] = expanded;
        if (!expanded) {
          if (widget.trashObject.isEmpty()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill in all fields for Object ${widget.index + 1}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      initiallyExpanded: widget.isExpandedList[widget.index],
      backgroundColor: Colors.green.shade50,
      collapsedBackgroundColor: Colors.green.shade100,
      textColor: Colors.green.shade700,
      iconColor: Colors.green.shade700,
      collapsedTextColor: Colors.green.shade900,
      collapsedIconColor: Colors.green.shade900,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        GameFormField(
          controller: widget.trashObject.imageUrlController,
          label: 'Image URL',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        GameFormField(
          controller: widget.trashObject.tipController,
          label: 'Tip',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        TrashCanDropdown(
            selectedOption: selectedOption,
            onOptionSelected:  (String? value) {
              setState(() {
                selectedOption = value;
              });
            }
        ),
        if (widget.index >= 4)
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

import 'package:flutter/material.dart';

class TagSelection extends StatefulWidget {
  final List<String> availableTags = ['Recycling', 'Strategy', 'Citizenship'];
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsUpdated;

  TagSelection({
    super.key,
    required this.selectedTags,
    required this.onTagsUpdated,
  });

  @override
  TagSelectionState createState() => TagSelectionState();
}

class TagSelectionState extends State<TagSelection> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = List.from(widget.selectedTags);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
    widget.onTagsUpdated(selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Tags', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: widget.availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) => _toggleTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}

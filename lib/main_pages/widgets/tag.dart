import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String tag;

  const TagWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag),
    );
  }
}
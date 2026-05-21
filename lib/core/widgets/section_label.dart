import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final double letterSpacing;

  const SectionLabel(
    this.text, {
    super.key,
    this.fontSize = 10,
    this.letterSpacing = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

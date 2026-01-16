import 'package:flutter/material.dart';

class FilledTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool darkButton;

  const FilledTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.darkButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: darkButton
            ? colorScheme.onSurface
            : colorScheme.surface,
        side: BorderSide(
          color: darkButton ? colorScheme.surface : colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        textStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

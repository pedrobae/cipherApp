import 'package:flutter/material.dart';

class FilledTextButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDarkButton;
  final bool isDisabled;

  const FilledTextButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isDarkButton = false,
    this.isDisabled = false,
  });

  factory FilledTextButton.icon({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    bool isDarkButton = false,
  }) {
    return FilledTextButton(
      text: text,
      onPressed: onPressed,
      isDarkButton: isDarkButton,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: isDarkButton
            ? (isDisabled
                  ? colorScheme.onSurface.withValues(alpha: 0.68)
                  : colorScheme.onSurface)
            : (isDisabled
                  ? colorScheme.surface.withValues(alpha: 0.68)
                  : colorScheme.surface),
        side: BorderSide(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        textStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: isDisabled ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 24,
              color: isDarkButton ? colorScheme.surface : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkButton ? colorScheme.surface : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

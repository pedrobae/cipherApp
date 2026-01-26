import 'package:flutter/material.dart';

class FilledTextButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDarkButton;
  final bool isDisabled;
  final bool isDense;

  const FilledTextButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isDarkButton = false,
    this.isDisabled = false,
    this.isDense = false,
  });

  factory FilledTextButton.icon({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    bool isDarkButton = false,
    bool isDisabled = false,
    bool isDense = false,
  }) {
    return FilledTextButton(
      text: text,
      onPressed: onPressed,
      isDarkButton: isDarkButton,
      isDisabled: isDisabled,
      isDense: isDense,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        fixedSize: isDense ? Size.fromHeight(25) : Size.fromHeight(50),
        backgroundColor: isDarkButton
            ? (isDisabled
                  ? colorScheme.onSurface.withValues(alpha: 0.68)
                  : colorScheme.onSurface)
            : (isDisabled
                  ? colorScheme.surface.withValues(alpha: 0.68)
                  : colorScheme.surface),
        side: BorderSide(color: colorScheme.onSurface, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        padding: isDense ? const EdgeInsets.all(0) : const EdgeInsets.all(12),
      ),
      onPressed: isDisabled ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isDense ? 18 : 20,
              color: isDarkButton ? colorScheme.surface : colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: isDense ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: isDisabled
                  ? Colors.black
                  : (isDarkButton
                        ? colorScheme.surface
                        : colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

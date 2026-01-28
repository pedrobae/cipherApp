import 'package:flutter/material.dart';

class FilledTextButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isDisabled;
  final bool isDense;
  final bool isDiscrete;
  final IconData? trailingIcon;

  const FilledTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDark = false,
    this.isDisabled = false,
    this.isDense = false,
    this.isDiscrete = false,
    this.icon,
    this.trailingIcon,
  });

  factory FilledTextButton.trailingIcon({
    required String text,
    required VoidCallback onPressed,
    required IconData trailingIcon,
    bool isDark = false,
    bool isDisabled = false,
    bool isDense = false,
    bool isDiscrete = false,
  }) {
    return FilledTextButton(
      text: text,
      onPressed: onPressed,
      isDark: isDark,
      isDisabled: isDisabled,
      isDense: isDense,
      trailingIcon: trailingIcon,
      isDiscrete: isDiscrete,
    );
  }

  factory FilledTextButton.icon({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    bool isDark = false,
    bool isDisabled = false,
    bool isDense = false,
    bool isDiscrete = false,
  }) {
    return FilledTextButton(
      text: text,
      onPressed: onPressed,
      isDark: isDark,
      isDisabled: isDisabled,
      isDense: isDense,
      icon: icon,
      isDiscrete: isDiscrete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: isDark
            ? (isDisabled
                  ? colorScheme.onSurface.withValues(alpha: 0.68)
                  : colorScheme.onSurface)
            : (isDisabled
                  ? colorScheme.surface.withValues(alpha: 0.68)
                  : colorScheme.surface),
        side: BorderSide(
          color: isDiscrete
              ? colorScheme.surfaceContainerHigh
              : colorScheme.onSurface,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        padding: isDense ? const EdgeInsets.all(0) : const EdgeInsets.all(12),
        visualDensity: isDense ? VisualDensity.compact : VisualDensity.standard,
      ),
      onPressed: isDisabled ? null : onPressed,
      child: Row(
        mainAxisSize: trailingIcon != null
            ? MainAxisSize.max
            : MainAxisSize.min,
        mainAxisAlignment: trailingIcon != null
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isDense ? 18 : 20,
              color: isDark ? colorScheme.surface : colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: isDense ? 14 : 18,
              fontWeight: isDiscrete ? FontWeight.w400 : FontWeight.w500,
              color: isDisabled
                  ? Colors.black
                  : (isDark ? colorScheme.surface : colorScheme.onSurface),
            ),
          ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              size: isDense ? 24 : 32,
              color: isDark
                  ? (isDiscrete
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surface)
                  : (isDiscrete ? colorScheme.shadow : colorScheme.onSurface),
              fontWeight: FontWeight.w500,
            ),
        ],
      ),
    );
  }
}

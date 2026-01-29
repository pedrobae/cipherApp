import 'package:flutter/material.dart';

class FilledTextButton extends StatelessWidget {
  final String text;
  final String? tooltip;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isDangerous;
  final bool isDense;
  final bool isDiscrete;
  final bool isDisabled;
  final IconData? trailingIcon;

  const FilledTextButton({
    super.key,
    required this.text,
    this.tooltip,
    required this.onPressed,
    this.isDark = false,
    this.isDisabled = false,
    this.isDense = false,
    this.isDiscrete = false,
    this.isDangerous = false,
    this.icon,
    this.trailingIcon,
  });

  factory FilledTextButton.trailingIcon({
    required String text,
    String? tooltip,
    required VoidCallback onPressed,
    required IconData trailingIcon,
    bool isDark = false,
    bool isDisabled = false,
    bool isDense = false,
    bool isDiscrete = false,
    bool isDangerous = false,
  }) {
    return FilledTextButton(
      text: text,
      tooltip: tooltip,
      onPressed: onPressed,
      isDark: isDark,
      isDisabled: isDisabled,
      isDense: isDense,
      isDangerous: isDangerous,
      trailingIcon: trailingIcon,
      isDiscrete: isDiscrete,
    );
  }

  factory FilledTextButton.icon({
    required String text,
    String? tooltip,
    required VoidCallback onPressed,
    required IconData icon,
    bool isDark = false,
    bool isDisabled = false,
    bool isDangerous = false,
    bool isDense = false,
    bool isDiscrete = false,
  }) {
    return FilledTextButton(
      text: text,
      tooltip: tooltip,
      onPressed: onPressed,
      isDark: isDark,
      isDangerous: isDangerous,
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
          color: isDangerous
              ? colorScheme.error
              : (isDiscrete
                    ? colorScheme.surfaceContainerHigh
                    : colorScheme.onSurface),
          width: 1.3,
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
        spacing: 12,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isDense ? 18 : 20,
              color: isDangerous
                  ? colorScheme.error
                  : (isDark ? colorScheme.surface : colorScheme.onSurface),
              fontWeight: FontWeight.w500,
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: trailingIcon == null
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: isDense ? 14 : 18,
                    fontWeight: isDiscrete ? FontWeight.w400 : FontWeight.w500,
                    color: isDisabled
                        ? Colors.black
                        : (isDangerous
                              ? colorScheme.error
                              : (isDark
                                    ? colorScheme.surface
                                    : colorScheme.onSurface)),
                  ),
                ),
                if (tooltip != null)
                  RichText(
                    softWrap: true,
                    text: TextSpan(
                      text: tooltip!,
                      style: TextStyle(
                        fontSize: isDense ? 10 : 12,
                        fontWeight: FontWeight.w400,
                        color: isDisabled
                            ? Colors.black54
                            : (isDark
                                  ? colorScheme.surfaceContainerHighest
                                  : colorScheme.shadow),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              size: isDense ? 24 : 32,
              color: isDangerous
                  ? colorScheme.error
                  : (isDark
                        ? (isDiscrete
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.surface)
                        : (isDiscrete
                              ? colorScheme.shadow
                              : colorScheme.onSurface)),
              fontWeight: FontWeight.w500,
            ),
        ],
      ),
    );
  }
}

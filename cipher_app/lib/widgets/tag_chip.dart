import 'package:flutter/material.dart';
import '../helpers/color_helpers.dart';
import '../utils/string_utils.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onTap;

  const TagChip({super.key, required this.tag, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColors = ColorHelpers.getTagColors(context, tag);

    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          StringUtils.toTitleCase(tag),
          style: theme.textTheme.labelSmall?.copyWith(
            color: tagColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: tagColors.backgroundColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: tagColors.borderColor, width: 1),
      ),
    );
  }
}

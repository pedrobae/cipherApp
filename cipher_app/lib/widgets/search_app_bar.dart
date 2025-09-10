import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final String hint;
  final bool? isSearching;
  final VoidCallback? onSearchToggle;
  final String? title;

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.hint,
    this.isSearching,
    this.onSearchToggle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: title != null,
        ),
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: title != null ? 14 : null,
        ),
        onChanged: onSearchChanged,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

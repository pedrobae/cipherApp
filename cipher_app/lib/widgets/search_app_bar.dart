import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final String hint;

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: InputDecoration(hintText: hint),
        onChanged: onSearchChanged,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => '',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

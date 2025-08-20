import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_app_bar.dart';
import '../providers/search_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: SearchAppBar(
        isSearching: searchProvider.isSearching,
        searchController: _searchController,
        onSearchChanged: (value) {
          context.read<SearchProvider>().setSearchTerm(value);
        },
        onSearchToggle: () {
          context.read<SearchProvider>().toggleSearch();
          if (!searchProvider.isSearching) {
            _searchController.clear();
          }
        },
        hint: 'Procure Cifras...',
      ),
      body: Center(child: Text('Home Screen')),
    );
  }
}

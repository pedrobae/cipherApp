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
    return Scaffold(
      appBar: SearchAppBar(
        searchController: _searchController,
        onSearchChanged: (value) {
          context.read<SearchProvider>().setSearchTerm(value);
          print(value);
        },
        hint: 'Procure Cifras...',
      ),
      body: Center(child: Text('Home Screen')),
    );
  }
}

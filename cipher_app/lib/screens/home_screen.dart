import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/bottom_navigation_icons.dart';
import '../providers/search_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: const [
          Expanded(child: Center(child: Text('Home Screen'))),
          BottomNavigationIcons(),
        ],
      ),
    );
  }
}

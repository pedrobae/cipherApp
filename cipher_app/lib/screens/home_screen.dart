import 'package:flutter/material.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/bottom_navigation_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchInput = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    setState(() {
      _searchInput = value;
    });
    print('Searching: $_searchInput');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        isSearching: _isSearching,
        searchController: _searchController,
        onSearchChanged: _handleSearch,
        onSearchToggle: () => setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) _searchController.clear();
        }),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/cipher_card.dart';
import '../providers/search_provider.dart';
import '../providers/cipher_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  void initState() {
    super.initState();
    // Load ciphers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CipherProvider>().loadCiphers();
    });
  }

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
          context.read<CipherProvider>().searchCiphers(value);
          print(value);
        },
        hint: 'Procure Cifras...',
      ),
      body: Consumer<CipherProvider>(
        builder: (context, cipherProvider, child) {
          // Handle loading state
          if (cipherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (cipherProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${cipherProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cipherProvider.loadCiphers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle empty state
          if (cipherProvider.ciphers.isEmpty) {
            return const Center(
              child: Text('No ciphers found'),
            );
          }

          // Display ciphers
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cipherProvider.ciphers.length,
            itemBuilder: (context, index) {
              final cipher = cipherProvider.ciphers[index];
              return CipherCard(
                cipher: cipher,
                onAddToPlaylist: () {
                  // Handle add to playlist
                  print('Add ${cipher.title} to playlist');
                },
              );
            },
          );
        },
      ),
    );
  }
}
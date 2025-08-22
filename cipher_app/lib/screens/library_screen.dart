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
  bool _hasInitialized = false;

  void _loadDataIfNeeded() {
    if (!_hasInitialized && mounted) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CipherProvider>().loadCiphers();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadDataIfNeeded();
    return Scaffold(
      appBar: SearchAppBar(
        searchController: _searchController,
        // When Searching something
        onSearchChanged: (value) {
          context.read<SearchProvider>().setSearchTerm(value);
          context.read<CipherProvider>().searchCiphers(value);
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
            return const Center(child: Text('No ciphers found'));
          }

          // Display ciphers
          return ListView.builder(
            cacheExtent: 200,
            physics: const BouncingScrollPhysics(), // Smoother scrolling
            itemCount: cipherProvider.ciphers.length,
            itemBuilder: (context, index) {
              // Add bounds checking
              if (index >= cipherProvider.ciphers.length) {
                return const SizedBox.shrink();
              }

              final cipher = cipherProvider.ciphers[index];
              return CipherCard(
                key: ValueKey(cipher.id), // Add keys for better performance
                cipher: cipher,
                onAddToPlaylist: () {
                  // Handle add to playlist
                },
              );
            },
          );
        },
      ),
    );
  }
}
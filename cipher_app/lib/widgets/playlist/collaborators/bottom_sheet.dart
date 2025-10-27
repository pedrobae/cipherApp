import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:cipher_app/widgets/playlist/collaborators/list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/user.dart';
import 'package:cipher_app/providers/collaborator_provider.dart';

class CollaboratorsBottomSheet extends StatefulWidget {
  final Playlist playlist;

  const CollaboratorsBottomSheet({super.key, required this.playlist});

  @override
  State<CollaboratorsBottomSheet> createState() =>
      _CollaboratorsBottomSheetState();
}

class _CollaboratorsBottomSheetState extends State<CollaboratorsBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showShareCode = false;

  @override
  void initState() {
    super.initState();
    // Load collaborators when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollaboratorProvider>().loadCollaborators(
        widget.playlist.id,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Colaboradores',
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showShareCode = !_showShareCode;
                  });
                },
                icon: Icon(Icons.share, color: colorScheme.primary),
                tooltip: 'Mostrar código de compartilhamento',
              ),
              if (!_isSearching) ...[
                IconButton(
                  icon: Icon(Icons.person_add, color: colorScheme.primary),
                  tooltip: 'Adicionar colaborador',
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ] else ...[
                IconButton(
                  icon: Icon(Icons.group, color: colorScheme.primary),
                  tooltip: 'Cancelar busca',
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      context.read<UserProvider>().clearSearchResults();
                    });
                  },
                ),
              ],
            ],
          ),
          if (_showShareCode) ...[
            Card(
              color: colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Código de Compartilhamento',
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    Card(
                      color: colorScheme.onPrimary,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SelectableText(
                          widget.playlist.shareCode ?? 'N/A',
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          _isSearching
              ? _buildSearchSection(context)
              : CollaboratorList(playlistId: widget.playlist.id),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por e-mail ou username',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<UserProvider>().clearSearchResults();
                },
              ),
            ),
            onChanged: (value) {
              context.read<UserProvider>().searchUsers(value);
            },
          ),
          const SizedBox(height: 16),
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                return Center(child: Text('Erro: ${provider.error}'));
              }

              if (provider.searchResults.isEmpty &&
                  _searchController.text.length >= 3) {
                return const Center(child: Text('Nenhum usuário encontrado'));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: provider.searchResults.length,
                  itemBuilder: (context, index) {
                    final user = provider.searchResults[index];
                    return _buildUserSearchResultTile(context, user);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserSearchResultTile(BuildContext context, User user) {
    // Check if user is already a collaborator
    final collaborators = context
        .read<CollaboratorProvider>()
        .getCollaboratorsForPlaylist(widget.playlist.id);
    final isCollaborator = collaborators.any((c) => c.userId == user.id);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profilePhoto != null
            ? NetworkImage(user.profilePhoto!)
            : null,
        child: user.profilePhoto == null ? Text(user.username[0]) : null,
      ),
      title: Text(user.username),
      subtitle: Text(user.mail),
      trailing: isCollaborator
          ? const Chip(label: Text('Já é colaborador'))
          : ElevatedButton(
              onPressed: () {
                _showAddCollaboratorDialog(context, user);
              },
              child: const Text('Adicionar'),
            ),
    );
  }

  void _showAddCollaboratorDialog(BuildContext context, User user) {
    String selectedInstrument = 'Vocalista';
    final instrumentOptions = context
        .read<CollaboratorProvider>()
        .getCommonInstruments();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Colaborador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profilePhoto != null
                    ? NetworkImage(user.profilePhoto!)
                    : null,
                child: user.profilePhoto == null
                    ? Text(user.username[0])
                    : null,
              ),
              title: Text(user.username),
              subtitle: Text(user.mail),
            ),
            const SizedBox(height: 16),
            const Text('Instrumento:'),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<String>(
                  initialValue: selectedInstrument,
                  decoration: const InputDecoration(
                    labelText: 'Selecione o instrumento',
                  ),
                  items: instrumentOptions.map((String instrument) {
                    return DropdownMenuItem<String>(
                      value: instrument,
                      child: Text(instrument),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedInstrument = newValue!;
                    });
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CollaboratorProvider>().addCollaborator(
                widget.playlist.id,
                user.id!,
                selectedInstrument,
                context.read<UserProvider>().getLocalIdByFirebaseId(
                  context.read<AuthProvider>().id!,
                )!,
              );
              Navigator.of(context).pop();
              setState(() {
                _isSearching = false;
              });
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

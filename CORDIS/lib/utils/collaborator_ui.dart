import 'package:flutter/material.dart';
import '../models/domain/playlist/playlist.dart';
import '../widgets/playlist/collaborators/bottom_sheet.dart';

/// Helper class for showing collaborator-related UI components
class CollaboratorUI {
  /// Shows the collaborators bottom sheet for a playlist
  static void showCollaboratorsBottomSheet(
    BuildContext context,
    Playlist playlist,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: CollaboratorsBottomSheet(playlist: playlist),
          );
        },
      ),
    );
  }
}

# GitHub Copilot Instructions for Cipher App

## ✅ Language Configuration - PORTUGUESE UI

**IMPORTANT: The default user interface (UI) language is PORTUGUESE BRAZILIAN.**

✅ **STATUS: SUCCESSFULLY IMPLEMENTED - All user interface has been translated to Brazilian Portuguese.**

### UI Text Guidelines:

1. **All user-visible text must be in Brazilian Portuguese**
2. **Screen titles and buttons must use Portuguese**
3. **Error messages and feedback must be in Portuguese**
4. **Tooltips and labels must be in Portuguese**

### Translation Examples Already Implemented:

- "Cipher App" → "App de Cifras"
- "Library" → "Biblioteca"
- "Playlists" → "Playlists"
- "Settings" → "Configurações"
- "Information" → "Informações"
- "Add Cipher" → "Adicionar Cifra"
- "Edit Cipher" → "Editar Cifra"
- "New Cipher" → "Nova Cifra"
- "Delete Cipher" → "Excluir Cifra"
- "Save Changes" → "Salvar Alterações"
- "Create Cipher" → "Criar Cifra"
- "Cancel" → "Cancelar"
- "Error" → "Erro"
- "Retry" → "Tentar Novamente"
- "No ciphers found" → "Nenhuma cifra encontrada"
- "Search Ciphers..." → "Procure Cifras..."
- "Add to playlist" → "Adicionar à playlist"
- "Key" → "Tom"
- "Author" → "Autor"
- "Title" → "Título"
- "Language" → "Idioma"

### Coding Conventions:

1. Comments can be in English (for developers)
2. Variable and function names should remain in English
3. Strings shown to users MUST be in Portuguese
4. Documentation and README can be in Portuguese or English

## Architecture Overview

This is a Flutter app for managing musical ciphers (chord charts) using a layered architecture:

- **Models**: Domain models (`Cipher`, `CipherMap`, `MapContent`) in `lib/models/domain/`
- **Database Layer**: `DatabaseHelper` (singleton) manages SQLite with automatic seeding
- **Repository Layer**: `CipherRepository` abstracts data access and builds complete domain objects
- **Provider Layer**: State management using `ChangeNotifier` pattern (e.g., `CipherProvider`)
- **UI Layer**: Screens consume providers, widgets are reusable components

## Critical Database Patterns

### Database Schema & Relationships
The app uses a complex relational schema:
- `cipher` → `cipher_map` (1:many, different versions/keys of same song)
- `cipher_map` → `map_content` (1:many, verses/chorus blocks in ChordPro format)
- `cipher` ↔ `tag` (many:many via `cipher_tags` junction table)

### Database Helper Singleton
```dart
// Always use the singleton instance
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;
```

### Automatic Seeding
Database automatically seeds with sample data on first creation via two mechanisms:
1. **Primary**: `_onCreate` callback seeds immediately after table creation
2. **Fallback**: `_initDatabase` checks for empty database and seeds if needed

See `lib/helpers/seed_database.dart` for initial hymns with ChordPro formatted content.

### Database Factory Initialization
Cross-platform database initialization is handled by `DatabaseFactoryHelper`:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseFactoryHelper.initialize(); // Platform-specific setup
  runApp(const MyApp());
}

// In tests
setUpAll(() {
  DatabaseFactoryHelper.initializeForTesting(); // Always uses FFI
});
```

**Platform Support:**
- **Mobile (iOS/Android)**: Uses native sqflite
- **Desktop (Windows/Linux/macOS)**: Uses `sqflite_common_ffi`
- **Web**: Throws UnsupportedError with suggestions for alternatives
- **Tests**: Always use FFI for consistency

### Testing Database Reset
```dart
await dbHelper.resetDatabase(); // Deletes and recreates DB with seed data
```

## Repository Pattern Implementation

`CipherRepository` builds complete domain objects with relationships:
```dart
// This loads cipher WITH maps and content
final cipher = await repository.getCipherById(id);
expect(cipher.maps.first.content.isNotEmpty, true);
```

Key methods always include related data:
- `getAllCiphers()` - includes tags
- `getCipherById(id)` - includes maps and map content
- `getCipherMaps(cipherId)` - includes content blocks

### Tags Handling Pattern
Tags require special handling since they're stored in a many-to-many relationship:
```dart
// Insert/Update operations use transactions to handle tags
await db.transaction((txn) async {
  final cipherId = await txn.insert('cipher', cipher.toJson());
  // Handle tags separately in cipher_tags junction table
  for (final tagTitle in cipher.tags) {
    await _addTagToCipherInTransaction(txn, cipherId, tagTitle);
  }
});
```

## Provider State Management Patterns

### Loading Pattern
```dart
if (_isLoading) return; // Prevent multiple simultaneous loads
_isLoading = true;
notifyListeners();
// ... do work
_isLoading = false;
notifyListeners();
```

### CRUD Operations Pattern
All CRUD operations in providers should:
1. Check if already saving/loading (`if (_isSaving) return;`)
2. Set loading state and clear errors
3. Perform the repository operation with `await`
4. Always call `await loadCiphers()` after create/update/delete to refresh data
5. Handle errors and update state in finally block

```dart
// Example pattern for all CRUD operations
try {
  await _cipherRepository.updateCipher(cipher);
  await loadCiphers(); // Always reload to get fresh data with relationships
} catch (e) {
  _error = e.toString();
} finally {
  _isSaving = false;
  notifyListeners();
}
```

### Memory vs Database Filtering
`CipherProvider` uses in-memory filtering for instant search results rather than SQL queries.

## Testing Requirements

### Test Setup (Critical)
```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});

setUp(() async {
  dbHelper = DatabaseHelper();
  await dbHelper.resetDatabase(); // Ensures clean state
});
```

### Database Factory Initialization
Main app requires explicit database factory initialization. Tests use `sqflite_common_ffi`.

## Navigation & UI Patterns

### Main Navigation Structure
- Uses `IndexedStack` with `NavigationProvider` for persistent state
- Drawer navigation with route constants in `NavigationProvider`
- Provider pattern for cross-screen state (search, selected indices)

### Screen Loading Pattern
```dart
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
```

## Key Files for Understanding
- `lib/helpers/database_helper.dart` - Database schema and singleton management
- `lib/helpers/seed_database.dart` - Initial data structure and ChordPro format
- `lib/repositories/cipher_repository.dart` - Data access patterns and relationship building
- `lib/providers/cipher_provider.dart` - State management and filtering logic
- `test/database_helper_test.dart` - Testing patterns and database verification
- `test/cipher_repository_test.dart` - Repository testing with seed data expectations

## Development Commands
```bash
flutter test                    # Run all tests
flutter test test/database_helper_test.dart  # Database-specific tests
flutter run                     # Start app (requires mobile emulator/device)
```

## Common Patterns to Follow
- Always use `await dbHelper.resetDatabase()` in test setUp
- Repository methods return complete domain objects with relationships
- Providers handle loading states and error handling consistently
- Database uses soft deletes (`is_deleted` flag) rather than hard deletes
- ChordPro format for musical content with chord notation like `[G]Amazing [D]Grace`

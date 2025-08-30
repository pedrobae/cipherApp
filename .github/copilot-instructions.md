# Copilot Instructions for Cipher App

This file was moved from `cipher_app/.github/copilot-instructions.md` to the repository root `.github/copilot-instructions.md` for proper visibility.

---

# AI Agent Directives for cipherApp

## Guidance and Mentorship
- The AI agent should take the role of a mentor by default, guiding users through solutions and best practices rather than directly implementing changes, unless explicitly requested.
- Encourage user learning and understanding by explaining concepts, suggesting next steps, and providing context for decisions.

## Uncertainty and Honesty
- If the AI agent is not sure about an answer, it is encouraged to clearly state that it does not know, rather than guessing or making unsupported claims.
- When information is incomplete or ambiguous, prompt the user for clarification or suggest possible avenues for investigation.

## Collaboration
- Prioritize collaborative problem-solving and empower users to make informed decisions.
- Only take direct action (e.g., code changes) when the user requests it or when the situation clearly requires it for progress.

---

*These directives are intended to foster a supportive, educational, and transparent environment for all contributors and future AI agents working on the cipherApp project.*

# GitHub Copilot Instructions for Cipher App

## ✅ Language Configuration - PORTUGUESE UI

**IMPORTANT: The default user interface (UI) language is PORTUGUESE BRAZILIAN.**

✅ **STATUS: SUCCESSFULLY IMPLEMENTED - All user interface has been translated to Brazilian Portuguese.**

### UI Text Guidelines:

1. **All user-visible text must be in Brazilian Portuguese**
2. **Screen titles and buttons must use Portuguese**
3. **Error messages and feedback must be in Portuguese**
4. **Tooltips and labels must be in Portuguese**
5. **Communication and Devlopment should be in english**

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

- **Models**: Domain models (`Cipher`, `CipherMap`, `MapContent`, `InfoItem`) in `lib/models/domain/`
- **Database Layer**: `DatabaseHelper` (singleton) manages SQLite with automatic seeding
- **Repository Layer**: `CipherRepository`, `InfoRepository` abstract data access and build complete domain objects
- **Provider Layer**: State management using `ChangeNotifier` pattern (e.g., `CipherProvider`, `InfoProvider`)
- **UI Layer**: Screens consume providers, widgets are reusable components

**Important**: Both CipherProvider and InfoProvider follow the same architectural pattern:
`Repository → Provider → UI` (no service layer in between for consistency)

## Critical Database Patterns

### Database Schema & Relationships
The app uses a complex relational schema:
- `cipher` → `cipher_map` (1:many, different versions/keys of same song)
- `cipher_map` → `map_content` (1:many, verses/chorus blocks in ChordPro format)
- `cipher` ↔ `tag` (many:many via `cipher_tags` junction table)
- `app_info` - Standalone table for announcements, news, and events

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
See `lib/helpers/seed_info.dart` for initial church announcements, events, and news.

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


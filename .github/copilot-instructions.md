# GitHub Copilot Instructions for Cipher App

## ✅ Language Configuration - PORTUGUESE UI

**IMPORTANT: The default user interface (UI) language is PORTUGUESE BRAZILIAN.**

### UI Text Guidelines:

1. **All user-visible text must be in Brazilian Portuguese**
2. **Screen titles and buttons must use Portuguese**
3. **Error messages and feedback must be in Portuguese**
4. **Tooltips and labels must be in Portuguese**
5. **Communication and Development should be in English**

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

## 🏗️ Architecture Overview

This Flutter app manages musical ciphers (chord charts) with a strict layered architecture:

### Core Architecture Pattern
```
Database (SQLite) → Repository → Provider (ChangeNotifier) → UI (Screens/Widgets)
```

**Critical**: No service layer exists between Repository and Provider for consistency.

### Domain Model Evolution (UPDATED)
The app has evolved from legacy `cipher_map`/`map_content` to modern `version`/`section`:

- **Cipher**: Base song entity with metadata (`title`, `author`, `musicKey`, `language`, `tags`)
- **Version**: Different arrangements of same cipher (`song_structure`, `transposed_key`, `version_name`)
- **Section**: Content blocks within versions (`content_type`, `content_code`, `content_text`, `content_color`)

### Key Directory Structure
```
lib/
├── models/domain/cipher/     # Core domain models (Cipher, Version, Section)
├── repositories/             # Data access layer (no business logic)
├── providers/               # State management (ChangeNotifier pattern)
├── screens/                 # Full-screen UI components
├── widgets/cipher/editor/   # Specialized cipher editing widgets
├── helpers/                 # Database setup and utilities
└── utils/                   # Project-specific utilities (color, string)
```

## 🗄️ Critical Database Patterns

### Modern Schema (v3)
```sql
cipher → version (1:many, different arrangements)
version → section (1:many, content blocks like verses/chorus)
cipher ↔ tag (many:many via cipher_tags)
```

### Database Singleton Pattern
```dart
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;
```

### Cross-Platform Database Setup
**CRITICAL**: Must initialize DatabaseFactory before any database operations:
```dart
// In main.dart
await DatabaseFactoryHelper.initialize(); // Handles desktop vs mobile

// In tests
DatabaseFactoryHelper.initializeForTesting(); // Always uses FFI
```

### Automatic Seeding
Database seeds with sample hymns on first creation. Seeds are in `lib/helpers/seed_data/`.

## 🔄 State Management Patterns

### Provider Usage Pattern
All providers follow identical patterns:
```dart
class CipherProvider extends ChangeNotifier {
  final CipherRepository _repository = CipherRepository();
  
  List<Cipher> _ciphers = [];
  bool _isLoading = false;
  String? _error;
  
  // Load, Create, Update, Delete methods with error handling
  // Always call notifyListeners() after state changes
}
```

### Multi-Provider Setup
App uses multiple providers in `main.dart`:
- `CipherProvider` + `VersionProvider` work together for editing
- `SettingsProvider` + `LayoutSettingsProvider` for configuration
- Each provider has independent lifecycle

### Critical Provider Patterns
1. **Always check `_isLoading`** before async operations
2. **Use `Timer` for debouncing** rapid user input (see `cipher_section_form.dart`)
3. **Sync state in `didChangeDependencies`** for complex widgets
4. **Consumer2/Consumer3** for widgets needing multiple providers

## 🎵 Cipher-Specific Patterns

### Section Color System
Predefined section types with default colors in `cipher_section_form.dart`:
```dart
const Map<String, Color> _defaultSectionColors = {
  'V1': Colors.blue,    // Verse 1
  'C': Colors.red,      // Chorus  
  'B': Colors.green,    // Bridge
  'I': Colors.purple,   // Intro
};
```

### Song Structure Format
Stored as comma-separated codes: `"I,V1,C,V2,C,B,C,F"`
- Allows reuse of sections (multiple chorus occurrences)
- Order defines playback sequence

### ChordPro Content Format
Sections contain ChordPro-formatted text for chord charts:
```
[Am]Amazing [F]grace, how [C]sweet the [G]sound
That [Am]saved a [F]wretch like [C]me
```

## 🧪 Testing Conventions

### Test Setup Pattern
```dart
setUpAll(() {
  DatabaseFactoryHelper.initializeForTesting();
});

setUp(() async {
  dbHelper = DatabaseHelper();
  await dbHelper.resetDatabase(); // Recreates and seeds
  repository = CipherRepository();
});
```

### Test Data Expectations
Seeded database contains 4 hymns: "Amazing Grace", "How Great Thou Art", "Holy Holy Holy", "Be Thou My Vision"

## 🎨 UI Component Patterns

### Widget Organization
- `lib/widgets/cipher/editor/` - Complex form components for cipher editing
- `lib/widgets/cipher/viewer/` - Display components for cipher viewing
- Widgets are highly reusable and provider-agnostic when possible

### Color Utilities
Custom color handling in `lib/utils/color.dart`:
```dart
Color colorFromHex(String? hexColor)  // Handles null safely
String colorToHex(Color? color)       // Converts back for storage
```

### Navigation Pattern
- `AppRoutes` defines static routes and content routes
- Complex navigation (with parameters) uses `Navigator.push` directly
- `NavigationProvider` manages bottom navigation state

## 🔧 Development Workflows

### Build & Test Commands
```powershell
flutter pub get                    # Install dependencies
flutter test                       # Run unit tests
flutter analyze                    # Lint analysis
flutter run                        # Debug build
flutter build windows              # Windows desktop build
```

### Database Operations
- Database version is currently 3 (handles table renaming migration)
- Use `resetDatabase()` in tests to ensure clean state
- Database file: `cipher_app.db` in platform-specific location

### Key Dependencies
- `provider: ^6.0.5` - State management
- `sqflite: ^2.3.0` + `sqflite_common_ffi: ^2.3.0` - Cross-platform database
- `flutter_colorpicker: ^1.0.3` - Section color selection
- `shared_preferences: ^2.2.2` - Settings persistence

## 🚨 Common Pitfalls

1. **Don't skip `DatabaseFactoryHelper.initialize()`** - causes runtime errors on desktop
2. **Always dispose TextControllers** in complex forms like `cipher_section_form.dart`
3. **Use debouncing for form inputs** that trigger provider updates
4. **Check provider loading states** before navigation or operations
5. **Maintain Portuguese UI strings** - never hardcode English in user-facing text


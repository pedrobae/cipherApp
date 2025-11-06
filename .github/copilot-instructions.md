# GitHub Copilot Instructions for Cipher App
**IMPORTANT: UNLESS ASKED TO ACT DEFAULT TO A MENTOR ROLE, ASKING AND ANSWERING QUESTIONS AND GIVING ADVICE.**

## ✅ Language Configuration

**IMPORTANT: All developer communication must be in ENGLISH.**

### UI Text Guidelines:

1. **All user-visible text must be in Brazilian Portuguese**
2. **Screen titles and buttons must use Portuguese**
3. **Error messages and feedback must be in Portuguese**
4. **Tooltips and labels must be in Portuguese**
5. **All code comments, documentation, and developer communication must be in English**

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

This Flutter app manages musical ciphers (chord charts) with a strict layered architecture supporting both local-first and cloud synchronization:

### Core Architecture Pattern
```
Local SQLite ←→ Repository ←→ Provider (ChangeNotifier) ←→ UI (Screens/Widgets)
     ↕                ↕
  FirebaseSync ←→ CloudRepository
```

**Critical**: Hybrid offline-first architecture with cloud sync capabilities for sharing and collaboration.

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
- **Future**: `AuthProvider` + `SyncProvider` for Firebase integration
- Each provider has independent lifecycle

### Critical Provider Patterns
1. **Always check `_isLoading`** before async operations
2. **Use `Timer` for debouncing** rapid user input (see `cipher_section_form.dart`)
3. **Sync state in `didChangeDependencies`** for complex widgets that need to react to dependency changes
4. **Consumer2/Consumer3** for widgets needing multiple providers
5. **Follow StatefulWidget pattern** for widgets requiring data pre-loading (see UI Component Patterns)
6. **Use post-frame callbacks** to avoid setState during build cycles
7. **Generate unique keys** for reorderable widgets to prevent global key collisions
8. **Firebase operations** should extend existing repository methods, not replace them

### Cache Management Patterns (CRITICAL)
**Dual-Purpose Cache Awareness**: Both `_ciphers` and `_versions` serve multiple contexts:

**CipherProvider `_ciphers` Cache:**
- **Primary**: Cipher Library (loads ALL ciphers via `loadCiphers()`)
- **Secondary**: Playlist contexts use existing cache via `getCachedCipher(id)`
- **Cloud Integration**: `syncCiphers()` updates local cache after Firebase sync
- **NEVER add playlist-specific loading** - use existing `loadCiphers()` if not `hasLoadedCiphers`

**VersionProvider `_versions` Cache:**
- **Cipher Expansion**: Multiple versions of one cipher (via `loadVersionsOfCipher()`)
- **Playlist Context**: Specific versions by IDs (via `loadVersionsForPlaylist()`)
- **Cache Conflicts**: Playlist loading overwrites cipher expansion - this is expected behavior

**Cache Cleaning Rules:**
```dart
// For navigating between library and playlist contexts:
versionProvider.clearVersions(); // Clears _versions safely
// CipherProvider._ciphers should persist across contexts (never clear in playlist)

// For cache consistency during updates:
// Always update both caches when modifying version data (see saveUpdatedSongStructure)
```

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

## 🔥 Firebase Integration Architecture

### On-Demand Download Strategy (Free Tier Optimized)
**Core Principle**: Only download full cipher data when user **actually views** the cipher, not when browsing or searching.

**Read Operation Optimization:**
- **Library Browsing**: Metadata only (title, author, tags) - 1 cached read per session
- **Cipher Viewing**: Full download on-demand - 1 read per unique cipher viewed
- **Result**: ~96% reduction in read operations vs. full sync approach

### Cloud Database Structure
```
firestore/
├── users/{userId}/
│   ├── profile: {name, email, preferences}  
│   ├── sharedPlaylists: {playlistId: permissions}
│   └── syncSessions: {sessionId: {timestamp, role}}
├── publicCiphers/{cipherId}/
│   ├── metadata: {title, author, musicKey, tags, downloadCount, lastUpdated}
│   └── fullData: {
│       versions: {versionId: {songStructure, sections: {...}}},
│       cipherData: {language, createdAt, contributors}
│     }
├── playlists/{playlistId}/
│   ├── metadata: {name, description, owner, public}
│   ├── items: [{type, contentId, order}]
│   ├── collaborators: {userId: permission}
│   └── presentation: {currentIndex, timestamp, presenter}
├── infoContent/{infoId}: {title, content, lastUpdated}
└── syncSessions/{sessionId}/
    ├── metadata: {playlistId, presenter, participants}
    └── state: {currentIndex, timestamp, isPlaying}
```

### Firebase Integration Patterns

**Critical Firebase Rules:**
1. **Offline-First Design**: SQLite remains primary data source, Firebase is download source
2. **On-Demand Downloads**: Only read full cipher data when viewing (not browsing)
3. **Repository Pattern Extension**: Extend existing repositories with cloud methods
4. **Permanent Local Storage**: Downloaded ciphers stored permanently in SQLite
5. **Authentication Required**: All cloud operations require Firebase Auth
6. **Real-time for Presentation Only**: Use Firestore listeners only for live presentation sync

**Firebase Services Structure:**
```dart
lib/services/
├── firebase_service.dart      // Core Firebase initialization
├── auth_service.dart          // Authentication wrapper
├── download_service.dart      // On-demand cipher downloads
└── presentation_sync_service.dart // Real-time presentation sync
```

**Cloud Repository Extensions:**
```dart
// Extend existing repositories, don't replace them
class CipherRepository {
  Future<List<CipherMetadata>> getPublicCipherMetadata(); // Browse without downloading
  Future<Cipher> downloadFirebaseCipher(String firebaseId); // Single read, full download
  Future<void> shareCipher(Cipher cipher); // Upload to shared collection
}
```

**Provider Integration:**
- `AuthProvider`: Manages Firebase Auth state
- `DownloadProvider`: Handles cipher download progress and caching
- `CipherProvider`: Extended with `loadCipherFromFirebase()` method
- Existing providers: Add cloud download methods without breaking local functionality

**Portuguese UI Extensions:**
- "Entrar" (Sign In), "Sair" (Sign Out)
- "Cifras da Nuvem" (Cloud Ciphers), "Baixar Cifra" (Download Cipher)
- "Baixando..." (Downloading...), "Cifra baixada!" (Cipher downloaded!)
- "Apresentação ao Vivo" (Live Presentation)

**Download Flow Integration:**
```dart
// In CipherViewer._loadData()
if (isFirebaseCipher(widget.cipherId)) {
  await cipherProvider.loadCipherFromFirebase(widget.firebaseCipherId);
} else {
  await cipherProvider.loadCipher(widget.cipherId); // Existing SQLite logic
}
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

### StatefulWidget Pattern for Provider Integration
**CRITICAL**: When creating widgets that need data from providers, follow this established pattern:

```dart
class MyWidget extends StatefulWidget {
  final int requiredId;
  final VoidCallback? onCallback;

  const MyWidget({
    super.key,
    required this.requiredId,
    this.onCallback,
  });

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Pre-load data with post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MyProvider>();
      if (!provider.isDataLoaded(widget.requiredId)) {
        provider.loadData(widget.requiredId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use for complex widgets that need to sync state when dependencies change
    // Example: When widget parameters change and need to reload provider data
    final provider = context.read<MyProvider>();
    if (provider.needsRefresh(widget.requiredId)) {
      provider.refreshData(widget.requiredId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        final data = provider.getCachedData(widget.requiredId);
        
        if (data == null) {
          return const CircularProgressIndicator();
        }

        return MyActualWidget(
          data: data,
          onAction: () => widget.onCallback?.call(),
        );
      },
    );
  }
}
```

**Key Pattern Rules:**
1. **Always use StatefulWidget** for provider-dependent widgets that need pre-loading
2. **Pre-load in `initState`** with `WidgetsBinding.instance.addPostFrameCallback`
3. **Use `didChangeDependencies`** for complex widgets that need to react to dependency changes
4. **Access widget properties** as `widget.propertyName` in StatefulWidget context
5. **Use Consumer pattern** for reactive UI updates
6. **Handle loading states** with proper null checks and loading indicators
7. **Generate globally unique keys** for lists/reorderable widgets: `ValueKey('scope_${widget.id}_item_${itemId}_occurrence_$count')` for ReorderableListView (never use index), `ValueKey('scope_${widget.id}_item_$index')` for regular lists

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
- **Firebase Stack (Future):**
  - `firebase_core: ^2.24.2` - Firebase initialization
  - `cloud_firestore: ^4.13.6` - Cloud database
  - `firebase_auth: ^4.15.3` - User authentication
  - `firebase_storage: ^11.5.6` - File storage (future attachments)

## 🚨 Common Pitfalls

1. **Don't skip `DatabaseFactoryHelper.initialize()`** - causes runtime errors on desktop
2. **Always dispose TextControllers** in complex forms like `cipher_section_form.dart`
3. **Use debouncing for form inputs** that trigger provider updates
4. **Check provider loading states** before navigation or operations
5. **Maintain Portuguese UI strings** - never hardcode English in user-facing text
6. **Firebase offline-first**: Always sync to local SQLite first, then push to Firebase
7. **Authentication flows**: Handle authentication state changes gracefully in providers


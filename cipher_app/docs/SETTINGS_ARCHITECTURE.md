# Settings Architecture Documentation

## Overview
Comprehensive settings system using SharedPreferences for persistence with automatic sync to providers for reactive UI updates.

## Architecture Components

### 1. SettingsService (`lib/services/settings_service.dart`)
- **Purpose**: Centralized storage service using SharedPreferences
- **Features**:
  - App-wide settings (theme, locale, notifications)
  - Layout settings (fonts, colors, display options)
  - Utility methods (export, clear, initialize)
- **Platform**: Cross-platform persistence (iOS, Android, Web, Desktop)

### 2. SettingsProvider (`lib/providers/settings_provider.dart`)
- **Purpose**: App-wide settings state management
- **Features**:
  - Theme mode (light/dark/system)
  - Notification preferences
  - Locale settings
  - Material 3 theme configurations
- **Usage**: Controls global app theme and behavior

### 3. LayoutSettingsProvider (`lib/providers/layout_settings_provider.dart`)
- **Purpose**: Cipher viewer layout settings
- **Features**:
  - Font size and family
  - Chord and lyric colors
  - Column count
  - Content filters (chords, lyrics, notes, transitions)
- **Usage**: Controls how cipher content is displayed

## Settings Categories

### App Settings
- **Theme Mode**: Light, Dark, System
- **Locale**: Language preference (currently pt_BR)
- **Notifications**: Enable/disable app notifications
- **Reminders**: Enable/disable reminder notifications

### Layout Settings
- **Typography**: Font size and family for chords and lyrics
- **Colors**: Customizable colors for chords and lyrics
- **Layout**: Column count for cipher display
- **Filters**: Show/hide chords, lyrics, notes, transitions

## Usage Examples

### Changing Theme
```dart
final settingsProvider = context.read<SettingsProvider>();
await settingsProvider.setThemeMode(ThemeMode.dark);
```

### Updating Font Size
```dart
final layoutProvider = context.read<LayoutSettingsProvider>();
layoutProvider.setFontSize(18.0);
```

### Accessing Settings in Widgets
```dart
Consumer<SettingsProvider>(
  builder: (context, settings, child) {
    return Text('Current theme: ${settings.themeMode}');
  },
)
```

## Persistence Strategy

### Current Implementation
- **Local**: SharedPreferences for immediate access
- **Automatic**: Settings saved immediately on change
- **Reactive**: UI updates automatically via providers

### Future Firebase Integration
- When user authentication is added:
  1. Sync settings to Firestore on change
  2. Load user settings from Firestore on login
  3. Maintain local cache for offline use
  4. Conflict resolution for multi-device sync

## File Structure
```
lib/
├── services/
│   └── settings_service.dart        # Storage layer
├── providers/
│   ├── settings_provider.dart       # App settings state
│   └── layout_settings_provider.dart # Layout settings state
└── screens/
    └── settings_screen.dart         # Settings UI
```

## Initialization
Settings are initialized in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.initialize();
  runApp(const MyApp());
}
```

## Benefits
1. **Fast Access**: Local storage for immediate response
2. **Reactive UI**: Automatic updates via Provider pattern
3. **Persistence**: Settings survive app restarts
4. **Extensible**: Easy to add new settings
5. **Future-Ready**: Prepared for Firebase sync
6. **Type-Safe**: Strongly typed settings access
7. **Debuggable**: Export/import for troubleshooting

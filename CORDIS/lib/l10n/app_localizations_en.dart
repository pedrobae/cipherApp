// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CORDIS';

  @override
  String get home => 'Home';

  @override
  String get library => 'Library';

  @override
  String get playlists => 'Playlists';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get schedule => 'Schedule';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Log In';

  @override
  String get logInTitlePrefix => 'Sign in to ';

  @override
  String get logOut => 'Sign Out';

  @override
  String get accountCreationPrefix => 'New User? ';

  @override
  String get accountCreationSuffix => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordSuffix => 'Please try again or Request a new one.';

  @override
  String get title => 'Song Title';

  @override
  String get author => 'Author';

  @override
  String get versionName => 'Version Name';

  @override
  String get musicKey => 'Key';

  @override
  String get bpm => 'BPM';

  @override
  String get duration => 'Duration';

  @override
  String get language => 'Language';

  @override
  String get sections => 'Sections';

  @override
  String get versions => ' versions';

  @override
  String get cipherEditorTitle => 'Song Editor';

  @override
  String get info => 'Info';

  @override
  String get cloudCipher => 'Cloud Song Map';

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get searchCiphers => 'Search title, author...';

  @override
  String get create => 'Create';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get noCiphersFound => 'No Song Map found';

  @override
  String get loading => 'Loading...';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get hintPrefixO => 'Enter your ';

  @override
  String get hintPrefixA => 'Enter your ';

  @override
  String get hintSuffix => ' here...';

  @override
  String get noSectionsInStructurePrompt =>
      'No sections in structure. Use the button above to add sections.';

  @override
  String get songStructure => 'Song Structure';

  @override
  String get addSection => 'Add Section';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get failedToCreateCipher => 'Failed to create cipher.';

  @override
  String get failedToCreateVersion => 'Failed to create version.';

  @override
  String get cipherCreatedSuccessfully => 'Cipher created successfully!';

  @override
  String get errorCreating => 'Error creating: ';

  @override
  String get cipherSavedSuccessfully => 'Cipher saved successfully!';

  @override
  String get cannotCreateCipherExistingCipher =>
      'Could not create cipher: existing cipher found.';

  @override
  String welcome(Object userName) {
    return 'Hello $userName';
  }

  @override
  String get anonymousWelcome => 'Welcome';

  @override
  String get by => 'by';
}

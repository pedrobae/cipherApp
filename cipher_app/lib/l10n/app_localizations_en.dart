// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Worship Link';

  @override
  String get email => 'Email';

  @override
  String get library => 'Library';

  @override
  String get home => 'Home';

  @override
  String get playlists => 'Playlists';

  @override
  String get logInTitlePrefix => 'Login to ';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordSuffix => 'Please try again or Request a new one.';

  @override
  String get login => 'Log In';

  @override
  String get accountCreationPrefix => 'New User? ';

  @override
  String get accountCreationSuffix => 'Sign Up';
}

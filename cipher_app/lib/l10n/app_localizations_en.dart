// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginOrSignUp => 'Login or Sign Up';

  @override
  String get loginDescription =>
      'Please select your preferred method to continue setting up your account';

  @override
  String get emailLogin => 'Continue with Email';

  @override
  String get phoneLogin => 'Continue with Phone';

  @override
  String get accountCreationPrefix => 'If you are creating a new account, ';

  @override
  String get accountCreationMiddle => ' and ';

  @override
  String get accountCreationSuffix => ' will apply.';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get library => 'Library';

  @override
  String get home => 'Home';

  @override
  String get playlists => 'Playlists';
}

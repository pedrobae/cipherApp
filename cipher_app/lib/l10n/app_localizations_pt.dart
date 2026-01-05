// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Worship Link';

  @override
  String get email => 'E-mail';

  @override
  String get library => 'Biblioteca';

  @override
  String get home => 'Home';

  @override
  String get playlists => 'Playlists';

  @override
  String get logInTitlePrefix => 'Login no ';

  @override
  String get password => 'Senha';

  @override
  String get forgotPassword => 'Esqueceu a Senha?';

  @override
  String get forgotPasswordSuffix =>
      'Por favor, tente novamente ou solicite uma nova.';

  @override
  String get login => 'Entrar';

  @override
  String get accountCreationPrefix => 'Não tem uma conta? ';

  @override
  String get accountCreationSuffix => 'Registre-se.';
}

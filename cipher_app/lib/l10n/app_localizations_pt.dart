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
  String get loginOrSignUp => 'Login ou Cadastro';

  @override
  String get loginDescription =>
      'Selecione um método para terminar de configurar sua conta';

  @override
  String get emailLogin => 'Entrar com E-mail';

  @override
  String get phoneLogin => 'Entrar com Telefone';

  @override
  String get accountCreationPrefix => 'Se você está criando uma conta, ';

  @override
  String get accountCreationMiddle => ' e ';

  @override
  String get accountCreationSuffix => ' se aplicarão.';

  @override
  String get termsAndConditions => 'Termos & Condições';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get library => 'Biblioteca';

  @override
  String get home => 'Home';

  @override
  String get playlists => 'Playlists';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'CORDIS'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @library.
  ///
  /// In pt, this message translates to:
  /// **'Biblioteca'**
  String get library;

  /// No description provided for @playlists.
  ///
  /// In pt, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get about;

  /// No description provided for @schedule.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get schedule;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// Prefix to use in conjunction with appName
  ///
  /// In pt, this message translates to:
  /// **'Login no '**
  String get logInTitlePrefix;

  /// No description provided for @logOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logOut;

  /// Prefix text for account creation prompt
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta? '**
  String get accountCreationPrefix;

  /// Suffix text for account creation prompt
  ///
  /// In pt, this message translates to:
  /// **'Registre-se.'**
  String get accountCreationSuffix;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a Senha?'**
  String get forgotPassword;

  /// Suffix text for forgot password message
  ///
  /// In pt, this message translates to:
  /// **'Por favor, tente novamente ou solicite uma nova.'**
  String get forgotPasswordSuffix;

  /// No description provided for @title.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @author.
  ///
  /// In pt, this message translates to:
  /// **'Autor'**
  String get author;

  /// No description provided for @versionName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da Versão'**
  String get versionName;

  /// No description provided for @musicKey.
  ///
  /// In pt, this message translates to:
  /// **'Tom'**
  String get musicKey;

  /// No description provided for @bpm.
  ///
  /// In pt, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// No description provided for @duration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get duration;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @sections.
  ///
  /// In pt, this message translates to:
  /// **'Seções'**
  String get sections;

  /// Label for number of versions of a cipher (lowercase 'v')
  ///
  /// In pt, this message translates to:
  /// **' versões'**
  String get versions;

  /// No description provided for @cipherEditorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editor de Cifras'**
  String get cipherEditorTitle;

  /// No description provided for @info.
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get info;

  /// No description provided for @cloudCipher.
  ///
  /// In pt, this message translates to:
  /// **'Cifra na Nuvem'**
  String get cloudCipher;

  /// No description provided for @addToPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar à Playlist'**
  String get addToPlaylist;

  /// No description provided for @searchCiphers.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar por título, autor...'**
  String get searchCiphers;

  /// No description provided for @create.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get create;

  /// No description provided for @filter.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// Message displayed when no ciphers are found
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma cifra encontrada'**
  String get noCiphersFound;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// Prefix to be used with the relevant error message
  ///
  /// In pt, this message translates to:
  /// **'Erro: '**
  String get errorPrefix;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar Novamente'**
  String get tryAgain;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// Prefix to be used on text fields with masculine nouns
  ///
  /// In pt, this message translates to:
  /// **'Insira seu '**
  String get hintPrefixO;

  /// Prefix to be used on text fields with feminine nouns
  ///
  /// In pt, this message translates to:
  /// **'Insira sua '**
  String get hintPrefixA;

  /// Suffix to be used on text fields
  ///
  /// In pt, this message translates to:
  /// **' aqui...'**
  String get hintSuffix;

  /// Prompt displayed when there are no sections in the song structure
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma seção na estrutura. Use o botão acima para adicionar seções.'**
  String get noSectionsInStructurePrompt;

  /// No description provided for @songStructure.
  ///
  /// In pt, this message translates to:
  /// **'Mapa da Música'**
  String get songStructure;

  /// No description provided for @addSection.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Seção'**
  String get addSection;

  /// No description provided for @lyrics.
  ///
  /// In pt, this message translates to:
  /// **'Letras'**
  String get lyrics;

  /// No description provided for @failedToCreateCipher.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao criar cifra.'**
  String get failedToCreateCipher;

  /// No description provided for @failedToCreateVersion.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao criar versão.'**
  String get failedToCreateVersion;

  /// No description provided for @cipherCreatedSuccessfully.
  ///
  /// In pt, this message translates to:
  /// **'Cifra criada com sucesso!'**
  String get cipherCreatedSuccessfully;

  /// Prefix to be used with the relevant error message when creating a cipher
  ///
  /// In pt, this message translates to:
  /// **'Erro ao criar: '**
  String get errorCreating;

  /// No description provided for @cipherSavedSuccessfully.
  ///
  /// In pt, this message translates to:
  /// **'Cifra salva com sucesso!'**
  String get cipherSavedSuccessfully;

  /// No description provided for @cannotCreateCipherExistingCipher.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar a cifra porque uma cifra com o mesmo ID já existe.'**
  String get cannotCreateCipherExistingCipher;

  /// Welcome message with the user's name
  ///
  /// In pt, this message translates to:
  /// **'Olá {userName}'**
  String welcome(Object userName);

  /// No description provided for @anonymousWelcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo'**
  String get anonymousWelcome;

  /// No description provided for @by.
  ///
  /// In pt, this message translates to:
  /// **'por'**
  String get by;

  /// No description provided for @nextUp.
  ///
  /// In pt, this message translates to:
  /// **'Próxima Agenda'**
  String get nextUp;

  /// No description provided for @playlist.
  ///
  /// In pt, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @role.
  ///
  /// In pt, this message translates to:
  /// **'Função'**
  String get role;

  /// No description provided for @generalMember.
  ///
  /// In pt, this message translates to:
  /// **'Membro Geral'**
  String get generalMember;

  /// No description provided for @share.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get share;

  /// No description provided for @view.
  ///
  /// In pt, this message translates to:
  /// **'Visualizar'**
  String get view;

  /// No description provided for @createPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Criar Playlist'**
  String get createPlaylist;

  /// No description provided for @addSongToLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Música'**
  String get addSongToLibrary;

  /// No description provided for @assignSchedule.
  ///
  /// In pt, this message translates to:
  /// **'Agendar'**
  String get assignSchedule;

  /// Hint text for searching playlists
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar por nome da playlist...'**
  String get searchPlaylist;

  /// Message displayed when no playlists are found
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma playlist encontrada'**
  String get noPlaylistsFound;

  /// No description provided for @item.
  ///
  /// In pt, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In pt, this message translates to:
  /// **'itens'**
  String get items;

  /// No description provided for @nextThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Ainda neste Mês'**
  String get nextThisMonth;

  /// No description provided for @searchSchedule.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar nome, local...'**
  String get searchSchedule;

  /// No description provided for @selectSectionType.
  ///
  /// In pt, this message translates to:
  /// **'Selecione sua Seção'**
  String get selectSectionType;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

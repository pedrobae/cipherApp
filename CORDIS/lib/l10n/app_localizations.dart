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

  /// Application name
  ///
  /// In pt, this message translates to:
  /// **'CORDIS'**
  String get appName;

  /// Authentication related messages
  ///
  /// In pt, this message translates to:
  /// **'Autenticação'**
  String get authentication;

  /// Email field label
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// Password field label
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// Login button label
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// Prefix to use in conjunction with appName
  ///
  /// In pt, this message translates to:
  /// **'Login no '**
  String get logInTitlePrefix;

  /// Logout button label
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

  /// Forgot password link label
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a Senha?'**
  String get forgotPassword;

  /// Suffix text for forgot password message
  ///
  /// In pt, this message translates to:
  /// **'Por favor, tente novamente ou solicite uma nova.'**
  String get forgotPasswordSuffix;

  /// Home navigation tab
  ///
  /// In pt, this message translates to:
  /// **'Home'**
  String get home;

  /// Library navigation tab
  ///
  /// In pt, this message translates to:
  /// **'Biblioteca'**
  String get library;

  /// Playlists navigation tab
  ///
  /// In pt, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// Schedule navigation tab
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get schedule;

  /// Settings navigation tab
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// About navigation tab
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get about;

  /// Song title field label
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get title;

  /// Song author field label
  ///
  /// In pt, this message translates to:
  /// **'Autor'**
  String get author;

  /// Musical key field label
  ///
  /// In pt, this message translates to:
  /// **'Tom'**
  String get musicKey;

  /// Beats per minute field label
  ///
  /// In pt, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// Song duration field label
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get duration;

  /// Song language field label
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Version name field label
  ///
  /// In pt, this message translates to:
  /// **'Nome da Versão'**
  String get versionName;

  /// Label for number of versions of a cipher (lowercase 'v')
  ///
  /// In pt, this message translates to:
  /// **' versões'**
  String get versions;

  /// Sections field label
  ///
  /// In pt, this message translates to:
  /// **'Seções'**
  String get sections;

  /// Section label
  ///
  /// In pt, this message translates to:
  /// **'Seção'**
  String get section;

  /// Song structure/map label
  ///
  /// In pt, this message translates to:
  /// **'Mapa da Música'**
  String get songStructure;

  /// Add section button label
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Seção'**
  String get addSection;

  /// Prompt to select a section type
  ///
  /// In pt, this message translates to:
  /// **'Selecione sua Seção'**
  String get selectSectionType;

  /// Prompt displayed when there are no sections in the song structure
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma seção na estrutura. Use o botão acima para adicionar seções.'**
  String get noSectionsInStructurePrompt;

  /// Lyrics field label
  ///
  /// In pt, this message translates to:
  /// **'Letras'**
  String get lyrics;

  /// Section code field label
  ///
  /// In pt, this message translates to:
  /// **'Código da Seção'**
  String get sectionCode;

  /// Section type field label
  ///
  /// In pt, this message translates to:
  /// **'Tipo da Seção'**
  String get sectionType;

  /// Section color field label
  ///
  /// In pt, this message translates to:
  /// **'Cor da Seção'**
  String get sectionColor;

  /// Hint text for section text input
  ///
  /// In pt, this message translates to:
  /// **'Texto da Seção...'**
  String get sectionText;

  /// Title for the cipher/song editor screen
  ///
  /// In pt, this message translates to:
  /// **'Editor de Cifras'**
  String get cipherEditorTitle;

  /// Label for cloud-based song maps
  ///
  /// In pt, this message translates to:
  /// **'Cifra na Nuvem'**
  String get cloudCipher;

  /// Title for the cipher parsing screen
  ///
  /// In pt, this message translates to:
  /// **'Escolhendo Análise'**
  String get cipherParsing;

  /// Information button/tab label
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get info;

  /// Success message when cipher is created
  ///
  /// In pt, this message translates to:
  /// **'Cifra criada com sucesso!'**
  String get cipherCreatedSuccessfully;

  /// Success message when cipher is saved
  ///
  /// In pt, this message translates to:
  /// **'Cifra salva com sucesso!'**
  String get cipherSavedSuccessfully;

  /// Error message when cipher creation fails
  ///
  /// In pt, this message translates to:
  /// **'Falha ao criar cifra.'**
  String get failedToCreateCipher;

  /// Error message when version creation fails
  ///
  /// In pt, this message translates to:
  /// **'Falha ao criar versão.'**
  String get failedToCreateVersion;

  /// Error message when trying to create duplicate cipher
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar a cifra porque uma cifra com o mesmo ID já existe.'**
  String get cannotCreateCipherExistingCipher;

  /// Hint text for cipher search field
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar por título, autor...'**
  String get searchCiphers;

  /// Filter button label
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// Sort button label
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// Message displayed when no ciphers are found
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma cifra encontrada'**
  String get noCiphersFound;

  /// Create playlist button label
  ///
  /// In pt, this message translates to:
  /// **'Criar Playlist'**
  String get createPlaylist;

  /// Prompt to name the playlist
  ///
  /// In pt, this message translates to:
  /// **'Nomeie sua playlist'**
  String get namePlaylistPrompt;

  /// Instructions for creating a new playlist
  ///
  /// In pt, this message translates to:
  /// **'Crie uma playlist vazia primeiro, você pode adicionar músicas e seções faladas depois.'**
  String get createPlaylistInstructions;

  /// Label for playlist name input field
  ///
  /// In pt, this message translates to:
  /// **'Nome da Playlist'**
  String get playlistNameLabel;

  /// Hint text for playlist name input field
  ///
  /// In pt, this message translates to:
  /// **'Insira o nome da playlist'**
  String get playlistNameHint;

  /// Playlist label
  ///
  /// In pt, this message translates to:
  /// **'Playlist'**
  String get playlist;

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

  /// Add song to playlist button label
  ///
  /// In pt, this message translates to:
  /// **'Adicionar à Playlist'**
  String get addToPlaylist;

  /// Singular item label
  ///
  /// In pt, this message translates to:
  /// **'item'**
  String get item;

  /// Plural items label
  ///
  /// In pt, this message translates to:
  /// **'itens'**
  String get items;

  /// User role label
  ///
  /// In pt, this message translates to:
  /// **'Função'**
  String get role;

  /// Default user role
  ///
  /// In pt, this message translates to:
  /// **'Membro Geral'**
  String get generalMember;

  /// Share button label
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get share;

  /// View button label
  ///
  /// In pt, this message translates to:
  /// **'Visualizar'**
  String get view;

  /// Next scheduled item label
  ///
  /// In pt, this message translates to:
  /// **'Próxima Agenda'**
  String get nextUp;

  /// Next scheduled item this month label
  ///
  /// In pt, this message translates to:
  /// **'Ainda neste Mês'**
  String get nextThisMonth;

  /// Hint text for searching schedule
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar nome, local...'**
  String get searchSchedule;

  /// Assign schedule button label
  ///
  /// In pt, this message translates to:
  /// **'Agendar'**
  String get assignSchedule;

  /// Create button label
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get create;

  /// Create manually option label
  ///
  /// In pt, this message translates to:
  /// **'Criar Manualmente'**
  String get createManually;

  /// Import button label
  ///
  /// In pt, this message translates to:
  /// **'Importar'**
  String get import;

  /// Import from PDF option
  ///
  /// In pt, this message translates to:
  /// **'Importar de PDF'**
  String get importFromPDF;

  /// Prompt to select a PDF file
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Arquivo PDF'**
  String get selectPDFFile;

  /// Label for displaying the selected file name
  ///
  /// In pt, this message translates to:
  /// **'Arquivo Selecionado: '**
  String get selectedFile;

  /// Process PDF button label
  ///
  /// In pt, this message translates to:
  /// **'Processar PDF'**
  String get processPDF;

  /// How to import instructions title
  ///
  /// In pt, this message translates to:
  /// **'Como Importar'**
  String get howToImport;

  /// Instructions for importing a song map from a PDF file
  ///
  /// In pt, this message translates to:
  /// **'• Selecione um PDF com cifra\n• Fonte mono é recomendada se possível\n• Separe estrofes com linhas vazias\n• Acordes acima das letras'**
  String get importInstructions;

  /// Import from image option
  ///
  /// In pt, this message translates to:
  /// **'Importar de Imagem'**
  String get importFromImage;

  /// Import from text option
  ///
  /// In pt, this message translates to:
  /// **'Importar de Texto'**
  String get importFromText;

  /// Prompt to paste cipher text
  ///
  /// In pt, this message translates to:
  /// **'Cole o texto da cifra aqui...'**
  String get pasteTextPrompt;

  /// Text indicating the source from which the song was imported
  ///
  /// In pt, this message translates to:
  /// **'Cifra importada de {importType}'**
  String importedFrom(Object importType);

  /// Add song to library button label
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Música'**
  String get addSongToLibrary;

  /// Title for parsing strategy selection
  ///
  /// In pt, this message translates to:
  /// **'Estratégia de Processamento'**
  String get parsingStrategy;

  /// Parsing strategy option for double new lines
  ///
  /// In pt, this message translates to:
  /// **'Dupla Nova Linha'**
  String get doubleNewLine;

  /// Parsing strategy option for section labels
  ///
  /// In pt, this message translates to:
  /// **'Rótulos de Seção'**
  String get sectionLabels;

  /// Parsing strategy option for PDF formatting
  ///
  /// In pt, this message translates to:
  /// **'Formatação PDF'**
  String get pdfFormatting;

  /// Title for import variation selection
  ///
  /// In pt, this message translates to:
  /// **'Variação de Importação'**
  String get importVariation;

  /// Import variation option for PDF with columns
  ///
  /// In pt, this message translates to:
  /// **'PDF com Colunas'**
  String get pdfWithColumns;

  /// Import variation option for PDF without columns
  ///
  /// In pt, this message translates to:
  /// **'PDF sem Colunas'**
  String get pdfNoColumns;

  /// Import variation option for direct text
  ///
  /// In pt, this message translates to:
  /// **'Texto Simples'**
  String get textDirect;

  /// Import variation option for image with OCR
  ///
  /// In pt, this message translates to:
  /// **'Imagem com OCR'**
  String get imageOcr;

  /// Choose language prompt
  ///
  /// In pt, this message translates to:
  /// **'Escolher Idioma'**
  String get chooseLanguage;

  /// Language selection instruction
  ///
  /// In pt, this message translates to:
  /// **'Selecione o idioma do aplicativo:'**
  String get selectAppLanguage;

  /// Portuguese language option
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// English language option
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get english;

  /// Loading indicator text
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// Retry button label
  ///
  /// In pt, this message translates to:
  /// **'Tentar Novamente'**
  String get tryAgain;

  /// Save button label
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// Cancel button label
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Delete button label
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// Confirm button label
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Edit placeholder with object name
  ///
  /// In pt, this message translates to:
  /// **'Editar {object}'**
  String editPlaceholder(Object object);

  /// Welcome message with the user's name
  ///
  /// In pt, this message translates to:
  /// **'Olá {userName}'**
  String welcome(Object userName);

  /// Generic welcome message
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo'**
  String get anonymousWelcome;

  /// By/author preposition
  ///
  /// In pt, this message translates to:
  /// **'por'**
  String get by;

  /// Label for the song title with placeholder
  ///
  /// In pt, this message translates to:
  /// **'Título: {title}'**
  String titleWithPlaceholder(Object title);

  /// Label for the author with placeholder
  ///
  /// In pt, this message translates to:
  /// **'Autor: {author}'**
  String authorWithPlaceholder(Object author);

  /// Label for the BPM with placeholder
  ///
  /// In pt, this message translates to:
  /// **'BPM: {bpm}'**
  String bpmWithPlaceholder(Object bpm);

  /// Label for the music key with placeholder
  ///
  /// In pt, this message translates to:
  /// **'Tom: {key}'**
  String keyWithPlaceholder(Object key);

  /// Label for number of sections with placeholder
  ///
  /// In pt, this message translates to:
  /// **'{count} seções'**
  String nSections(Object count);

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

  /// Generic error message with placeholders
  ///
  /// In pt, this message translates to:
  /// **'Erro durante {job}: {errorDetails}'**
  String errorMessage(Object job, Object errorDetails);
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

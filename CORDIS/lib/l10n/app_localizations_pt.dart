// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'CORDIS';

  @override
  String get authentication => 'Autenticação';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get login => 'Entrar';

  @override
  String get logInTitlePrefix => 'Login no ';

  @override
  String get logOut => 'Sair';

  @override
  String get accountCreationPrefix => 'Não tem uma conta? ';

  @override
  String get accountCreationSuffix => 'Registre-se.';

  @override
  String get forgotPassword => 'Esqueceu a Senha?';

  @override
  String get forgotPasswordSuffix =>
      'Por favor, tente novamente ou solicite uma nova.';

  @override
  String get home => 'Home';

  @override
  String get library => 'Biblioteca';

  @override
  String get playlists => 'Playlists';

  @override
  String get schedule => 'Agenda';

  @override
  String get settings => 'Configurações';

  @override
  String get about => 'Sobre';

  @override
  String get title => 'Título';

  @override
  String get author => 'Autor';

  @override
  String get musicKey => 'Tom';

  @override
  String get bpm => 'BPM';

  @override
  String get duration => 'Duração';

  @override
  String get language => 'Idioma';

  @override
  String get versionName => 'Nome da Versão';

  @override
  String get versions => ' versões';

  @override
  String get sections => 'Seções';

  @override
  String get section => 'Seção';

  @override
  String get songStructure => 'Mapa da Música';

  @override
  String get addSection => 'Adicionar Seção';

  @override
  String get selectSectionType => 'Selecione sua Seção';

  @override
  String get noSectionsInStructurePrompt =>
      'Nenhuma seção na estrutura. Use o botão acima para adicionar seções.';

  @override
  String get lyrics => 'Letras';

  @override
  String get sectionCode => 'Código da Seção';

  @override
  String get sectionType => 'Tipo da Seção';

  @override
  String get sectionColor => 'Cor da Seção';

  @override
  String get sectionText => 'Texto da Seção...';

  @override
  String get cipherEditorTitle => 'Editor de Cifras';

  @override
  String get cloudCipher => 'Cifra na Nuvem';

  @override
  String get cipherParsing => 'Escolhendo Análise';

  @override
  String get info => 'Informações';

  @override
  String get cipherCreatedSuccessfully => 'Cifra criada com sucesso!';

  @override
  String get cipherSavedSuccessfully => 'Cifra salva com sucesso!';

  @override
  String get failedToCreateCipher => 'Falha ao criar cifra.';

  @override
  String get failedToCreateVersion => 'Falha ao criar versão.';

  @override
  String get cannotCreateCipherExistingCipher =>
      'Não foi possível criar a cifra porque uma cifra com o mesmo ID já existe.';

  @override
  String get searchCiphers => 'Pesquisar por título, autor...';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get noCiphersFound => 'Nenhuma cifra encontrada';

  @override
  String get createPlaylist => 'Criar Playlist';

  @override
  String get namePlaylistPrompt => 'Nomeie sua playlist';

  @override
  String get createPlaylistInstructions =>
      'Crie uma playlist vazia primeiro, você pode adicionar músicas e seções faladas depois.';

  @override
  String get playlistNameLabel => 'Nome da Playlist';

  @override
  String get playlistNameHint => 'Insira o nome da playlist';

  @override
  String get playlist => 'Playlist';

  @override
  String get searchPlaylist => 'Pesquisar por nome da playlist...';

  @override
  String get noPlaylistsFound => 'Nenhuma playlist encontrada';

  @override
  String get addToPlaylist => 'Adicionar à Playlist';

  @override
  String get item => 'item';

  @override
  String get items => 'itens';

  @override
  String get role => 'Função';

  @override
  String get generalMember => 'Membro Geral';

  @override
  String get share => 'Compartilhar';

  @override
  String get view => 'Visualizar';

  @override
  String get nextUp => 'Próxima Agenda';

  @override
  String get nextThisMonth => 'Ainda neste Mês';

  @override
  String get searchSchedule => 'Pesquisar nome, local...';

  @override
  String get assignSchedule => 'Agendar';

  @override
  String get create => 'Criar';

  @override
  String get createManually => 'Criar Manualmente';

  @override
  String get import => 'Importar';

  @override
  String get importFromPDF => 'Importar de PDF';

  @override
  String get selectPDFFile => 'Selecionar Arquivo PDF';

  @override
  String get selectedFile => 'Arquivo Selecionado: ';

  @override
  String get processPDF => 'Processar PDF';

  @override
  String get howToImport => 'Como Importar';

  @override
  String get importInstructions =>
      '• Selecione um PDF com cifra\n• Fonte mono é recomendada se possível\n• Separe estrofes com linhas vazias\n• Acordes acima das letras';

  @override
  String get importFromImage => 'Importar de Imagem';

  @override
  String get importFromText => 'Importar de Texto';

  @override
  String get pasteTextPrompt => 'Cole o texto da cifra aqui...';

  @override
  String importedFrom(Object importType) {
    return 'Cifra importada de $importType';
  }

  @override
  String get addSongToLibrary => 'Adicionar Música';

  @override
  String get parsingStrategy => 'Estratégia de Processamento';

  @override
  String get doubleNewLine => 'Dupla Nova Linha';

  @override
  String get sectionLabels => 'Rótulos de Seção';

  @override
  String get pdfFormatting => 'Formatação PDF';

  @override
  String get importVariation => 'Variação de Importação';

  @override
  String get pdfWithColumns => 'PDF com Colunas';

  @override
  String get pdfNoColumns => 'PDF sem Colunas';

  @override
  String get textDirect => 'Texto Simples';

  @override
  String get imageOcr => 'Imagem com OCR';

  @override
  String get chooseLanguage => 'Escolher Idioma';

  @override
  String get selectAppLanguage => 'Selecione o idioma do aplicativo:';

  @override
  String get portuguese => 'Português';

  @override
  String get english => 'Inglês';

  @override
  String get loading => 'Carregando...';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String editPlaceholder(Object object) {
    return 'Editar $object';
  }

  @override
  String welcome(Object userName) {
    return 'Olá $userName';
  }

  @override
  String get anonymousWelcome => 'Bem-vindo';

  @override
  String get by => 'por';

  @override
  String titleWithPlaceholder(Object title) {
    return 'Título: $title';
  }

  @override
  String authorWithPlaceholder(Object author) {
    return 'Autor: $author';
  }

  @override
  String bpmWithPlaceholder(Object bpm) {
    return 'BPM: $bpm';
  }

  @override
  String keyWithPlaceholder(Object key) {
    return 'Tom: $key';
  }

  @override
  String nSections(Object count) {
    return '$count seções';
  }

  @override
  String get hintPrefixO => 'Insira seu ';

  @override
  String get hintPrefixA => 'Insira sua ';

  @override
  String get hintSuffix => ' aqui...';

  @override
  String errorMessage(Object job, Object errorDetails) {
    return 'Erro durante $job: $errorDetails';
  }
}

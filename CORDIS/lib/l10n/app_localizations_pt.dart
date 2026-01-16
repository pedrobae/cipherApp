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
  String get home => 'Home';

  @override
  String get library => 'Biblioteca';

  @override
  String get playlists => 'Playlists';

  @override
  String get settings => 'Configurações';

  @override
  String get about => 'Sobre';

  @override
  String get schedule => 'Agenda';

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
  String get title => 'Título';

  @override
  String get author => 'Autor';

  @override
  String get versionName => 'Nome da Versão';

  @override
  String get musicKey => 'Tom';

  @override
  String get bpm => 'BPM';

  @override
  String get duration => 'Duração';

  @override
  String get language => 'Idioma';

  @override
  String get sections => 'Seções';

  @override
  String get versions => ' versões';

  @override
  String get cipherEditorTitle => 'Editor de Cifras';

  @override
  String get info => 'Informações';

  @override
  String get cloudCipher => 'Cifra na Nuvem';

  @override
  String get addToPlaylist => 'Adicionar à Playlist';

  @override
  String get searchCiphers => 'Pesquisar por título, autor...';

  @override
  String get create => 'Criar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get noCiphersFound => 'Nenhuma cifra encontrada';

  @override
  String get loading => 'Carregando...';

  @override
  String get errorPrefix => 'Erro: ';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get hintPrefixO => 'Insira seu ';

  @override
  String get hintPrefixA => 'Insira sua ';

  @override
  String get hintSuffix => ' aqui...';

  @override
  String get noSectionsInStructurePrompt =>
      'Nenhuma seção na estrutura. Use o botão acima para adicionar seções.';

  @override
  String get songStructure => 'Mapa da Música';

  @override
  String get addSection => 'Adicionar Seção';

  @override
  String get lyrics => 'Letras';

  @override
  String get failedToCreateCipher => 'Falha ao criar cifra.';

  @override
  String get failedToCreateVersion => 'Falha ao criar versão.';

  @override
  String get cipherCreatedSuccessfully => 'Cifra criada com sucesso!';

  @override
  String get errorCreating => 'Erro ao criar: ';

  @override
  String get cipherSavedSuccessfully => 'Cifra salva com sucesso!';

  @override
  String get cannotCreateCipherExistingCipher =>
      'Não foi possível criar a cifra porque uma cifra com o mesmo ID já existe.';

  @override
  String welcome(Object userName) {
    return 'Olá $userName';
  }

  @override
  String get anonymousWelcome => 'Bem-vindo';

  @override
  String get by => 'por';

  @override
  String get nextUp => 'Próxima Agenda';

  @override
  String get playlist => 'Playlist';

  @override
  String get role => 'Função';

  @override
  String get generalMember => 'Membro Geral';

  @override
  String get share => 'Compartilhar';

  @override
  String get view => 'Visualizar';

  @override
  String get createPlaylist => 'Criar Playlist';

  @override
  String get addSongToLibrary => 'Adicionar Música';

  @override
  String get assignSchedule => 'Agendar';
}

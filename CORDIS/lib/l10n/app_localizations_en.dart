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
  String get authentication => 'Authentication';

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
  String get user => 'User';

  @override
  String get name => 'Name';

  @override
  String get enterNameHint => 'Enter name...';

  @override
  String get enterEmailHint => 'Enter email...';

  @override
  String get pleaseEnterNameAndEmail => 'Please enter name and email.';

  @override
  String get userNotFoundInCloud => 'User not found in cloud.';

  @override
  String get home => 'Home';

  @override
  String get library => 'Library';

  @override
  String get playlists => 'Playlists';

  @override
  String get schedule => 'Schedule';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get cipher => 'Song';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'Enter title ...';

  @override
  String get author => 'Author';

  @override
  String get musicKey => 'Key';

  @override
  String get bpm => 'BPM';

  @override
  String get duration => 'Duration';

  @override
  String get language => 'Language';

  @override
  String get version => 'Version';

  @override
  String get versionName => 'Version Name';

  @override
  String get versions => ' versions';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get sections => 'Sections';

  @override
  String get section => 'Section';

  @override
  String get songStructure => 'Song Structure';

  @override
  String get selectSectionType => 'Select your Section';

  @override
  String get noSectionsInStructurePrompt =>
      'No sections in structure. Use the button above to add sections.';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get sectionCode => 'Section Code';

  @override
  String get sectionType => 'Section Type';

  @override
  String get sectionColor => 'Section Color';

  @override
  String get sectionText => 'Section Text...';

  @override
  String get cipherEditorTitle => 'Song Editor';

  @override
  String get cloudCipher => 'Cloud Song Map';

  @override
  String get cipherParsing => 'Choosing Parsing';

  @override
  String get info => 'Info';

  @override
  String get cipherCreatedSuccessfully => 'Cipher created successfully!';

  @override
  String get cipherSavedSuccessfully => 'Cipher saved successfully!';

  @override
  String get failedToCreateCipher => 'Failed to create cipher.';

  @override
  String get failedToCreateVersion => 'Failed to create version.';

  @override
  String get cannotCreateCipherExistingCipher =>
      'Could not create cipher: existing cipher found.';

  @override
  String get deleteCipherDescription =>
      'When deleting a song, all its versions will also be deleted. This action cannot be undone.';

  @override
  String get searchCiphers => 'Search title, author...';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get noCiphersFound => 'No Song Map found';

  @override
  String get playlist => 'Playlist';

  @override
  String get flowItem => 'Flow Item';

  @override
  String get namePlaylistPrompt => 'Name your playlist';

  @override
  String get createPlaylistInstructions =>
      'Create an empty playlist first, you can add songs and flow items later.';

  @override
  String get playlistNameLabel => 'Playlist Name';

  @override
  String get playlistNameHint => 'Enter a playlist name';

  @override
  String get searchPlaylist => 'Search playlists...';

  @override
  String get noPlaylistsFound => 'No playlists found';

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get emptyPlaylist => 'This Playlist is empty.';

  @override
  String get emptyPlaylistInstructions =>
      'Please add Song and Flow items to build your playlist.';

  @override
  String get deletePlaylistDescription =>
      'When deleting a playlist, all of its items will also be deleted. This action cannot be undone.';

  @override
  String get item => 'item';

  @override
  String get role => 'Role';

  @override
  String get generalMember => 'General Member';

  @override
  String get share => 'Share';

  @override
  String get view => 'View';

  @override
  String createPlaceholder(Object object) {
    return 'Create $object';
  }

  @override
  String editPlaceholder(Object object) {
    return 'Edit $object';
  }

  @override
  String addPlaceholder(Object object) {
    return 'Add $object';
  }

  @override
  String savePlaceholder(Object object) {
    return 'Save $object';
  }

  @override
  String duplicatePlaceholder(Object object) {
    return 'Duplicate $object';
  }

  @override
  String get scheduleName => 'Schedule Name';

  @override
  String get date => 'Date';

  @override
  String get startTime => 'Start Time';

  @override
  String get location => 'Location';

  @override
  String get annotationsOptional => 'Annotations (Optional)';

  @override
  String get schedulePlaylist => 'Schedule Playlist';

  @override
  String get changePlaylist => 'Change Playlist';

  @override
  String get selectPlaylistForScheduleInstruction =>
      'Please create a schedule by selecting a playlist below.';

  @override
  String get scheduleDetails => 'Schedule Details';

  @override
  String get fillScheduleDetailsInstruction =>
      'Please fill in the schedule details.';

  @override
  String get createRolesAndAssignUsersInstruction =>
      'Please create roles and assign Members to the schedule.';

  @override
  String get pleaseEnterScheduleName => 'Please enter a schedule name.';

  @override
  String get pleaseEnterDate => 'Please enter a valid date (DD/MM/YYYY).';

  @override
  String get pleaseEnterStartTime => 'Please enter a valid start time (HH:MM).';

  @override
  String get pleaseEnterLocation => 'Please enter a location.';

  @override
  String get noRoles => 'No roles yet.';

  @override
  String get addRolesInstructions =>
      'Add your own roles and people, and assign them to this schedule.';

  @override
  String get roleNameHint => 'e.g., Worship Leader, Vocalist';

  @override
  String get member => 'Member';

  @override
  String assignMembersToRole(Object role) {
    return 'Assign Members to $role';
  }

  @override
  String get noMembers => 'No members yet.';

  @override
  String xMembers(Object count) {
    return '$count members';
  }

  @override
  String get nextUp => 'Next Up';

  @override
  String get nextSchedules => 'Next Schedules';

  @override
  String get searchSchedule => 'Search schedule...';

  @override
  String get assignSchedule => 'Assign Schedule';

  @override
  String get noPlaylistAssigned => 'No playlist assigned.';

  @override
  String get scheduleNotFound => 'Schedule Not Found';

  @override
  String get scheduleNotFoundMessage =>
      'The requested schedule could not be found.';

  @override
  String get create => 'Create';

  @override
  String get createManually => 'Create Manually';

  @override
  String get import => 'Import';

  @override
  String get importFromPDF => 'Import from PDF';

  @override
  String get selectPDFFile => 'Select PDF File';

  @override
  String get selectedFile => 'Selected File: ';

  @override
  String get processPDF => 'Process PDF';

  @override
  String get howToImport => 'How to Import';

  @override
  String get importInstructions =>
      '• Select a PDF with the song map\n• Separate verses with empty lines or Labels\n• Chords above the lyrics at the correct positions';

  @override
  String get importFromImage => 'Import from Image';

  @override
  String get importFromText => 'Import from Text';

  @override
  String get pasteTextPrompt => 'Paste the cipher text here...';

  @override
  String importedFrom(Object importType) {
    return 'Song imported from $importType';
  }

  @override
  String playlistVersionName(Object playlistName) {
    return '$playlistName\'s Version';
  }

  @override
  String get parsingStrategy => 'Parsing Strategy';

  @override
  String get doubleNewLine => 'Double New Line';

  @override
  String get sectionLabels => 'Section Labels';

  @override
  String get pdfFormatting => 'PDF Formatting';

  @override
  String get importVariation => 'Import Variation';

  @override
  String get pdfWithColumns => 'PDF with Columns';

  @override
  String get pdfNoColumns => 'PDF without Columns';

  @override
  String get textDirect => 'Direct Text';

  @override
  String get imageOcr => 'Image with OCR';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get selectAppLanguage => 'Select the application language:';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get english => 'English';

  @override
  String get load => 'Load';

  @override
  String get loading => 'Loading...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get keepGoing => 'Continue';

  @override
  String get quickAction => 'Quick Action';

  @override
  String get copySuffix => '(Copy)';

  @override
  String get assign => 'Assign';

  @override
  String get clear => 'Clear';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmationTitle => 'Confirm Deletion';

  @override
  String deleteConfirmationMessage(Object object) {
    return 'Are you sure you want to delete this $object?';
  }

  @override
  String get deleteWarningMessage => 'This action cannot be undone.';

  @override
  String welcome(Object userName) {
    return 'Hello $userName';
  }

  @override
  String get anonymousWelcome => 'Welcome';

  @override
  String get by => 'by';

  @override
  String titleWithPlaceholder(Object title) {
    return 'Title: $title';
  }

  @override
  String authorWithPlaceholder(Object author) {
    return 'Author: $author';
  }

  @override
  String bpmWithPlaceholder(Object bpm) {
    return 'BPM: $bpm';
  }

  @override
  String keyWithPlaceholder(Object key) {
    return 'Key: $key';
  }

  @override
  String nSections(Object count) {
    return '$count sections';
  }

  @override
  String get hintPrefixO => 'Enter your ';

  @override
  String get hintPrefixA => 'Enter your ';

  @override
  String get hintSuffix => ' here...';

  @override
  String stepXofY(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get error => 'Error';

  @override
  String errorMessage(Object job, Object errorDetails) {
    return 'Error during $job: $errorDetails';
  }

  @override
  String get invalidTimeFormat => 'Invalid time format. Please use MM:SS.';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String pluralPlaceholder(Object label) {
    return '${label}s';
  }
}

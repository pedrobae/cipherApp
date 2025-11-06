import 'package:cipher_app/helpers/chords/chord_song.dart';

class ParsingCipher {
  final String rawText;
  Map<String, dynamic> metadata;
  List<Map<String, dynamic>>
  sections; // {'suggestedTitle': String, 'content': String}
  List<Chord> chords;
  String chordProText;

  ParsingCipher({
    required this.rawText,
    this.metadata = const {},
    this.chords = const [],
    this.sections = const [],
    this.chordProText = '',
  });
}

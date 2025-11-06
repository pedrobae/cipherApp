import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/services/parsing/chord_line_parser.dart';
import 'package:cipher_app/services/parsing/metadata_parser.dart';
import 'package:cipher_app/services/parsing/section_parser.dart';

class ParsingServiceBase {
  final MetadataParser metadataParser = MetadataParser();
  final ChordLineParser chordLineParser = ChordLineParser();
  final SectionParser sectionParser = SectionParser();

  Future<void> parseMetadata(ParsingCipher cipher) async {
    await metadataParser.parseMetadata(cipher);
  }

  Future<void> parseSections(ParsingCipher cipher) async {
    await sectionParser.parseSections(cipher);
  }

  Future<void> parseChords(ParsingCipher cipher) async {
    await chordLineParser.parseChords(cipher);
  }
}

import 'package:cipher_app/services/parsing/chord_line_parser.dart';
import 'package:cipher_app/services/parsing/metadata_parser.dart';
import 'package:cipher_app/services/parsing/section_parser.dart';

class ParsingServiceBase {
  final MetadataParser metadataParser = MetadataParser();
  final ChordLineParser chordLineParser = ChordLineParser();
  final SectionParser sectionParser = SectionParser();

  // TODO implementation for parsing imported text into structured format
  // Receives raw text and metadata from import services
  // Utilizes MetadataParser, ChordLineParser, SectionParser to process the text
  // Outputs chordPro representation suitable for Cipher editing
}

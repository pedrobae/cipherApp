import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/providers/import_provider.dart';

/// Represents a single candidate produced by a parsing strategy.
/// This is the minimal payload the UI needs to render and choose.
class CipherParseCandidate {
  final ParsingStrategy strategy;
  final ImportVariant importVariant; // Key of the import variant used
  final Cipher cipher; // Fully built domain Cipher
  final int sectionCount; // For quick ranking/display

  const CipherParseCandidate({
    required this.strategy,
    required this.importVariant,
    required this.cipher,
    required this.sectionCount,
  });
}

/// Document flowing to the UI with the most relevant parsed results.
/// Keeps UI decoupled from import-variant x parsing-strategy matrix.
class ParsedCipherDoc {
  final ImportType importType;
  final List<CipherParseCandidate> candidates;

  /// Optionally, a recommended candidate for default selection.
  final CipherParseCandidate? recommended;

  const ParsedCipherDoc({
    required this.importType,
    required this.candidates,
    this.recommended,
  });

  bool get isEmpty => candidates.isEmpty;
}

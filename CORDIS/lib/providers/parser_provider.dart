import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/models/domain/parsed_doc.dart';
import 'package:cordis/models/domain/parsing_cipher.dart';
import 'package:cordis/providers/import_provider.dart';
import 'package:cordis/services/parsing/parsing_service_base.dart';
import 'package:flutter/material.dart';

class ParserProvider extends ChangeNotifier {
  final ParsingServiceBase _parsingService = ParsingServiceBase();

  ParsingCipher? _cipher;
  ParsingCipher? get cipher => _cipher;

  // Consolidated document for UI consumption
  ParsedCipherDoc? _doc;
  ParsedCipherDoc? get doc => _doc;

  // Chosen Cipher after parsing
  Cipher? parsedCipher;

  bool _isParsing = false;
  bool get isParsing => _isParsing;

  String _error = '';
  String get error => _error;

  Future<void> parseCipher(ParsingCipher importedCipher) async {
    if (_isParsing) return;

    _cipher = importedCipher;
    _isParsing = true;
    _error = '';
    notifyListeners();

    try {
      // ===== PRE-PROCESSING STEPS =====
      switch (importedCipher.importType) {
        case ImportType.text:
          for (var importVariant in _cipher!.importVariants.values) {
            // Separate lines for each import variant
            _parsingService.calculateLines(importVariant);
            _parsingService.debugPrintCalcs(importVariant);
          }
          break;
        case ImportType.pdf:
          for (var importVariant in _cipher!.importVariants.values) {
            // Average character spacing and font style analysis
            _parsingService.preProcessPdf(importVariant);
          }
          break;
        case ImportType.image:
          // Image specific parsing can be added here
          break;
      }

      /// ===== PARSING STEPS =====
      for (var importVariant in _cipher!.importVariants.values) {
        _parsingService.parse(importVariant);
      }

      _selectCandidates();

      _isParsing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error during parsing: $e';
      _isParsing = false;
      notifyListeners();
      return;
    }
  }

  void _selectCandidates() {
    List<CipherParseCandidate> candidates = [];

    _cipher!.importVariants.forEach((_, importVariant) {
      importVariant.parsingResults.forEach((strategy, result) {
        // Build domain Cipher from parsed sections
        Cipher cipher = _parsingService.buildCipherFromParsedImportVariant(
          result,
          importVariant,
        );

        // Create candidate
        CipherParseCandidate candidate = CipherParseCandidate(
          strategy: strategy,
          variation: importVariant.variation,
          cipher: cipher,
          sectionCount: result.parsedSections.length,
        );

        candidates.add(candidate);
      });
    });

    _doc = ParsedCipherDoc(
      importType: _cipher!.importType,
      candidates: candidates,
    );
    parsedCipher = candidates.isNotEmpty ? candidates[0].cipher : null;
  }
}

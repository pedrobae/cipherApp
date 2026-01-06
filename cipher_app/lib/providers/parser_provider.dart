import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/parsed_doc.dart';
import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:cipher_app/services/parsing/parsing_service_base.dart';
import 'package:flutter/material.dart';

class ParserProvider extends ChangeNotifier {
  final ParsingServiceBase _parsingService = ParsingServiceBase();

  ParsingCipher? _cipher;
  ParsingCipher? get cipher => _cipher;

  // Consolidated document for UI consumption
  ParsedCipherDoc? _doc;
  ParsedCipherDoc? get doc => _doc;

  // Chosen Cipher after parsing
  Cipher? _parsedCipher;
  Cipher? get parsedCipher => _parsedCipher;
  set parsedCipher(Cipher? cipher) {
    _parsedCipher = cipher;
  }

  bool _isParsing = false;
  bool get isParsing => _isParsing;

  String _parsingStatus = 'Not parsing';
  String get parsingStatus => _parsingStatus;

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
          break;
        case ImportType.pdf:
          for (var importVariant in _cipher!.allImportVariants.values) {
            // Separate lines for each import variant
            _parsingService.preProcessPdf(importVariant);
          }
          break;
        case ImportType.image:
          // Image specific parsing can be added here
          break;
      }

      for (var importVariant in _cipher!.allImportVariants.values) {
        // Separate lines for each import variant
        _parsingService.calculateLines(importVariant);
        _parsingService.debugPrintCalcs(importVariant);
      }

      /// ===== PARSING STEPS =====
      switch (importedCipher.importType) {
        case ImportType.text:
          for (var importVariant in _cipher!.allImportVariants.values) {
            // Parse sections for each import variant and strategy
            _parsingService.textParser(importVariant);
          }
          break;
        case ImportType.pdf:
          for (var importVariant in _cipher!.allImportVariants.values) {
            // Parse sections for each import variant and strategy
            _parsingService.pdfParser(importVariant);
          }
          break;
        case ImportType.image:
          // Image specific parsing can be added here
          break;
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

    _cipher!.allImportVariants.forEach((importKey, importVariant) {
      importVariant.parsingResults.forEach((strategy, result) {
        // Build domain Cipher from parsed sections
        Cipher cipher = _parsingService.buildCipherFromParsedImportVariant(
          importVariant,
          strategy,
        );

        // Create candidate
        CipherParseCandidate candidate = CipherParseCandidate(
          strategy: strategy,
          importVariant: importVariant,
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
  }
}

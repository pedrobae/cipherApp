import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:cipher_app/services/parsing/parsing_service_base.dart';
import 'package:flutter/material.dart';

class ParserProvider extends ChangeNotifier {
  final ParsingServiceBase _parsingService = ParsingServiceBase();

  ParsingCipher? _cipher;
  ParsingCipher? get cipher => _cipher;

  bool _isParsing = false;
  bool _isParsingMetadata = false;
  bool _isParsingSections = false;
  bool _isParsingChords = false;
  bool get isParsing => _isParsing;

  bool _hasParsedMetadata = false;
  bool _hasParsedSections = false;
  bool _hasParsedChords = false;
  bool get hasParsedMetadata => _hasParsedMetadata;
  bool get hasParsedSections => _hasParsedSections;
  bool get hasParsedChords => _hasParsedChords;

  String _error = '';
  String get error => _error;

  String getParsingStatus() {
    if (_isParsing) {
      if (_isParsingChords) {
        return 'Parsing chords';
      } else if (_isParsingSections) {
        return 'Parsing sections';
      } else if (_isParsingMetadata) {
        return 'Parsing metadata';
      } else {
        return 'Parsing in progress';
      }
    }
    return 'Not parsing';
  }

  Future<void> parseCipher(ParsingCipher cipher) async {
    if (_isParsing) return;

    _cipher = cipher;
    _isParsing = true;
    _hasParsedMetadata = false;
    _hasParsedSections = false;
    _hasParsedChords = false;
    _error = '';
    notifyListeners();

    try {
      if (_cipher!.importType == ImportType.text) {
        _parsingService.separateLines(_cipher!);
      }
      // Calculate lines
      _parsingService.calculateLines(_cipher!);
      _parsingService.debugPrintCalcs(_cipher!);

      // Parse sections
      await _parseSections();

      // Parse metadata
      await _parseMetadata();

      // Parse chords
      await _parseChords();

      _isParsing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error during parsing: $e';
      _isParsing = false;
      notifyListeners();
      return;
    }
  }

  Future<void> _parseMetadata() async {
    if (_isParsingMetadata || _hasParsedMetadata) return;

    _isParsingMetadata = true;
    notifyListeners();

    try {
      await _parsingService.parseMetadata(_cipher!);
      _hasParsedMetadata = true;
    } catch (e) {
      _error = 'Error during metadata parsing: $e';
    } finally {
      _isParsingMetadata = false;
      notifyListeners();
    }
  }

  Future<void> _parseSections() async {
    if (_isParsingSections || _hasParsedSections) return;

    _isParsingSections = true;
    notifyListeners();

    try {
      await _parsingService.parseSections(_cipher!);
      _hasParsedSections = true;
    } catch (e) {
      _error = 'Error during section parsing: $e';
    } finally {
      _isParsingSections = false;
      notifyListeners();
    }
  }

  Future<void> _parseChords() async {
    if (_isParsingChords || _hasParsedChords) return;

    _isParsingChords = true;
    notifyListeners();

    try {
      await _parsingService.parseChords(_cipher!);
      _hasParsedChords = true;
    } catch (e) {
      _error = 'Error during chord parsing: $e';
    } finally {
      _isParsingChords = false;
      notifyListeners();
    }
  }
}

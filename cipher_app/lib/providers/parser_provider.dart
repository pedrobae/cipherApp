import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:cipher_app/services/parsing/parsing_service_base.dart';
import 'package:flutter/material.dart';

class ParserProvider extends ChangeNotifier {
  final ParsingServiceBase _parsingService = ParsingServiceBase();

  ParsingCipher? _cipher;
  ParsingCipher? get cipher => _cipher;
  Cipher? _labelCipherObject;
  Cipher? get labelParsedCipher => _labelCipherObject;
  Cipher? _doubleNewLineCipherObject;
  Cipher? get doubleNewLineParsedCipher => _doubleNewLineCipherObject;

  bool _isParsing = false;
  bool get isParsing => _isParsing;

  String _parsingStatus = 'Not parsing';
  String get parsingStatus => _parsingStatus;

  String _error = '';
  String get error => _error;

  Future<void> parseCipher(ParsingCipher cipher) async {
    if (_isParsing) return;

    _cipher = cipher;
    _isParsing = true;
    _error = '';
    notifyListeners();

    try {
      switch (cipher.importType) {
        case ImportType.text:
          // Separate lines
          _parsingService.separateLines(_cipher!);
          break;
        case ImportType.pdf:
          await _parsePdfLines();

          break;
        case ImportType.image:
          // Image specific parsing can be added here
          break;
      }
      // Calculate lines
      _parsingService.calculateLines(_cipher!.lines);
      _parsingService.debugPrintCalcs(_cipher!);

      // Parse sections
      await _parseSections();

      // Parse metadata
      await _parseMetadata();

      // Parse chords
      await _parseChords();

      _labelCipherObject = _buildCipherObject(_cipher!, SeparationType.label);
      _doubleNewLineCipherObject = _buildCipherObject(
        _cipher!,
        SeparationType.doubleNewLine,
      );

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
    _parsingStatus = 'Parsing Metadata';
    notifyListeners();

    try {
      await _parsingService.parseMetadata(_cipher!);
    } catch (e) {
      _error = 'Error during metadata parsing: $e';
    } finally {
      _parsingStatus = 'Not parsing';
      notifyListeners();
    }
  }

  Future<void> _parseSections() async {
    _parsingStatus = 'Parsing Sections';
    notifyListeners();

    try {
      await _parsingService.parseSections(_cipher!);
    } catch (e) {
      _error = 'Error during section parsing: $e';
    } finally {
      _parsingStatus = 'Not parsing';
      notifyListeners();
    }
  }

  Future<void> _parseChords() async {
    _parsingStatus = 'Parsing Chords';
    notifyListeners();

    try {
      await _parsingService.parseChords(_cipher!);
    } catch (e) {
      _error = 'Error during chord parsing: $e';
    } finally {
      _parsingStatus = 'Not parsing';
      notifyListeners();
    }
  }

  Future<void> _parsePdfLines() async {
    _parsingStatus = 'Parsing PDF Lines';
    notifyListeners();

    try {
      await _parsingService.parsePdfLines(_cipher!);
    } catch (e) {
      _error = 'Error during PDF line parsing: $e';
    } finally {
      _parsingStatus = 'Not parsing';
      notifyListeners();
    }
  }

  Cipher _buildCipherObject(ParsingCipher cipher, SeparationType type) {
    return Cipher(
      id: -1, // Temporary ID, to be set when saving to DB
      title: cipher.metadata['title'] ?? 'Untitled',
      author: cipher.metadata['author'] ?? 'Unknown Artist',
      musicKey: cipher.metadata['key'] ?? '-',
      tempo: cipher.metadata['tempo'] ?? '-',
      language: cipher.metadata['language'] ?? 'Unknown',
      isLocal: false, // Will be set when saving to DB
      versions: _buildVersionObjects(cipher, type),
    );
  }

  List<Version> _buildVersionObjects(
    ParsingCipher cipher,
    SeparationType type,
  ) {
    if (type == SeparationType.doubleNewLine) {
      Version version = Version(
        transposedKey: cipher.metadata['key'],
        id: -1, // Temporary ID
        cipherId: -1, // Temporary cipher ID
        sections: cipher.parsedDoubleLineSeparatedSections,
        songStructure: cipher.doubleLineSeparatedSongStructure,
        versionName: 'imported',
      );

      return [version];
    }
    if (type == SeparationType.label) {
      Version version = Version(
        transposedKey: cipher.metadata['key'],
        id: -1, // Temporary ID
        cipherId: -1, // Temporary cipher ID
        sections: cipher.parsedLabelSeparatedSections,
        songStructure: cipher.labelSeparatedSongStructure,
        versionName: 'imported',
      );

      return [version];
    } else {
      return [];
    }
  }
}

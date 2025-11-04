import 'package:cipher_app/services/parsing/parsing_service_base.dart';
import 'package:flutter/material.dart';

class ParsingProvider extends ChangeNotifier {
  final ParsingServiceBase _parsingService = ParsingServiceBase();

  bool _parsingMetadata = false;
  bool _parsingSections = false;
  bool _parsingChords = false;
  bool _hasParsedMetadata = false;
  bool _hasParsedSections = false;
  bool _hasParsedChords = false;

  bool get hasParsedMetadata => _hasParsedMetadata;
  bool get hasParsedSections => _hasParsedSections;
  bool get hasParsedChords => _hasParsedChords;
}

import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/dtos/pdf_dto.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Import strategy variants - different ways to extract text from source
/// Used when the same import type has multiple extraction methods
enum ImportVariation {
  pdfWithColumns, // PDF with column detection applied
  pdfNoColumns, // PDF without column detection
  textDirect, // Plain text as-is
  imageOcr, // Image with OCR
}

/// Available parsing strategies for converting imported text to cipher sections
enum ParsingStrategy { doubleNewLine, sectionLabels, pdfFormatting }

/// Container for results from a single parsing strategy
class ParsingResult {
  final ParsingStrategy strategy;
  final List<Map<String, dynamic>> rawSections = [];
  final Map<String, Section> parsedSections = {};
  final List<String> songStructure = [];
  final Map<String, dynamic> strategyMetadata;
  List<PdfFontStyle>? dominantChordStyle;

  /// PDF-specific formatting analysis (only populated for PDF imports)
  final Map<List<PdfFontStyle>, int> fontStyleCount = {};
  final Map<List<PdfFontStyle>, Map<List<PdfFontStyle>, int>>
  followingStyleCounts = {};

  ParsingResult({required this.strategy, this.strategyMetadata = const {}});

  /// Check if this result has any parsed content
  bool get hasContent => parsedSections.isNotEmpty || rawSections.isNotEmpty;

  /// Get the number of sections found
  int get sectionCount => parsedSections.length;
}

/// Container for a single import variant with its line data and parsing results
class ImportVariant {
  final ImportVariation variation;
  final String rawText;
  final List<Map<String, dynamic>> lines;
  final Map<ParsingStrategy, ParsingResult> parsingResults = {};

  /// Metadata specific to this import variant
  Map<String, dynamic> metadata = {};

  ImportVariant({
    required this.variation,
    required this.rawText,
    required this.lines,
  });

  /// Get available parsing strategies for this variant
  List<ParsingStrategy> get availableParsingStrategies =>
      parsingResults.keys.toList();

  /// Factory constructor for PDF imports with formatted line data
  factory ImportVariant.fromPdfLines(
    List<LineData> textLines, {
    required ImportVariation strategy,
  }) {
    StringBuffer buffer = StringBuffer();
    List<Map<String, dynamic>> lines = [];

    for (var line in textLines) {
      buffer.writeln(line.text);
      lines.add({'textLine': line});
    }

    final variant = ImportVariant(
      variation: strategy,
      rawText: buffer.toString(),
      lines: lines,
    );

    return variant;
  }
}

/// Main cipher parsing container that holds imported text and all import variants
class ParsingCipher {
  final ImportType importType;

  /// Global metadata extracted from the entire document (title, author, etc)
  Map<String, dynamic> metadata = {};

  /// Storage for different import variants
  /// Key: ImportStrategy identifier (e.g., 'pdfWithColumns', 'pdfNoColumns')
  final Map<String, ImportVariant> _importVariants = {};

  ParsingCipher({required this.importType});

  // ============ Import Variants Management ============

  /// Add or update an import variant
  void addImportVariant(String key, ImportVariant variant) {
    _importVariants[key] = variant;
  }

  /// Get a specific import variant
  ImportVariant? getImportVariant(String key) => _importVariants[key];

  /// Get all import variants
  Map<String, ImportVariant> get allImportVariants => Map.from(_importVariants);

  /// Get list of available import variant keys
  List<String> get availableImportVariants => _importVariants.keys.toList();
}

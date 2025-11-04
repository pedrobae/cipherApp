import 'package:cipher_app/services/import/image_import_service.dart';
import 'package:cipher_app/services/import/pdf_import_service.dart';
import 'package:cipher_app/services/import/text_import_service.dart';

class ImportServiceBase {
  final TextImportService textImportService = TextImportService();
  final PDFImportService pdfImportService = PDFImportService();
  final ImageImportService imageImportService = ImageImportService();

  // TODO implementation for coordinating different import services

  Future<void> importCipherFromText(String text) async {
    await textImportService.importFromText(text);
  }
}

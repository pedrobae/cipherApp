import 'package:cipher_app/repositories/cipher_repository_cloud.dart';
import 'package:cipher_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Progress callback for bulk operations
typedef ProgressCallback = void Function(int current, int total, String status);

/// Service for admin-only bulk operations
/// Handles bulk import of ciphers to both SQLite and Firestore
class AdminBulkService {
  final CloudCipherRepository _cloudRepository = CloudCipherRepository();
  final AuthService _authService = AuthService();

  /// Import multiple ciphers from JSON format
  /// Supports both local-only and cloud upload
  Future<BulkImportResult> importCiphersFromJson({
    required Map<String, dynamic> jsonData,
    required bool uploadToCloud,
    ProgressCallback? onProgress,
  }) async {
    // Require admin access for bulk operations
    if (!(await _authService.isAdmin)) {
      throw Exception(
        'Acesso negado: operação requer privilégios de administrador',
      );
    }

    final List<dynamic> ciphersJson = jsonData['ciphers'] as List<dynamic>;
    final result = BulkImportResult();

    onProgress?.call(0, ciphersJson.length, 'Iniciando importação...');

    for (int i = 0; i < ciphersJson.length; i++) {
      try {
        final cipherData = ciphersJson[i] as Map<String, dynamic>;
        onProgress?.call(
          i + 1,
          ciphersJson.length,
          'Processando: ${cipherData['title']}',
        );

        // Upload to cloud if requested and admin authenticated
        if (uploadToCloud) {
          try {
            await _cloudRepository.createPublicCipherFromJson(cipherData);
            result.cloudSuccessCount++;
          } catch (e) {
            result.cloudFailures.add('${cipherData['title']}: $e');
            if (kDebugMode) {
              print('Failed to upload ${cipherData['title']} to cloud: $e');
            }
          }
        }
      } catch (e) {
        final title =
            (ciphersJson[i] as Map<String, dynamic>)['title'] ??
            'Cifra desconhecida';
        result.localFailures.add('$title: $e');
        if (kDebugMode) {
          print('Failed to import $title: $e');
        }
      }
    }

    onProgress?.call(
      ciphersJson.length,
      ciphersJson.length,
      'Importação concluída!',
    );
    return result;
  }

  /// Validate JSON structure before import
  Future<ValidationResult> validateImportJson(
    Map<String, dynamic> jsonData,
  ) async {
    final result = ValidationResult();

    try {
      // Check if ciphers array exists
      if (!jsonData.containsKey('ciphers')) {
        result.addError('JSON deve conter um array "ciphers"');
        return result;
      }

      final ciphersArray = jsonData['ciphers'];
      if (ciphersArray is! List) {
        result.addError('"ciphers" deve ser um array');
        return result;
      }

      if (ciphersArray.isEmpty) {
        result.addWarning('Array de cifras está vazio');
        return result;
      }

      // Validate each cipher
      for (int i = 0; i < ciphersArray.length; i++) {
        final cipher = ciphersArray[i];
        if (cipher is! Map<String, dynamic>) {
          result.addError('Cifra $i: deve ser um objeto JSON');
          continue;
        }

        _validateCipherStructure(cipher, i, result);
      }
    } catch (e) {
      result.addError('Erro ao validar JSON: $e');
    }

    return result;
  }

  void _validateCipherStructure(
    Map<String, dynamic> cipher,
    int index,
    ValidationResult result,
  ) {
    // Required fields
    final requiredFields = ['title', 'author'];
    for (final field in requiredFields) {
      if (!cipher.containsKey(field) ||
          cipher[field] == null ||
          cipher[field].toString().isEmpty) {
        result.addError('Cifra $index: campo "$field" é obrigatório');
      }
    }

    // Validate versions
    if (cipher.containsKey('versions')) {
      final versions = cipher['versions'];
      if (versions is List && versions.isNotEmpty) {
        for (int v = 0; v < versions.length; v++) {
          _validateVersionStructure(versions[v], index, v, result);
        }
      }
    } else {
      result.addWarning('Cifra $index: sem versões definidas');
    }
  }

  void _validateVersionStructure(
    dynamic version,
    int cipherIndex,
    int versionIndex,
    ValidationResult result,
  ) {
    if (version is! Map<String, dynamic>) {
      result.addError(
        'Cifra $cipherIndex, Versão $versionIndex: deve ser um objeto JSON',
      );
      return;
    }

    // Validate song structure
    if (version.containsKey('song_structure')) {
      final structure = version['song_structure'];
      if (structure is! String && structure is! List) {
        result.addError(
          'Cifra $cipherIndex, Versão $versionIndex: song_structure deve ser string ou array',
        );
      }
    }

    // Validate sections
    if (version.containsKey('sections')) {
      final sections = version['sections'];
      if (sections is! Map<String, dynamic>) {
        result.addError(
          'Cifra $cipherIndex, Versão $versionIndex: sections deve ser um objeto',
        );
      } else {
        for (final entry in sections.entries) {
          _validateSectionStructure(
            entry.value,
            cipherIndex,
            versionIndex,
            entry.key,
            result,
          );
        }
      }
    }
  }

  void _validateSectionStructure(
    dynamic section,
    int cipherIndex,
    int versionIndex,
    String sectionCode,
    ValidationResult result,
  ) {
    if (section is! Map<String, dynamic>) {
      result.addError(
        'Cifra $cipherIndex, Versão $versionIndex, Seção $sectionCode: deve ser um objeto JSON',
      );
      return;
    }

    final requiredSectionFields = [
      'content_type',
      'content_code',
      'content_text',
    ];
    for (final field in requiredSectionFields) {
      if (!section.containsKey(field)) {
        result.addError(
          'Cifra $cipherIndex, Versão $versionIndex, Seção $sectionCode: campo "$field" é obrigatório',
        );
      }
    }
  }

  /// Get sample JSON template for documentation
  static Map<String, dynamic> getSampleTemplate() {
    return {
      "ciphers": [
        {
          "title": "Nome da Cifra",
          "author": "Nome do Autor",
          "tempo": "Moderado",
          "music_key": "C",
          "language": "pt-BR",
          "tags": ["hino", "adoração"],
          "versions": [
            {
              "version_name": "Original",
              "transposed_key": "C",
              "song_structure": ["V1", "C", "V2", "C"],
              "sections": {
                "V1": {
                  "content_type": "verse",
                  "content_code": "V1",
                  "content_text": "[C]Primeira estrofe da cifra...",
                  "content_color": "#2196F3",
                },
                "C": {
                  "content_type": "chorus",
                  "content_code": "C",
                  "content_text": "[F]Refrão da cifra...",
                  "content_color": "#F44336",
                },
                "V2": {
                  "content_type": "verse",
                  "content_code": "V2",
                  "content_text": "[C]Segunda estrofe...",
                  "content_color": "#2196F3",
                },
              },
            },
          ],
        },
      ],
    };
  }
}

/// Result of bulk import operation
class BulkImportResult {
  int localSuccessCount = 0;
  int cloudSuccessCount = 0;
  List<String> localFailures = [];
  List<String> cloudFailures = [];

  bool get hasLocalFailures => localFailures.isNotEmpty;
  bool get hasCloudFailures => cloudFailures.isNotEmpty;
  bool get hasAnyFailures => hasLocalFailures || hasCloudFailures;

  int get totalAttempted => localSuccessCount + localFailures.length;

  String getSummary() {
    final lines = <String>[];
    lines.add('=== RESULTADO DA IMPORTAÇÃO ===');
    lines.add(
      'Local: $localSuccessCount sucessos, ${localFailures.length} falhas',
    );
    if (cloudSuccessCount > 0 || cloudFailures.isNotEmpty) {
      lines.add(
        'Nuvem: $cloudSuccessCount sucessos, ${cloudFailures.length} falhas',
      );
    }

    if (hasLocalFailures) {
      lines.add('\n--- FALHAS LOCAIS ---');
      lines.addAll(localFailures);
    }

    if (hasCloudFailures) {
      lines.add('\n--- FALHAS NA NUVEM ---');
      lines.addAll(cloudFailures);
    }

    return lines.join('\n');
  }
}

/// Result of JSON validation
class ValidationResult {
  List<String> errors = [];
  List<String> warnings = [];

  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  void addError(String error) => errors.add(error);
  void addWarning(String warning) => warnings.add(warning);

  String getSummary() {
    final lines = <String>[];

    if (errors.isNotEmpty) {
      lines.add('=== ERROS ===');
      lines.addAll(errors);
    }

    if (warnings.isNotEmpty) {
      lines.add('\n=== AVISOS ===');
      lines.addAll(warnings);
    }

    if (isValid && !hasWarnings) {
      lines.add('✅ JSON válido e pronto para importação!');
    }

    return lines.join('\n');
  }
}

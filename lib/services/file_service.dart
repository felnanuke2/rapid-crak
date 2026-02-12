import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../core/domain/entities/attack_entities.dart';

class FilePickResult {
  final LoadedFile file;
  final Uint8List bytes;

  FilePickResult(this.file, this.bytes);
}

/// Service for managing file operations.
class FileService {
  static const List<String> supportedExtensions = ['zip', 'pdf', 'rar', '7z'];

  /// Opens the file picker.
  /// Returns [FilePickResult] on success, null if canceled.
  static Future<FilePickResult?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User canceled.
      }

      final file = result.files.single;
      final bytes = file.bytes;
      
      if (bytes == null) {
        throw Exception('Não foi possível ler os bytes do arquivo');
      }

      final loadedFile = LoadedFile(
        path: file.path ?? '',
        name: file.name,
        sizeInBytes: file.size,
        loadedAt: DateTime.now(),
      );
      
      return FilePickResult(loadedFile, bytes);
    } catch (e) {
      throw Exception('Erro ao selecionar arquivo: $e');
    }
  }

  /// Validates whether the file exists and is supported.
  static bool isFileValid(LoadedFile file) {
    final extension = file.extension;
    return supportedExtensions.contains(extension);
  }

  /// Returns an error message if the file is invalid.
  static String? validateFile(LoadedFile file) {
    if (!isFileValid(file)) {
      return 'Tipo de arquivo não suportado. Use: ${supportedExtensions.join(', ')}';
    }
    if (file.sizeInBytes == 0) {
      return 'Arquivo vazio';
    }
    if (file.sizeInBytes > 5000000000) { // 5GB
      return 'Arquivo muito grande (máximo 5GB)';
    }
    return null;
  }

  /// Returns the supported extensions as a formatted string.
  static String get supportedFormats =>
      supportedExtensions.map((e) => '.$e').join(', ');
}

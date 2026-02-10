import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../core/domain/entities/attack_entities.dart';

class FilePickResult {
  final LoadedFile file;
  final Uint8List bytes;

  FilePickResult(this.file, this.bytes);
}

/// Serviço para gerenciar operações com arquivos
class FileService {
  static const List<String> supportedExtensions = ['zip', 'pdf', 'rar', '7z'];

  /// Abre o seletor de arquivo
  /// Retorna [FilePickResult] se bem-sucedido, null se cancelado
  static Future<FilePickResult?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null; // Usuário cancelou
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

  /// Valida se o arquivo existe e é suportado
  static bool isFileValid(LoadedFile file) {
    final extension = file.extension;
    return supportedExtensions.contains(extension);
  }

  /// Retorna mensagem de erro se o arquivo for inválido
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

  /// Retorna a lista de extensões suportadas como string formatado
  static String get supportedFormats =>
      supportedExtensions.map((e) => '.$e').join(', ');
}

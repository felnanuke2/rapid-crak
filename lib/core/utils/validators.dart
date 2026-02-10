/// Validadores para entrada de dados
class AppValidators {
  /// Valida se a extensão do arquivo é suportada
  static bool isFileSupported(String fileName) {
    final supportedExtensions = ['zip', 'pdf', 'rar', '7z'];
    final extension = fileName.split('.').last.toLowerCase();
    return supportedExtensions.contains(extension);
  }

  /// Retorna mensagem de erro para arquivo não suportado
  static String? validateFileExtension(String fileName) {
    if (!isFileSupported(fileName)) {
      return 'Arquivo não suportado. Use .zip, .pdf, .rar ou .7z';
    }
    return null;
  }

  /// Valida se o tamanho da senha é razoável
  static String? validatePasswordLength(int minLength, int maxLength) {
    if (minLength > maxLength) {
      return 'Comprimento mínimo não pode ser maior que o máximo';
    }
    if (maxLength > 16) {
      return 'Comprimento máximo recomendado é 16 (muito longo)';
    }
    return null;
  }

  /// Valida se foi selecionado pelo menos um tipo de caractere
  static bool hasAtLeastOneCharacterType({
    required bool numbers,
    required bool lowercase,
    required bool uppercase,
    required bool symbols,
  }) {
    return numbers || lowercase || uppercase || symbols;
  }

  /// Valida se o arquivo existe (básico)
  static bool isValidFilePath(String path) {
    return path.isNotEmpty && path.length > 3;
  }
}

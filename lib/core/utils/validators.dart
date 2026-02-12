/// Input validators.
class AppValidators {
  /// Validates if the file extension is supported.
  static bool isFileSupported(String fileName) {
    final supportedExtensions = ['zip', 'pdf', 'rar', '7z'];
    final extension = fileName.split('.').last.toLowerCase();
    return supportedExtensions.contains(extension);
  }

  /// Returns an error message for unsupported files.
  static String? validateFileExtension(String fileName) {
    if (!isFileSupported(fileName)) {
      return 'Arquivo não suportado. Use .zip, .pdf, .rar ou .7z';
    }
    return null;
  }

  /// Validates whether the password length is reasonable.
  static String? validatePasswordLength(int minLength, int maxLength) {
    if (minLength > maxLength) {
      return 'Comprimento mínimo não pode ser maior que o máximo';
    }
    if (maxLength > 16) {
      return 'Comprimento máximo recomendado é 16 (muito longo)';
    }
    return null;
  }

  /// Validates that at least one character type was selected.
  static bool hasAtLeastOneCharacterType({
    required bool numbers,
    required bool lowercase,
    required bool uppercase,
    required bool symbols,
  }) {
    return numbers || lowercase || uppercase || symbols;
  }

  /// Validates that the file path exists (basic).
  static bool isValidFilePath(String path) {
    return path.isNotEmpty && path.length > 3;
  }
}

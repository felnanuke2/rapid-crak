import 'dart:typed_data' as typed_data;

/// Estados possíveis do ataque de força bruta
enum AttackState {
  idle,       // Aguardando entrada
  configuring,  // Usuário configurando ataque
  running,    // Ataque em andamento
  paused,     // Ataque pausado
  completed,  // Ataque completado
  error,      // Erro durante ataque
}

/// Estratégia de força bruta (tipos de caracteres)
class CharacterStrategy {
  final bool numbers;        // 0-9
  final bool lowercase;      // a-z
  final bool uppercase;      // A-Z
  final bool symbols;        // !@#$%^&*()

  CharacterStrategy({
    required this.numbers,
    required this.lowercase,
    required this.uppercase,
    required this.symbols,
  });

  /// Retorna uma cópia com valores modificados
  CharacterStrategy copyWith({
    bool? numbers,
    bool? lowercase,
    bool? uppercase,
    bool? symbols,
  }) {
    return CharacterStrategy(
      numbers: numbers ?? this.numbers,
      lowercase: lowercase ?? this.lowercase,
      uppercase: uppercase ?? this.uppercase,
      symbols: symbols ?? this.symbols,
    );
  }

  /// Verifica se ao menos um tipo está selecionado
  bool get hasAtLeastOne =>
      numbers || lowercase || uppercase || symbols;

  /// Conta quantos tipos estão selecionados
  int get selectedCount =>
      (numbers ? 1 : 0) +
      (lowercase ? 1 : 0) +
      (uppercase ? 1 : 0) +
      (symbols ? 1 : 0);

  @override
  String toString() => 'CharacterStrategy(numbers: $numbers, lowercase: $lowercase, uppercase: $uppercase, symbols: $symbols)';
}

/// Configuração do ataque de força bruta
class AttackConfiguration {
  final int minLength;
  final int maxLength;
  final CharacterStrategy strategy;

  AttackConfiguration({
    required this.minLength,
    required this.maxLength,
    required this.strategy,
  });

  /// Retorna cópia com valores modificados
  AttackConfiguration copyWith({
    int? minLength,
    int? maxLength,
    CharacterStrategy? strategy,
  }) {
    return AttackConfiguration(
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      strategy: strategy ?? this.strategy,
    );
  }

  /// Valida se a configuração é válida
  bool get isValid =>
      minLength >= 1 &&
      maxLength <= 16 &&
      minLength <= maxLength &&
      strategy.hasAtLeastOne;

  /// Estima complexidade (muito básico)
  int get estimatedComplexity {
    int charCount = 0;
    if (strategy.numbers) charCount += 10;
    if (strategy.lowercase) charCount += 26;
    if (strategy.uppercase) charCount += 26;
    if (strategy.symbols) charCount += 32;
    return charCount;
  }

  @override
  String toString() =>
      'AttackConfiguration(minLength: $minLength, maxLength: $maxLength, strategy: $strategy)';
}

/// Metadados do arquivo carregado
class LoadedFile {
  final String path;
  final String name;
  final int sizeInBytes;
  final DateTime loadedAt;
  final typed_data.Uint8List bytes; // Bytes do arquivo para passar ao Rust

  LoadedFile({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.loadedAt,
    required this.bytes,
  });

  // Alias para compatibilidade
  int get sizeBytes => sizeInBytes;

  /// Retorna tamanho formatado (ex: "15.5 MB")
  String get formattedSize {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    if (sizeInBytes == 0) return '0 B';

    final index = (sizeInBytes.toString().length - 1) ~/ 3;
    final divisor = 1024 * (index > 0 ? 1 << (10 * index) : 1);
    final size = sizeInBytes / divisor;

    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }

  /// Extrai extensão do arquivo
  String get extension => name.split('.').last.toLowerCase();

  @override
  String toString() =>
      'LoadedFile(name: $name, size: $sizeInBytes, extension: $extension)';
}

/// Estatísticas de execução em tempo real
class AttackStats {
  final int attemptedCount;
  final double passwordsPerSecond; // Alterado de int para double
  final Duration elapsedTime;
  final String? lastTestedPassword;

  AttackStats({
    required this.attemptedCount,
    required this.passwordsPerSecond,
    required this.elapsedTime,
    this.lastTestedPassword,
  });

  // Alias para compatibilidade com o código Rust
  String? get currentPassword => lastTestedPassword;

  /// Retorna cópia com valores modificados
  AttackStats copyWith({
    int? attemptedCount,
    double? passwordsPerSecond,
    Duration? elapsedTime,
    String? lastTestedPassword,
  }) {
    return AttackStats(
      attemptedCount: attemptedCount ?? this.attemptedCount,
      passwordsPerSecond: passwordsPerSecond ?? this.passwordsPerSecond,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      lastTestedPassword: lastTestedPassword ?? this.lastTestedPassword,
    );
  }

  @override
  String toString() =>
      'AttackStats(attempts: $attemptedCount, speed: $passwordsPerSecond/s, elapsed: $elapsedTime)';
}

/// Resultado final do ataque
class AttackResult {
  final bool success;
  final String? password;
  final Duration totalTime;
  final int totalAttempts;
  final String? errorMessage;

  AttackResult({
    required this.success,
    this.password,
    required this.totalTime,
    required this.totalAttempts,
    this.errorMessage,
  });

  /// Verifica se é um erro
  bool get isError => !success && errorMessage != null;

  @override
  String toString() =>
      'AttackResult(success: $success, password: ${password ?? "N/A"}, attempts: $totalAttempts)';
}

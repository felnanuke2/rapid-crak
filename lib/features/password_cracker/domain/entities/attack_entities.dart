import 'dart:typed_data' as typed_data;

/// Possible states of the brute force attack.
enum AttackState {
  idle,       // Waiting for input.
  configuring,  // User configuring the attack.
  running,    // Attack running.
  paused,     // Attack paused.
  completed,  // Attack completed.
  error,      // Error during attack.
}

/// Brute force strategy (character types).
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

  /// Returns a copy with modified values.
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

  /// Checks whether at least one type is selected.
  bool get hasAtLeastOne =>
      numbers || lowercase || uppercase || symbols;

  /// Counts how many types are selected.
  int get selectedCount =>
      (numbers ? 1 : 0) +
      (lowercase ? 1 : 0) +
      (uppercase ? 1 : 0) +
      (symbols ? 1 : 0);

  @override
  String toString() => 'CharacterStrategy(numbers: $numbers, lowercase: $lowercase, uppercase: $uppercase, symbols: $symbols)';
}

/// Brute force attack configuration.
class AttackConfiguration {
  final int minLength;
  final int maxLength;
  final CharacterStrategy strategy;

  AttackConfiguration({
    required this.minLength,
    required this.maxLength,
    required this.strategy,
  });

  /// Returns a copy with modified values.
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

  /// Validates whether the configuration is valid.
  bool get isValid =>
      minLength >= 1 &&
      maxLength <= 16 &&
      minLength <= maxLength &&
      strategy.hasAtLeastOne;

  /// Estimates complexity (very basic).
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

/// Loaded file metadata.
class LoadedFile {
  final String path;
  final String name;
  final int sizeInBytes;
  final DateTime loadedAt;
  final typed_data.Uint8List bytes; // File bytes to pass to Rust.

  LoadedFile({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.loadedAt,
    required this.bytes,
  });

  // Alias for compatibility.
  int get sizeBytes => sizeInBytes;

  /// Returns formatted size (e.g. "15.5 MB").
  String get formattedSize {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    if (sizeInBytes == 0) return '0 B';

    final index = (sizeInBytes.toString().length - 1) ~/ 3;
    final divisor = 1024 * (index > 0 ? 1 << (10 * index) : 1);
    final size = sizeInBytes / divisor;

    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }

  /// Extracts the file extension.
  String get extension => name.split('.').last.toLowerCase();

  @override
  String toString() =>
      'LoadedFile(name: $name, size: $sizeInBytes, extension: $extension)';
}

/// Real-time execution stats.
class AttackStats {
  final int attemptedCount;
  final double passwordsPerSecond; // Changed from int to double.
  final Duration elapsedTime;
  final String? lastTestedPassword;

  AttackStats({
    required this.attemptedCount,
    required this.passwordsPerSecond,
    required this.elapsedTime,
    this.lastTestedPassword,
  });

  // Alias for compatibility with Rust code.
  String? get currentPassword => lastTestedPassword;

  /// Returns a copy with modified values.
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

/// Final attack result.
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

  /// Checks if this is an error.
  bool get isError => !success && errorMessage != null;

  @override
  String toString() =>
      'AttackResult(success: $success, password: ${password ?? "N/A"}, attempts: $totalAttempts)';
}

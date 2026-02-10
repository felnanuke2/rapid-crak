/// Represents the character strategy for password attack
class CharacterStrategy {
  final bool numbers;
  final bool lowercase;
  final bool uppercase;
  final bool symbols;

  CharacterStrategy({
    this.numbers = true,
    this.lowercase = true,
    this.uppercase = false,
    this.symbols = false,
  });

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

  int get characterSetSize {
    int size = 0;
    if (numbers) size += 10;
    if (lowercase) size += 26;
    if (uppercase) size += 26;
    if (symbols) size += 32; // Common symbols
    return size;
  }
}

/// Represents the configuration for an attack
class AttackConfiguration {
  final int minLength;
  final int maxLength;
  final CharacterStrategy strategy;

  AttackConfiguration({
    required this.minLength,
    required this.maxLength,
    required this.strategy,
  });

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

  bool get isValid => minLength > 0 && maxLength >= minLength;
}

/// Represents the current state of an attack
enum AttackState {
  idle,
  configuring,
  running,
  paused,
  completed,
  error,
}

/// Represents statistics during an attack
class AttackStats {
  final int attemptsMade;
  final int totalPossibilities;
  final double progressPercentage;
  final Duration elapsedTime;
  final String currentAttempt;

  AttackStats({
    required this.attemptsMade,
    required this.totalPossibilities,
    required this.progressPercentage,
    required this.elapsedTime,
    required this.currentAttempt,
  });

  double get estimatedTimeRemaining {
    if (attemptsMade == 0) return 0;
    final timePerAttempt = elapsedTime.inSeconds / attemptsMade;
    final remaining = totalPossibilities - attemptsMade;
    return remaining * timePerAttempt;
  }

  AttackStats copyWith({
    int? attemptsMade,
    int? totalPossibilities,
    double? progressPercentage,
    Duration? elapsedTime,
    String? currentAttempt,
  }) {
    return AttackStats(
      attemptsMade: attemptsMade ?? this.attemptsMade,
      totalPossibilities: totalPossibilities ?? this.totalPossibilities,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      currentAttempt: currentAttempt ?? this.currentAttempt,
    );
  }
}

/// Represents the result of an attack
class AttackResult {
  final bool success;
  final String? password;
  final String? hash;
  final Duration totalTime;
  final int totalAttempts;
  final bool isError;
  final String? errorMessage;

  AttackResult({
    required this.success,
    this.password,
    this.hash,
    required this.totalTime,
    required this.totalAttempts,
    this.isError = false,
    this.errorMessage,
  });

  AttackResult copyWith({
    bool? success,
    String? password,
    String? hash,
    Duration? totalTime,
    int? totalAttempts,
    bool? isError,
    String? errorMessage,
  }) {
    return AttackResult(
      success: success ?? this.success,
      password: password ?? this.password,
      hash: hash ?? this.hash,
      totalTime: totalTime ?? this.totalTime,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Represents a loaded file for password cracking
class LoadedFile {
  final String path;
  final String name;
  final int sizeInBytes;
  final DateTime loadedAt;

  LoadedFile({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.loadedAt,
  });

  String get sizeInMB => (sizeInBytes / (1024 * 1024)).toStringAsFixed(2);

  String get formattedSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String get extension {
    final lastDotIndex = name.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == name.length - 1) {
      return '';
    }
    return name.substring(lastDotIndex + 1).toLowerCase();
  }

  LoadedFile copyWith({
    String? path,
    String? name,
    int? sizeInBytes,
    DateTime? loadedAt,
  }) {
    return LoadedFile(
      path: path ?? this.path,
      name: name ?? this.name,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }
}

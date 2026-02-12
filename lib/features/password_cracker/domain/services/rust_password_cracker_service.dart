import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/attack_entities.dart';
import '../../presentation/state/password_cracker_provider.dart';
import '../../../../src/rust/api/password_cracker.dart' as rust;
import '../../../../src/rust/frb_generated.dart';
import '../../../../generated_l10n/app_localizations.dart';

/// Service that connects Rust to Flutter.
/// Manages communication between brute force logic (Rust) and the UI (Flutter).
class RustPasswordCrackerService {
  static bool _initialized = false;
  static StreamSubscription<rust.CrackProgress>? _activeAttackSubscription;

  /// Initializes Rust (should be called at app startup).
  /// Safe to call even if RustLib.init() was called in main().
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await RustLib.init();
    } catch (_) {
      // RustLib.init() already called in main(), ok.
    }
    _initialized = true;
  }

  /// Pauses attack execution.
  static Future<void> pauseAttack() async {
    try {
      await rust.setPause(paused: true);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao pausar ataque: $e');
      }
    }
  }

  /// Resumes attack execution.
  static Future<void> resumeAttack() async {
    try {
      await rust.setPause(paused: false);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao retomar ataque: $e');
      }
    }
  }

  /// Stops attack execution (cancels it completely).
  static Future<void> stopAttack() async {
    try {
      // Cancel the active subscription to stop the Rust execution
      await _activeAttackSubscription?.cancel();
      _activeAttackSubscription = null;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao parar ataque: $e');
      }
    }
  }

  /// Executes the brute force attack.
  /// Real-time progress stream.
  static Future<void> executeAttack({
    required Uint8List fileBytes,
    required AttackConfiguration config,
    required PasswordCrackerProvider provider,
    BuildContext? context,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Reset pause flag before starting
    rust.setPause(paused: false);

    // Converts Flutter config -> Rust.
    final rustConfig = rust.CrackConfig(
      minLength: BigInt.from(config.minLength),
      maxLength: BigInt.from(config.maxLength),
      useLowercase: config.strategy.lowercase,
      useUppercase: config.strategy.uppercase,
      useNumbers: config.strategy.numbers,
      useSymbols: config.strategy.symbols,
      useDictionary: true,
      customWords: [],
    );

    try {
      // Starts the attack.
      provider.startAttack();

      // Rust progress stream.
      final progressStream = rust.crackZipPassword(
        fileBytes: fileBytes,
        config: rustConfig,
      );

      rust.CrackProgress? lastProgress;
      
      // Listens to progress in real time and stores the subscription.
      _activeAttackSubscription = progressStream.listen(
        (progress) {
          lastProgress = progress;
          
          // Updates stats in the UI.
          provider.updateAttackStats(AttackStats(
            attemptedCount: progress.attempts.toInt(),
            passwordsPerSecond: progress.passwordsPerSecond,
            elapsedTime: Duration(seconds: progress.elapsedSeconds.toInt()),
            lastTestedPassword: progress.currentPassword ?? '',
          ));
        },
        onDone: () {
          _activeAttackSubscription = null;
          
          // Stream ended, but we need the Result<CrackResult> output.
          // Due to flutter_rust_bridge limitations, the Result is not in the stream.
          // If the stream ended, we assume the operation finished.
          // lastProgress carries the final information.
          
          if (lastProgress != null) {
            // If the last tested password was successful, it will be in currentPassword.
            final currentPassword = lastProgress!.currentPassword ?? '';
            final isSuccess = currentPassword.isNotEmpty && 
                              currentPassword != '...';
            
            provider.completeAttack(AttackResult(
              success: isSuccess,
              password: isSuccess ? currentPassword : null,
              totalAttempts: lastProgress!.attempts.toInt(),
              totalTime: Duration(seconds: lastProgress!.elapsedSeconds.toInt()),
            ));
          } else {
            final errorMessage = context != null
                ? AppLocalizations.of(context)!.noPasswordFound
                : 'Nenhuma senha encontrada';
            provider.setError(errorMessage);
          }
        },
        onError: (e) {
          _activeAttackSubscription = null;
          final errorMessage = context != null
              ? AppLocalizations.of(context)!.attackError(e.toString())
              : 'Erro no ataque: $e';
          provider.setError(errorMessage);
          if (kDebugMode) {
            print('Erro no ataque de força bruta: $e');
          }
        },
      );
    } catch (e) {
      _activeAttackSubscription = null;
      final errorMessage = context != null
          ? AppLocalizations.of(context)!.attackError(e.toString())
          : 'Erro no ataque: $e';
      provider.setError(errorMessage);
      if (kDebugMode) {
        print('Erro no ataque de força bruta: $e');
      }
    }
  }

  /// Tests a single password (debug/validation).
  static Future<bool> testPassword(
    Uint8List fileBytes,
    String password,
  ) async {
    if (!_initialized) {
      throw Exception('RustPasswordCrackerService não foi inicializado');
    }

    try {
      return rust.testZipPassword(
        fileBytes: fileBytes,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao testar senha: $e');
      }
      return false;
    }
  }

  /// Estimates how many combinations will be tested.
  static Future<BigInt> estimateCombinations(
    AttackConfiguration config,
  ) async {
    if (!_initialized) {
      throw Exception('RustPasswordCrackerService não foi inicializado');
    }

    final rustConfig = rust.CrackConfig(
      minLength: BigInt.from(config.minLength),
      maxLength: BigInt.from(config.maxLength),
      useLowercase: config.strategy.lowercase,
      useUppercase: config.strategy.uppercase,
      useNumbers: config.strategy.numbers,
      useSymbols: config.strategy.symbols,
      useDictionary: true,
      customWords: [],
    );

    try {
      final result = await rust.estimateCombinations(config: rustConfig);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao estimar combinações: $e');
      }
      return BigInt.zero;
    }
  }
}

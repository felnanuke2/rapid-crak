import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/attack_entities.dart';
import '../../presentation/state/password_cracker_provider.dart';
import '../../../../src/rust/api/password_cracker.dart' as rust;
import '../../../../src/rust/frb_generated.dart';
import '../../../../generated_l10n/app_localizations.dart';

/// Serviço que conecta o Rust ao Flutter
/// Gerencia a comunicação entre a lógica de força bruta (Rust) e a UI (Flutter)
class RustPasswordCrackerService {
  static bool _initialized = false;
  static StreamSubscription<rust.CrackProgress>? _activeAttackSubscription;

  /// Inicializa o Rust (deve ser chamado no início do app)
  /// Seguro para chamar mesmo se RustLib.init() já foi chamado em main()
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await RustLib.init();
    } catch (_) {
      // RustLib.init() já foi chamado em main(), ok
    }
    _initialized = true;
  }

  /// Pausa a execução do ataque
  static Future<void> pauseAttack() async {
    try {
      await rust.setPause(paused: true);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao pausar ataque: $e');
      }
    }
  }

  /// Retoma a execução do ataque
  static Future<void> resumeAttack() async {
    try {
      await rust.setPause(paused: false);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao retomar ataque: $e');
      }
    }
  }

  /// Para a execução do ataque (cancela a execução completamente)
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

  /// Executa o ataque de força bruta
  /// Stream de progresso em tempo real
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

    // Converte config Flutter -> Rust
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
      // Inicia o ataque
      provider.startAttack();

      // Stream de progresso do Rust
      final progressStream = rust.crackZipPassword(
        fileBytes: fileBytes,
        config: rustConfig,
      );

      rust.CrackProgress? lastProgress;
      
      // Escuta o progresso em tempo real e armazena a subscription
      _activeAttackSubscription = progressStream.listen(
        (progress) {
          lastProgress = progress;
          
          // Atualiza stats na UI
          provider.updateAttackStats(AttackStats(
            attemptedCount: progress.attempts.toInt(),
            passwordsPerSecond: progress.passwordsPerSecond,
            elapsedTime: Duration(seconds: progress.elapsedSeconds.toInt()),
            lastTestedPassword: progress.currentPassword ?? '',
          ));
        },
        onDone: () {
          _activeAttackSubscription = null;
          
          // Stream terminou - mas precisamos pegar o resultado do Result<CrackResult>
          // Por limitação do flutter_rust_bridge, o Result não vem no stream
          // Vamos considerar que se o stream terminou, é porque acabou
          // O lastProgress tem as informações finais
          
          if (lastProgress != null) {
            // Se a última senha testada foi bem-sucedida, ela estará em currentPassword
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

  /// Testa uma única senha (para debug/validação)
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

  /// Estima quantas combinações serão testadas
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

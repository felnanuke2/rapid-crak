import 'package:flutter/foundation.dart';
import '../../domain/entities/attack_entities.dart';
import '../../domain/services/rust_password_cracker_service.dart';

/// Gerencia todo o estado da aplicação
/// Usando ChangeNotifier para simplicidade (pode evoluir para Riverpod/Bloc depois)
class PasswordCrackerProvider extends ChangeNotifier {
  // Estado atual
  LoadedFile? _loadedFile;
  AttackConfiguration _configuration = AttackConfiguration(
    minLength: 1,
    maxLength: 8,
    strategy: CharacterStrategy(
      numbers: true,
      lowercase: true,
      uppercase: false,
      symbols: false,
    ),
  );
  AttackState _state = AttackState.idle;
  AttackStats? _currentStats;
  AttackResult? _lastResult;

  // Getters
  LoadedFile? get loadedFile => _loadedFile;
  AttackConfiguration get configuration => _configuration;
  AttackState get state => _state;
  AttackStats? get currentStats => _currentStats;
  AttackResult? get lastResult => _lastResult;

  // Propriedades derivadas
  bool get hasLoadedFile => _loadedFile != null;
  bool get isAttackRunning => _state == AttackState.running;
  bool get hasSuccessfulResult =>
      _lastResult != null && _lastResult!.success;
  bool get hasFailedResult =>
      _lastResult != null && !_lastResult!.success && _lastResult!.isError;

  // Métodos públicos
  void setLoadedFile(LoadedFile? file) {
    _loadedFile = file;
    _state = file != null ? AttackState.configuring : AttackState.idle;
    notifyListeners();
  }

  void updateConfiguration(AttackConfiguration newConfig) {
    _configuration = newConfig;
    notifyListeners();
  }

  void updateStrategy(CharacterStrategy strategy) {
    _configuration = _configuration.copyWith(strategy: strategy);
    notifyListeners();
  }

  void updatePasswordLength({int? minLength, int? maxLength}) {
    _configuration = _configuration.copyWith(
      minLength: minLength ?? _configuration.minLength,
      maxLength: maxLength ?? _configuration.maxLength,
    );
    notifyListeners();
  }

  void startAttack() {
    if (!_configuration.isValid) {
      throw Exception('Configuração inválida');
    }
    _state = AttackState.running;
    _currentStats = AttackStats(
      attemptedCount: 0,
      passwordsPerSecond: 0,
      elapsedTime: Duration.zero,
    );
    notifyListeners();
  }

  void updateAttackStats(AttackStats stats) {
    _currentStats = stats;
    notifyListeners();
  }

  void pauseAttack() {
    if (_state == AttackState.running) {
      _state = AttackState.paused;
      // Communicate pause to Rust (async operation, fire and forget)
      RustPasswordCrackerService.pauseAttack().catchError((e) {
        if (kDebugMode) {
          print('Error pausing attack: $e');
        }
      });
      notifyListeners();
    }
  }

  void resumeAttack() {
    if (_state == AttackState.paused) {
      _state = AttackState.running;
      // Communicate resume to Rust (async operation, fire and forget)
      RustPasswordCrackerService.resumeAttack().catchError((e) {
        if (kDebugMode) {
          print('Error resuming attack: $e');
        }
      });
      notifyListeners();
    }
  }

  void completeAttack(AttackResult result) {
    _lastResult = result;
    _state = AttackState.completed;
    notifyListeners();
  }

  void setError(String errorMessage) {
    _lastResult = AttackResult(
      success: false,
      totalTime: _currentStats?.elapsedTime ?? Duration.zero,
      totalAttempts: _currentStats?.attemptedCount ?? 0,
      errorMessage: errorMessage,
    );
    _state = AttackState.error;
    notifyListeners();
  }

  void resetAttack() {
    _currentStats = null;
    _lastResult = null;
    _state = hasLoadedFile ? AttackState.configuring : AttackState.idle;
    notifyListeners();
  }

  void reset() {
    _loadedFile = null;
    _configuration = AttackConfiguration(
      minLength: 1,
      maxLength: 8,
      strategy: CharacterStrategy(
        numbers: true,
        lowercase: true,
        uppercase: false,
        symbols: false,
      ),
    );
    _state = AttackState.idle;
    _currentStats = null;
    _lastResult = null;
    notifyListeners();
  }

  /// Debug: printa estado atual
  void debugPrintState() {
    if (kDebugMode) {
      print('=== PasswordCrackerProvider State ===');
      print('File: ${_loadedFile?.name ?? "N/A"}');
      print('State: $_state');
      print('Config: $_configuration');
      print('Stats: $_currentStats');
      print('Result: $_lastResult');
    }
  }
}

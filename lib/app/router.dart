import 'package:flutter/material.dart';
import '../features/password_cracker/domain/entities/attack_entities.dart';
import '../features/password_cracker/presentation/screens/import_file_screen.dart';
import '../features/password_cracker/presentation/screens/attack_config_screen.dart';
import '../features/password_cracker/presentation/screens/attack_execution_screen.dart';
import '../features/password_cracker/presentation/screens/attack_result_screen.dart';

/// Roteador da aplicação
/// Determina qual screen mostrar baseado no estado do provider
class AppRouter extends StatelessWidget {
  final AttackState currentState;
  final bool hasLoadedFile;
  final bool isAttackRunning;

  const AppRouter({
    Key? key,
    required this.currentState,
    required this.hasLoadedFile,
    required this.isAttackRunning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lógica de roteamento baseada em estado
    if (currentState == AttackState.idle || !hasLoadedFile) {
      return const ImportFileScreen();
    } else if (currentState == AttackState.configuring) {
      return const AttackConfigScreen();
    } else if (currentState == AttackState.running ||
        currentState == AttackState.paused) {
      return const AttackExecutionScreen();
    } else if (currentState == AttackState.completed ||
        currentState == AttackState.error) {
      return const AttackResultScreen();
    } else {
      return const ImportFileScreen();
    }
  }
}

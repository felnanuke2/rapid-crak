import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../state/password_cracker_provider.dart';
import '../widgets/tech_widgets.dart';

/// Tela 3: Execução do Ataque (Feedback em Tempo Real)
class AttackExecutionScreen extends StatefulWidget {
  const AttackExecutionScreen({Key? key}) : super(key: key);

  @override
  State<AttackExecutionScreen> createState() =>
      _AttackExecutionScreenState();
}

class _AttackExecutionScreenState
    extends State<AttackExecutionScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showConsoleLog = true;
  final List<String> _lastPasswords = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<PasswordCrackerProvider>().resetAttack();
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.attackInProgress,
          style: AppTextStyles.headlineMedium,
        ),
        actions: [
          Consumer<PasswordCrackerProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.isAttackRunning
                      ? Icons.pause_circle
                      : Icons.play_circle,
                ),
                onPressed: () {
                  if (provider.isAttackRunning) {
                    provider.pauseAttack();
                  } else {
                    provider.resumeAttack();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<PasswordCrackerProvider>(
        builder: (context, provider, _) {
          final stats = provider.currentStats;

          // Update password log with real data from Rust
          if (stats?.lastTestedPassword != null && 
              stats!.lastTestedPassword!.isNotEmpty &&
              (_lastPasswords.isEmpty || _lastPasswords.first != stats.lastTestedPassword)) {
            _lastPasswords.insert(0, stats.lastTestedPassword!);
            if (_lastPasswords.length > 5) {
              _lastPasswords.removeLast();
            }
          }

          if (stats == null) {
            return Center(
              child: TechProgressIndicator(
                label: AppLocalizations.of(context)!.starting,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard de Performance
                Text(
                  AppLocalizations.of(context)!.performance,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const Gap(12),

                // Grid de estatísticas
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      label: AppLocalizations.of(context)!.speed,
                      value: AppFormatters.formatSpeed(stats.passwordsPerSecond, context: context),
                      icon: Icons.speed,
                    ),
                    StatCard(
                      label: AppLocalizations.of(context)!.totalTime,
                      value: stats.elapsedTime.toFormattedString(),
                      icon: Icons.timer,
                      color: AppColors.accent,
                    ),
                    StatCard(
                      label: AppLocalizations.of(context)!.attempts,
                      value:
                          AppFormatters.formatLargeNumber(stats.attemptedCount),
                      icon: Icons.repeat,
                      color: AppColors.warning,
                    ),
                    StatCard(
                      label: AppLocalizations.of(context)!.state,
                      value: provider.isAttackRunning
                          ? AppLocalizations.of(context)!.running
                          : AppLocalizations.of(context)!.paused,
                      icon: Icons.info,
                      color: provider.isAttackRunning
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ],
                ),

                const Gap(28),

                // Indicador de progresso
                Center(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0)
                        .animate(_pulseController),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 3,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          Icon(
                            Icons.search,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Gap(28),

                // Console/Log (opcional mas estiloso)
                TechCard(
                  borderColor: AppColors.terminalGreen,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showConsoleLog = !_showConsoleLog;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.terminal,
                                    color: AppColors.terminalGreen,
                                    size: 18,
                                  ),
                                  const Gap(8),
                                  Text(
                                    AppLocalizations.of(context)!.console,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.terminalGreen,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                _showConsoleLog
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.terminalGreen,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showConsoleLog)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.codeBg,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.terminalGreen
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          height: 120,
                          child: _lastPasswords.isEmpty
                              ? Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.waitingAttempts,
                                    style:
                                        AppTextStyles.monoSmall.copyWith(
                                      color: AppColors.terminalGreen
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _lastPasswords.length,
                                  itemBuilder:
                                      (context, index) {
                                    return Text(
                                      '> ${_lastPasswords[index]}',
                                      style: AppTextStyles.monoSmall
                                          .copyWith(
                                        color: AppColors.terminalGreen,
                                        letterSpacing: 0.5,
                                      ),
                                    );
                                  },
                                ),
                        ),
                    ],
                  ),
                ),

                const Gap(20),
              ],
            ),
          );
        },
      ),
    );
  }
}

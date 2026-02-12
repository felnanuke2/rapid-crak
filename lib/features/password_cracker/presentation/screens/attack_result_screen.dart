import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../state/password_cracker_provider.dart';
import '../widgets/tech_widgets.dart';

/// Screen 4: Attack Result (Success or Failure).
class AttackResultScreen extends StatelessWidget {
  const AttackResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PasswordCrackerProvider>(
        builder: (context, provider, _) {
          final result = provider.lastResult;

          if (result == null) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noResult,
                style: AppTextStyles.headlineMedium,
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Result: Success or Failure.
                  if (result.success) ...[
                    // Success.
                    const Gap(40),
                    Center(
                      child: Icon(
                        Icons.lock_open,
                        size: 100,
                        color: AppColors.success,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      AppLocalizations.of(context)!.passwordFound,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.success,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(32),

                    // Password (Code Display).
                    CodeDisplay(
                      code: result.password ?? 'N/A',
                      onCopy: () {
                        Clipboard.setData(
                          ClipboardData(text: result.password ?? ''),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.passwordCopied),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const Gap(32),

                    // Statistics.
                    Text(
                      AppLocalizations.of(context)!.statistics,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Gap(12),

                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          label: AppLocalizations.of(context)!.totalTime,
                          value: AppFormatters.formatElapsedTime(
                            result.totalTime,
                          ),
                          icon: Icons.timer,
                        ),
                        StatCard(
                          label: AppLocalizations.of(context)!.attempts,
                          value: AppFormatters.formatLargeNumber(
                            result.totalAttempts,
                          ),
                          icon: Icons.repeat,
                          color: AppColors.success,
                        ),
                      ],
                    ),

                    const Gap(32),

                    // Buttons.
                    Column(
                      children: [
                        PrimaryActionButton(
                          label: AppLocalizations.of(context)!.copyPassword,
                          icon: Icons.content_copy,
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: result.password ?? ''),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.passwordCopied),
                              ),
                            );
                          },
                        ),
                        const Gap(12),
                        SecondaryButton(
                          label: AppLocalizations.of(context)!.newSearch,
                          icon: Icons.refresh,
                          onPressed: () {
                            context
                                .read<PasswordCrackerProvider>()
                                .reset();
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    // Failure.
                    const Gap(40),
                    Center(
                      child: Icon(
                        Icons.lock,
                        size: 100,
                        color: AppColors.error,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      AppLocalizations.of(context)!.passwordNotFound,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.error,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),

                    TechCard(
                      borderColor: AppColors.error,
                      child: Text(
                        result.errorMessage ??
                            AppLocalizations.of(context)!.passwordNotFoundMessage,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Gap(32),

                    // Statistics.
                    Text(
                      AppLocalizations.of(context)!.statistics,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Gap(12),

                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          label: AppLocalizations.of(context)!.totalTime,
                          value: AppFormatters.formatElapsedTime(
                            result.totalTime,
                          ),
                          icon: Icons.timer,
                        ),
                        StatCard(
                          label: AppLocalizations.of(context)!.attempts,
                          value: AppFormatters.formatLargeNumber(
                            result.totalAttempts,
                          ),
                          icon: Icons.repeat,
                          color: AppColors.error,
                        ),
                      ],
                    ),

                    const Gap(32),

                    // Buttons.
                    Column(
                      children: [
                        PrimaryActionButton(
                          label: AppLocalizations.of(context)!.tryAgain,
                          icon: Icons.refresh,
                          onPressed: () {
                            context
                                .read<PasswordCrackerProvider>()
                                .resetAttack();
                          },
                        ),
                        const Gap(12),
                        SecondaryButton(
                          label: AppLocalizations.of(context)!.newFile,
                          icon: Icons.folder_open,
                          onPressed: () {
                            context
                                .read<PasswordCrackerProvider>()
                                .reset();
                          },
                        ),
                      ],
                    ),
                  ],

                  const Gap(40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/loaded_file_extension.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../services/file_service.dart';
import '../../domain/entities/attack_entities.dart';
import '../state/password_cracker_provider.dart';
import '../widgets/tech_widgets.dart';

/// Screen 1: File Import (Clean State).
class ImportFileScreen extends StatelessWidget {
  const ImportFileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.passwordCrackerTitle,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    AppLocalizations.of(context)!.bruteForceRealTime,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Center: Icon + Text.
              Column(
                children: [
                  // Animated icon (pulsing).
                  TechCard(
                    borderColor: AppColors.primary,
                    padding: const EdgeInsets.all(32),
                    child: Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gap(32),
                  Text(
                    AppLocalizations.of(context)!.selectProtectedFile,
                    style: AppTextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.supportedFormats(FileService.supportedFormats),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Button.
              Consumer<PasswordCrackerProvider>(
                builder: (context, provider, _) {
                  return PrimaryActionButton(
                    label: AppLocalizations.of(context)!.importFile,
                    icon: Icons.folder_open,
                    onPressed: () => _handleFileSelection(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFileSelection(BuildContext context) async {
    try {
      final result = await FileService.pickFile();

      if (result == null) return; // Canceled.

      final error = FileService.validateFile(result.file);
      if (error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
        return;
      }

      if (context.mounted) {
        context.read<PasswordCrackerProvider>().setLoadedFile(result.file.toFeatureLoadedFile(result.bytes));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error(e.toString())),
          ),
        );
      }
    }
  }
}

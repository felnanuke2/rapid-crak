import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../domain/services/rust_password_cracker_service.dart';
import '../state/password_cracker_provider.dart';
import '../widgets/tech_widgets.dart';
import '../../domain/entities/attack_entities.dart';

/// Tela 2: Configuração do Ataque (War Room)
class AttackConfigScreen extends StatefulWidget {
  const AttackConfigScreen({Key? key}) : super(key: key);

  @override
  State<AttackConfigScreen> createState() => _AttackConfigScreenState();
}

class _AttackConfigScreenState extends State<AttackConfigScreen> {
  late bool _numbers;
  late bool _lowercase;
  late bool _uppercase;
  late bool _symbols;
  late int _minLength;
  late int _maxLength;

  @override
  void initState() {
    super.initState();
    final config =
        context.read<PasswordCrackerProvider>().configuration;
    _numbers = config.strategy.numbers;
    _lowercase = config.strategy.lowercase;
    _uppercase = config.strategy.uppercase;
    _symbols = config.strategy.symbols;
    _minLength = config.minLength;
    _maxLength = config.maxLength;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordCrackerProvider>(
      builder: (context, provider, _) {
        final file = provider.loadedFile!;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                provider.reset();
              },
            ),
            title: Text(
              AppLocalizations.of(context)!.configureAttack,
              style: AppTextStyles.headlineMedium,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: File Info
                TechCard(
                  borderColor: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.name,
                                  style:
                                      AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  file.formattedSize,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Gap(32),

                // Estratégia
                StrategySelector(
                  numbers: _numbers,
                  lowercase: _lowercase,
                  uppercase: _uppercase,
                  symbols: _symbols,
                  onChanged: (n, l, u, s) {
                    setState(() {
                      _numbers = n;
                      _lowercase = l;
                      _uppercase = u;
                      _symbols = s;
                    });
                  },
                ),

                const Gap(32),

                // Range Slider
                PasswordLengthSlider(
                  minLength: 1,
                  maxLength: 16,
                  currentMin: _minLength,
                  currentMax: _maxLength,
                  onChanged: (min, max) {
                    setState(() {
                      _minLength = min;
                      _maxLength = max;
                    });
                  },
                ),

                const Gap(32),

                // Info Box
                TechCard(
                  borderColor: AppColors.warning,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.optimizationTip,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              AppLocalizations.of(context)!.optimizationMessage,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(32),

                // Botões
                Column(
                  children: [
                    PrimaryActionButton(
                      label: AppLocalizations.of(context)!.startAttack,
                      icon: Icons.play_arrow,
                      onPressed:
                          _buildConfiguration() != null &&
                          AppValidators.hasAtLeastOneCharacterType(
                            numbers: _numbers,
                            lowercase: _lowercase,
                            uppercase: _uppercase,
                            symbols: _symbols,
                          )
                              ? () => _startAttack(context)
                              : null,
                      isEnabled:
                          _buildConfiguration() != null &&
                          AppValidators.hasAtLeastOneCharacterType(
                            numbers: _numbers,
                            lowercase: _lowercase,
                            uppercase: _uppercase,
                            symbols: _symbols,
                          ),
                    ),
                    const Gap(12),
                    SecondaryButton(
                      label: AppLocalizations.of(context)!.back,
                      onPressed: () {
                        context
                            .read<PasswordCrackerProvider>()
                            .reset();
                      },
                    ),
                  ],
                ),

                const Gap(32),
              ],
            ),
          ),
        );
      },
    );
  }

  AttackConfiguration? _buildConfiguration() {
    try {
      final strategy = CharacterStrategy(
        numbers: _numbers,
        lowercase: _lowercase,
        uppercase: _uppercase,
        symbols: _symbols,
      );

      final config = AttackConfiguration(
        minLength: _minLength,
        maxLength: _maxLength,
        strategy: strategy,
      );

      if (!config.isValid) return null;
      return config;
    } catch (e) {
      return null;
    }
  }

  void _startAttack(BuildContext context) {
    final config = _buildConfiguration();
    if (config == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidConfiguration)),
      );
      return;
    }

    final provider = context.read<PasswordCrackerProvider>();
    provider.updateConfiguration(config);

    // Inicia o ataque real via Rust (fire-and-forget)
    // executeAttack chama provider.startAttack() internamente,
    // que muda o estado para running e o router mostra a tela de execução
    RustPasswordCrackerService.executeAttack(
      fileBytes: provider.loadedFile!.bytes,
      config: config,
      provider: provider,
    );
  }
}

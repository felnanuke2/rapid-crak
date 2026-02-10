import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../generated_l10n/app_localizations.dart';

/// Botão primário grande (CTA - Call To Action)
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  const PrimaryActionButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: isEnabled ? 4 : 0,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.background,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Text(AppLocalizations.of(context)!.loading),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 22), const Gap(12)],
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botão secundário/outline
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const Gap(8)],
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão com borda Rust
class TechCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const TechCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor = AppColors.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Card para exibir número grande (estatísticas)
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.color = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TechCard(
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 20),
                const Gap(8),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            value,
            style: AppTextStyles.monoDisplayMedium.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Exibidor de código/senha com fonte mono
class CodeDisplay extends StatelessWidget {
  final String code;
  final bool selectable;
  final VoidCallback? onCopy;

  const CodeDisplay({
    Key? key,
    required this.code,
    this.selectable = true,
    this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onCopy,
      child: TechCard(
        borderColor: AppColors.terminalGreen,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SENHA ENCONTRADA',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.terminalGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                if (onCopy != null)
                  GestureDetector(
                    onTap: onCopy,
                    child: Icon(
                      Icons.copy,
                      color: AppColors.terminalGreen,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const Gap(12),
            SelectableText(
              code,
              style: AppTextStyles.monoDisplayLarge.copyWith(
                color: AppColors.terminalGreen,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seletor de estratégia com chips
class StrategySelector extends StatelessWidget {
  final bool numbers;
  final bool lowercase;
  final bool uppercase;
  final bool symbols;
  final Function(bool, bool, bool, bool) onChanged;

  const StrategySelector({
    Key? key,
    required this.numbers,
    required this.lowercase,
    required this.uppercase,
    required this.symbols,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.bruteForcingStrategy,
          style: AppTextStyles.headlineSmall,
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              label: AppLocalizations.of(context)!.numbers,
              selected: numbers,
              onChanged: (v) => onChanged(v, lowercase, uppercase, symbols),
            ),
            _buildChip(
              label: AppLocalizations.of(context)!.lowercase,
              selected: lowercase,
              onChanged: (v) => onChanged(numbers, v, uppercase, symbols),
            ),
            _buildChip(
              label: AppLocalizations.of(context)!.uppercase,
              selected: uppercase,
              onChanged: (v) => onChanged(numbers, lowercase, v, symbols),
            ),
            _buildChip(
              label: AppLocalizations.of(context)!.symbols,
              selected: symbols,
              onChanged: (v) => onChanged(numbers, lowercase, uppercase, v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required Function(bool) onChanged,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withOpacity(0.3),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
        width: selected ? 2 : 1,
      ),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

/// Slider para comprimento de senha
class PasswordLengthSlider extends StatelessWidget {
  final int minLength;
  final int maxLength;
  final int currentMin;
  final int currentMax;
  final Function(int, int) onChanged;

  const PasswordLengthSlider({
    Key? key,
    required this.minLength,
    required this.maxLength,
    required this.currentMin,
    required this.currentMax,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.passwordLength,
              style: AppTextStyles.headlineSmall,
            ),
            Text(
              AppLocalizations.of(
                context,
              )!.minMaxCharacters(currentMin, currentMax),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const Gap(12),
        RangeSlider(
          values: RangeValues(currentMin.toDouble(), currentMax.toDouble()),
          min: minLength.toDouble(),
          max: maxLength.toDouble(),
          divisions: maxLength - minLength,
          labels: RangeLabels(currentMin.toString(), currentMax.toString()),
          onChanged: (RangeValues values) {
            onChanged(values.start.toInt(), values.end.toInt());
          },
        ),
        if (currentMax > 8)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: AppColors.warning, size: 18),
                const Gap(8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.warningLongPasswords,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Indicador de progresso indeterminado (estilo hacker)
class TechProgressIndicator extends StatelessWidget {
  final String label;
  final double size;

  const TechProgressIndicator({
    Key? key,
    this.label = 'Processando...',
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Círculo externo (estático)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              // Círculo girando
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        Text(
          label,
          style: AppTextStyles.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../generated_l10n/app_localizations.dart';

/// Extensões úteis para Duration
extension DurationExtensions on Duration {
  /// Retorna um bool se a duração é maior que um valor específico
  bool isLongerThan(Duration other) => compareTo(other) > 0;

  /// Retorna um bool se a duração é menor que um valor específico
  bool isShorterThan(Duration other) => compareTo(other) < 0;

  /// Retorna a duração em minutos com decimais
  double get inMinutesWithDecimals => inMilliseconds / (1000 * 60);

  /// Formata a duração como "00:04:12" (HH:MM:SS)
  String toFormattedString() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Retorna descrição legível: "2h 30m 45s"
  String toReadableString() {
    final h = inHours;
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);

    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (s > 0) parts.add('${s}s');

    return parts.isEmpty ? '0s' : parts.join(' ');
  }
}

/// Extensões úteis para BuildContext
extension ContextExtensions on BuildContext {
  /// Atalho para theme
  ThemeData get theme => Theme.of(this);

  /// Atalho para media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Atalho para tamanho da tela
  Size get screenSize => mediaQuery.size;

  /// Atalho para width da tela
  double get screenWidth => screenSize.width;

  /// Atalho para height da tela
  double get screenHeight => screenSize.height;

  /// Verifica se é landscape
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Verifica se é portrait
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Verifica se o dispositivo é pequeno (< 600dp)
  bool get isSmallDevice => screenWidth < 600;

  /// Obtém padding do sistema (notches, etc)
  EdgeInsets get systemPadding => mediaQuery.padding;

  /// Obtém viewinsets (teclado)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Fecha o teclado
  void closeKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Atalho para localizações do app
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Atalho alternativo para localizações
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

/// Extensões úteis para String
extension StringExtensions on String {
  /// Verifica se a string é email válido (básico)
  bool get isValidEmail {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(this);
  }

  /// Capitaliza primeira letra
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Remove espaços em branco
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Verifica se contém apenas números
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Verifica se contém apenas letras
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Trunca com reticências
  String truncate(int length) {
    if (this.length <= length) return this;
    return '${substring(0, length)}...';
  }

  /// Inverte a string
  String get reversed => split('').reversed.join('');
}

/// Extensões úteis para List
extension ListExtensions<T> on List<T> {
  /// Retorna um item aleatório
  T? get random => isEmpty ? null : this[(DateTime.now().millisecond % length)];

  /// Divide lista em chunks
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }

  /// Retorna lista sem duplicatas
  List<T> get unique => toSet().toList();
}

/// Extensões úteis para int
extension IntExtensions on int {
  /// Verifica se é par
  bool get isEven => this % 2 == 0;

  /// Verifica se é ímpar
  bool get isOdd => this % 2 != 0;

  /// Converte para Duration em segundos
  Duration get seconds => Duration(seconds: this);

  /// Converte para Duration em minutos
  Duration get minutes => Duration(minutes: this);

  /// Converte para Duration em horas
  Duration get hours => Duration(hours: this);

  /// Formata como número grande: 1000000 -> 1.000.000
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match m) => '.',
    );
  }
}

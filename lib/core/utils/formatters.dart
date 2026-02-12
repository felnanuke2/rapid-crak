import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../generated_l10n/app_localizations.dart';

/// Utilities for formatting numbers, durations, and text.
class AppFormatters {
  /// Formats large numbers with thousands separators.
  /// Example: 1000000 -> 1.000.000
  static String formatLargeNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// Formats speed (passwords per second).
  /// Example: 1500000 -> "1.500.000 senhas/seg"
  /// For localization, provide a [BuildContext].
  static String formatSpeed(double passwordsPerSecond, {BuildContext? context}) {
    final formatted = formatLargeNumber(passwordsPerSecond.round());
    if (context == null) {
      // Fallback to default Portuguese.
      return '$formatted senhas/seg';
    }
    return AppLocalizations.of(context)!.passwordsPerSecond(formatted);
  }

  /// Formats duration as HH:MM:SS.
  /// Example: Duration(seconds: 252) -> "00:04:12"
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// Formats file size in bytes/KB/MB/GB.
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    if (bytes == 0) return '0 B';
    
    final index = (bytes.abs().toStringAsFixed(0).length - 1) ~/ 3;
    final divisor = 1024 * (index > 0 ? 1 << (10 * index) : 1);
    final size = bytes / divisor;
    
    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }

  /// Formats a file name, optionally removing the extension.
  static String formatFileName(String filePath, {bool removeExtension = false}) {
    final fileName = filePath.split('/').last;
    if (!removeExtension) return fileName;
    return fileName.split('.').first;
  }

  /// Formats attempts with large-number formatting.
  /// Example: 45201000 -> "45.201.000 testadas"
  /// For localization, provide a [BuildContext].
  static String formatAttempts(int attempts, {BuildContext? context}) {
    final formatted = formatLargeNumber(attempts);
    if (context == null) {
      // Fallback to default Portuguese.
      return '$formatted testadas';
    }
    return '${AppLocalizations.of(context)!.attemptedLabel} $formatted';
  }

  /// Truncates text to a maximum length with ellipsis.
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Formats elapsed time in a readable format.
  static String formatElapsedTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Formats a percentage with decimal places.
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }
}

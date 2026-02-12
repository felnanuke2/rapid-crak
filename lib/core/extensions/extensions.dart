import 'package:flutter/material.dart';
import '../../generated_l10n/app_localizations.dart';

/// Useful extensions for Duration.
extension DurationExtensions on Duration {
  /// Returns true if the duration is greater than a specific value.
  bool isLongerThan(Duration other) => compareTo(other) > 0;

  /// Returns true if the duration is less than a specific value.
  bool isShorterThan(Duration other) => compareTo(other) < 0;

  /// Returns the duration in minutes with decimals.
  double get inMinutesWithDecimals => inMilliseconds / (1000 * 60);

  /// Formats the duration as "00:04:12" (HH:MM:SS).
  String toFormattedString() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Returns a readable description: "2h 30m 45s".
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

/// Useful extensions for BuildContext.
extension ContextExtensions on BuildContext {
  /// Shortcut to theme.
  ThemeData get theme => Theme.of(this);

  /// Shortcut to media query.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Shortcut to screen size.
  Size get screenSize => mediaQuery.size;

  /// Shortcut to screen width.
  double get screenWidth => screenSize.width;

  /// Shortcut to screen height.
  double get screenHeight => screenSize.height;

  /// Checks if landscape.
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Checks if portrait.
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Checks if the device is small (< 600dp).
  bool get isSmallDevice => screenWidth < 600;

  /// Gets system padding (notches, etc).
  EdgeInsets get systemPadding => mediaQuery.padding;

  /// Gets view insets (keyboard).
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Closes the keyboard.
  void closeKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Shortcut to app localizations.
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Alternate shortcut to localizations.
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

/// Useful extensions for String.
extension StringExtensions on String {
  /// Checks if the string is a valid email (basic).
  bool get isValidEmail {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(this);
  }

  /// Capitalizes the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Removes whitespace.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Checks if it contains only numbers.
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Checks if it contains only letters.
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Truncates with ellipsis.
  String truncate(int length) {
    if (this.length <= length) return this;
    return '${substring(0, length)}...';
  }

  /// Reverses the string.
  String get reversed => split('').reversed.join('');
}

/// Useful extensions for List.
extension ListExtensions<T> on List<T> {
  /// Returns a random item.
  T? get random => isEmpty ? null : this[(DateTime.now().millisecond % length)];

  /// Splits the list into chunks.
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }

  /// Returns a list without duplicates.
  List<T> get unique => toSet().toList();
}

/// Useful extensions for int.
extension IntExtensions on int {
  /// Checks if even.
  bool get isEven => this % 2 == 0;

  /// Checks if odd.
  bool get isOdd => this % 2 != 0;

  /// Converts to Duration in seconds.
  Duration get seconds => Duration(seconds: this);

  /// Converts to Duration in minutes.
  Duration get minutes => Duration(minutes: this);

  /// Converts to Duration in hours.
  Duration get hours => Duration(hours: this);

  /// Formats as a large number: 1000000 -> 1.000.000.
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match m) => '.',
    );
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Password Cracker - Brute Force';

  @override
  String get noResult => 'No result';

  @override
  String get passwordFound => '✓ PASSWORD FOUND';

  @override
  String get passwordNotFound => '✗ PASSWORD NOT FOUND';

  @override
  String get statistics => 'STATISTICS';

  @override
  String get totalTime => 'Total Time';

  @override
  String get attempts => 'Attempts';

  @override
  String get speed => 'Speed';

  @override
  String get state => 'State';

  @override
  String get console => 'CONSOLE';

  @override
  String get passwordCopied => 'Password copied!';

  @override
  String get copyPassword => 'Copy Password';

  @override
  String get newSearch => 'New Search';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get newFile => 'New File';

  @override
  String get loading => 'Loading...';

  @override
  String get processingPassword => 'Processing...';

  @override
  String get passwordNotFoundMessage =>
      'Password not found with current settings.';

  @override
  String get bruteForcingStrategy => 'Brute Force Strategy';

  @override
  String get numbers => 'Numbers (0-9)';

  @override
  String get lowercase => 'Lowercase (a-z)';

  @override
  String get uppercase => 'Uppercase (A-Z)';

  @override
  String get symbols => 'Symbols (!@#...)';

  @override
  String get passwordLength => 'Password Length';

  @override
  String minMaxCharacters(int min, int max) {
    return '$min - $max characters';
  }

  @override
  String get warningLongPasswords =>
      'Warning: Long passwords may take hours/days on mobile.';

  @override
  String get attackInProgress => 'Attack in Progress';

  @override
  String get starting => 'Starting...';

  @override
  String get performance => 'PERFORMANCE';

  @override
  String get running => 'RUNNING';

  @override
  String get paused => 'PAUSED';

  @override
  String get waitingAttempts => 'Waiting for attempts...';

  @override
  String get configureAttack => 'Attack Configuration';

  @override
  String get optimizationTip => 'Optimization Tip';

  @override
  String get optimizationMessage =>
      'The fewer character options and shorter the length, the faster the attack.';

  @override
  String get startAttack => 'START PASSWORD CRACKING';

  @override
  String get back => 'Back';

  @override
  String get selectProtectedFile => 'Select a protected file';

  @override
  String supportedFormats(String formats) {
    return 'Supported formats: $formats';
  }

  @override
  String get importFile => 'Import File';

  @override
  String get passwordCrackerTitle => '🔐 PASSWORD CRACKER';

  @override
  String get bruteForceRealTime => 'Brute Force in Real Time';

  @override
  String get invalidConfiguration => 'Invalid configuration';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get passwordStrength => 'Password Strength Analysis';

  @override
  String get weakPassword => 'WEAK PASSWORD';

  @override
  String get moderatePassword => 'MODERATE PASSWORD';

  @override
  String get strongPassword => 'STRONG PASSWORD';

  @override
  String get veryStrongPassword => 'VERY STRONG PASSWORD';

  @override
  String get weakPasswordMessage =>
      'This configuration indicates a weak password. The attack should succeed quickly (under 1 minute).';

  @override
  String moderatePasswordMessage(String minutes) {
    return 'This configuration indicates a moderate password. The attack may take up to $minutes minutes.';
  }

  @override
  String strongPasswordMessage(String hours) {
    return 'This configuration indicates a strong password. The attack may take up to $hours hours.';
  }

  @override
  String veryStrongPasswordMessage(String duration) {
    return 'This configuration indicates a VERY STRONG password (est. $duration). Brute-force is IMPRACTICAL with common devices. This app is effective only for WEAK passwords (4-6 characters).';
  }

  @override
  String veryStrongPasswordMessageYears(String years) {
    return 'This configuration indicates a VERY STRONG password (est. $years years). Brute-force is IMPRACTICAL with common devices. This app is effective only for WEAK passwords (4-6 characters).';
  }

  @override
  String passwordConfigurationInfo(
    int minLength,
    int maxLength,
    int charsetSize,
  ) {
    return 'Configuration: $minLength-$maxLength chars • Charset: $charsetSize characters';
  }

  @override
  String get appEffectiveFor =>
      'This app is most effective for passwords under 7 characters.';

  @override
  String estimatedDays(String days) {
    return '$days days';
  }

  @override
  String get lastPassword => 'Last Password';

  @override
  String get consoleAttempts => 'Attempts';

  @override
  String get consoleSpeed => 'Speed';

  @override
  String get consoleElapsed => 'Elapsed';
}

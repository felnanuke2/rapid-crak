import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Cracker - Brute Force'**
  String get appTitle;

  /// No description provided for @noResult.
  ///
  /// In en, this message translates to:
  /// **'No result'**
  String get noResult;

  /// No description provided for @passwordFound.
  ///
  /// In en, this message translates to:
  /// **'✓ PASSWORD FOUND'**
  String get passwordFound;

  /// No description provided for @passwordNotFound.
  ///
  /// In en, this message translates to:
  /// **'✗ PASSWORD NOT FOUND'**
  String get passwordNotFound;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statistics;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attempts;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @console.
  ///
  /// In en, this message translates to:
  /// **'CONSOLE'**
  String get console;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password copied!'**
  String get passwordCopied;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy Password'**
  String get copyPassword;

  /// No description provided for @newSearch.
  ///
  /// In en, this message translates to:
  /// **'New Search'**
  String get newSearch;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @newFile.
  ///
  /// In en, this message translates to:
  /// **'New File'**
  String get newFile;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @processingPassword.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingPassword;

  /// No description provided for @passwordNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Password not found with current settings.'**
  String get passwordNotFoundMessage;

  /// No description provided for @bruteForcingStrategy.
  ///
  /// In en, this message translates to:
  /// **'Brute Force Strategy'**
  String get bruteForcingStrategy;

  /// No description provided for @numbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers (0-9)'**
  String get numbers;

  /// No description provided for @lowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase (a-z)'**
  String get lowercase;

  /// No description provided for @uppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase (A-Z)'**
  String get uppercase;

  /// No description provided for @symbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols (!@#...)'**
  String get symbols;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password Length'**
  String get passwordLength;

  /// Password length range
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} characters'**
  String minMaxCharacters(int min, int max);

  /// No description provided for @warningLongPasswords.
  ///
  /// In en, this message translates to:
  /// **'Warning: Long passwords may take hours/days on mobile.'**
  String get warningLongPasswords;

  /// No description provided for @attackInProgress.
  ///
  /// In en, this message translates to:
  /// **'Attack in Progress'**
  String get attackInProgress;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE'**
  String get performance;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'RUNNING'**
  String get running;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @waitingAttempts.
  ///
  /// In en, this message translates to:
  /// **'Waiting for attempts...'**
  String get waitingAttempts;

  /// No description provided for @configureAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack Configuration'**
  String get configureAttack;

  /// No description provided for @optimizationTip.
  ///
  /// In en, this message translates to:
  /// **'Optimization Tip'**
  String get optimizationTip;

  /// No description provided for @optimizationMessage.
  ///
  /// In en, this message translates to:
  /// **'The fewer character options and shorter the length, the faster the attack.'**
  String get optimizationMessage;

  /// No description provided for @startAttack.
  ///
  /// In en, this message translates to:
  /// **'START PASSWORD CRACKING'**
  String get startAttack;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @selectProtectedFile.
  ///
  /// In en, this message translates to:
  /// **'Select a protected file'**
  String get selectProtectedFile;

  /// Supported file formats
  ///
  /// In en, this message translates to:
  /// **'Supported formats: {formats}'**
  String supportedFormats(String formats);

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import File'**
  String get importFile;

  /// No description provided for @passwordCrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'🔐 PASSWORD CRACKER'**
  String get passwordCrackerTitle;

  /// No description provided for @bruteForceRealTime.
  ///
  /// In en, this message translates to:
  /// **'Brute Force in Real Time'**
  String get bruteForceRealTime;

  /// No description provided for @invalidConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Invalid configuration'**
  String get invalidConfiguration;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength Analysis'**
  String get passwordStrength;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'WEAK PASSWORD'**
  String get weakPassword;

  /// No description provided for @moderatePassword.
  ///
  /// In en, this message translates to:
  /// **'MODERATE PASSWORD'**
  String get moderatePassword;

  /// No description provided for @strongPassword.
  ///
  /// In en, this message translates to:
  /// **'STRONG PASSWORD'**
  String get strongPassword;

  /// No description provided for @veryStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'VERY STRONG PASSWORD'**
  String get veryStrongPassword;

  /// No description provided for @weakPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'This configuration indicates a weak password. The attack should succeed quickly (under 1 minute).'**
  String get weakPasswordMessage;

  /// Message for moderate password difficulty
  ///
  /// In en, this message translates to:
  /// **'This configuration indicates a moderate password. The attack may take up to {minutes} minutes.'**
  String moderatePasswordMessage(String minutes);

  /// Message for strong password difficulty
  ///
  /// In en, this message translates to:
  /// **'This configuration indicates a strong password. The attack may take up to {hours} hours.'**
  String strongPasswordMessage(String hours);

  /// Message for very strong password (impractical to break)
  ///
  /// In en, this message translates to:
  /// **'This configuration indicates a VERY STRONG password (est. {duration}). Brute-force is IMPRACTICAL with common devices. This app is effective only for WEAK passwords (4-6 characters).'**
  String veryStrongPasswordMessage(String duration);

  /// Message for very strong password in years
  ///
  /// In en, this message translates to:
  /// **'This configuration indicates a VERY STRONG password (est. {years} years). Brute-force is IMPRACTICAL with common devices. This app is effective only for WEAK passwords (4-6 characters).'**
  String veryStrongPasswordMessageYears(String years);

  /// Password configuration details
  ///
  /// In en, this message translates to:
  /// **'Configuration: {minLength}-{maxLength} chars • Charset: {charsetSize} characters'**
  String passwordConfigurationInfo(
    int minLength,
    int maxLength,
    int charsetSize,
  );

  /// No description provided for @appEffectiveFor.
  ///
  /// In en, this message translates to:
  /// **'This app is most effective for passwords under 7 characters.'**
  String get appEffectiveFor;

  /// Estimated time in days
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String estimatedDays(String days);

  /// No description provided for @lastPassword.
  ///
  /// In en, this message translates to:
  /// **'Last Password'**
  String get lastPassword;

  /// No description provided for @consoleAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get consoleAttempts;

  /// No description provided for @consoleSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get consoleSpeed;

  /// No description provided for @consoleElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get consoleElapsed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

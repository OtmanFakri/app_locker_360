import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'App Locker 360'**
  String get appTitle;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Security section title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Fingerprint option
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// Fingerprint description
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint to unlock apps'**
  String get fingerprintDesc;

  /// Intruder selfie option
  ///
  /// In en, this message translates to:
  /// **'Intruder Selfie'**
  String get intruderSelfie;

  /// Intruder selfie description
  ///
  /// In en, this message translates to:
  /// **'Capture photo when wrong PIN is entered'**
  String get intruderSelfieDesc;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Dark mode description
  ///
  /// In en, this message translates to:
  /// **'Enable dark mode'**
  String get darkModeDesc;

  /// Language option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language description
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get languageDesc;

  /// Arabic language
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Stealth mode option
  ///
  /// In en, this message translates to:
  /// **'Stealth Mode'**
  String get stealthMode;

  /// Stealth mode description
  ///
  /// In en, this message translates to:
  /// **'Hide app from app list'**
  String get stealthModeDesc;

  /// Notifications option
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notifications description
  ///
  /// In en, this message translates to:
  /// **'Show notifications'**
  String get notificationsDesc;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Developer label
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Apps tab label
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get apps;

  /// Vault tab label
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vault;

  /// Search hint in apps list
  ///
  /// In en, this message translates to:
  /// **'Search for an app...'**
  String get searchApp;

  /// No apps found message
  ///
  /// In en, this message translates to:
  /// **'No apps found'**
  String get noApps;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Error loading apps message
  ///
  /// In en, this message translates to:
  /// **'Error loading apps'**
  String get errorLoadingApps;

  /// Enter PIN title
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// Access dashboard subtitle
  ///
  /// In en, this message translates to:
  /// **'To access the App Locker 360'**
  String get accessDashboard;

  /// Use PIN button
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

  /// Use fingerprint button
  ///
  /// In en, this message translates to:
  /// **'Use Fingerprint'**
  String get useFingerprint;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Empty vault message
  ///
  /// In en, this message translates to:
  /// **'No files in vault'**
  String get noFilesInVault;

  /// Add files hint
  ///
  /// In en, this message translates to:
  /// **'Tap + to add files'**
  String get tapToAddFiles;

  /// Images file type
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// Videos file type
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// Audio file type
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Documents file type
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// Choose file type dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose File Type'**
  String get chooseFileType;

  /// Other file types option
  ///
  /// In en, this message translates to:
  /// **'Other (MP3, PDF, APK...)'**
  String get otherFiles;

  /// File encrypted success message
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) encrypted successfully'**
  String fileEncryptedSuccess(int count);

  /// File deleted message
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get fileDeleted;

  /// File delete failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete file'**
  String get fileDeleteFailed;

  /// Storage permission required message
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required'**
  String get storagePermissionRequired;

  /// Permissions page title
  ///
  /// In en, this message translates to:
  /// **'Required Permissions'**
  String get permissionsRequired;

  /// Permissions page subtitle
  ///
  /// In en, this message translates to:
  /// **'We need these permissions to protect your apps and files'**
  String get permissionsSubtitle;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Grant permission button
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// Storage permission title
  ///
  /// In en, this message translates to:
  /// **'File Access'**
  String get storagePermission;

  /// Storage permission description
  ///
  /// In en, this message translates to:
  /// **'To save and encrypt your photos and videos in the vault'**
  String get storagePermissionDesc;

  /// Usage stats permission title
  ///
  /// In en, this message translates to:
  /// **'Usage Statistics'**
  String get usageStatsPermission;

  /// Usage stats permission description
  ///
  /// In en, this message translates to:
  /// **'To monitor and protect locked apps'**
  String get usageStatsPermissionDesc;

  /// System alert permission title
  ///
  /// In en, this message translates to:
  /// **'Display Over Apps'**
  String get systemAlertPermission;

  /// System alert permission description
  ///
  /// In en, this message translates to:
  /// **'To show lock screen when opening a protected app'**
  String get systemAlertPermissionDesc;

  /// Xiaomi popup permission title
  ///
  /// In en, this message translates to:
  /// **'Display Popup Windows in Background'**
  String get xiaomiPopupPermission;

  /// Xiaomi popup permission description
  ///
  /// In en, this message translates to:
  /// **'To allow lock screen display while apps are running in background (Xiaomi)'**
  String get xiaomiPopupPermissionDesc;

  /// Important instructions dialog title
  ///
  /// In en, this message translates to:
  /// **'Important Instructions'**
  String get importantInstructions;

  /// Xiaomi permission instructions
  ///
  /// In en, this message translates to:
  /// **'On the next page:\n\n1. Tap on \"Other permissions\"\n2. Find \"Display popup windows while running in the background\"\n3. Enable this permission\n4. Return to the app'**
  String get xiaomiInstructions;

  /// Understood open settings button
  ///
  /// In en, this message translates to:
  /// **'Got it, Open Settings'**
  String get understoodOpenSettings;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Welcome to
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// Onboarding welcome description
  ///
  /// In en, this message translates to:
  /// **'Advanced protection for your apps and personal files\\nwith top-level security'**
  String get onboardingWelcomeDesc;

  /// Powerful features title
  ///
  /// In en, this message translates to:
  /// **'Powerful Features'**
  String get powerfulFeatures;

  /// Features subtitle
  ///
  /// In en, this message translates to:
  /// **'Everything you need to protect your privacy'**
  String get featuresSubtitle;

  /// Lock apps feature
  ///
  /// In en, this message translates to:
  /// **'Lock Apps'**
  String get lockApps;

  /// Lock apps description
  ///
  /// In en, this message translates to:
  /// **'Protect your apps with PIN or fingerprint'**
  String get lockAppsDesc;

  /// File vault feature
  ///
  /// In en, this message translates to:
  /// **'File Vault'**
  String get fileVault;

  /// File vault description
  ///
  /// In en, this message translates to:
  /// **'Hide and encrypt your photos and videos'**
  String get fileVaultDesc;

  /// Intruder detection feature
  ///
  /// In en, this message translates to:
  /// **'Intruder Detection'**
  String get intruderDetection;

  /// Intruder detection description
  ///
  /// In en, this message translates to:
  /// **'Capture photo of anyone trying to open your apps'**
  String get intruderDetectionDesc;

  /// Top level security title
  ///
  /// In en, this message translates to:
  /// **'Top-Level Security'**
  String get topLevelSecurity;

  /// Security description
  ///
  /// In en, this message translates to:
  /// **'We use the latest encryption technologies to protect your data.\\nYour privacy is our top priority.'**
  String get securityDesc;

  /// AES-256 encryption badge
  ///
  /// In en, this message translates to:
  /// **'AES-256 Encryption'**
  String get aes256Encryption;

  /// Fingerprint protection badge
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Protection'**
  String get fingerprintProtection;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Create PIN title
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// Confirm PIN title
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// Enter 4-digit PIN subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter a 4-digit PIN'**
  String get enterFourDigitPin;

  /// Re-enter PIN for confirmation
  ///
  /// In en, this message translates to:
  /// **'Re-enter PIN for confirmation'**
  String get reEnterPin;

  /// PIN mismatch error
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match, try again'**
  String get pinMismatch;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

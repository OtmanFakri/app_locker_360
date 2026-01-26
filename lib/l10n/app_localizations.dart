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

  /// Camera permission denied message
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required for intruder selfie feature'**
  String get cameraPermissionDenied;

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
  /// **'Create New PIN'**
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
  /// **'PINs do not match. Try again.'**
  String get pinMismatch;

  /// Backup PIN label
  ///
  /// In en, this message translates to:
  /// **'Backup PIN'**
  String get backupPin;

  /// Backup PIN page title
  ///
  /// In en, this message translates to:
  /// **'Save Your Backup PIN'**
  String get backupPinTitle;

  /// Backup PIN description
  ///
  /// In en, this message translates to:
  /// **'This backup PIN can be used to recover access if you forget your main PIN. Save it in a safe place.'**
  String get backupPinDescription;

  /// Backup PIN warning message
  ///
  /// In en, this message translates to:
  /// **'You won\'t be able to see this again!'**
  String get backupPinWarning;

  /// Copy to clipboard button
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// Save to gallery button
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// Copied to clipboard success message
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get copiedToClipboard;

  /// Saved to gallery success message
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery!'**
  String get savedToGallery;

  /// Continue to app button
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get continueToApp;

  /// No description provided for @createPinDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter a new 4-digit PIN for your locker'**
  String get createPinDesc;

  /// No description provided for @confirmPinDesc.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new PIN to confirm'**
  String get confirmPinDesc;

  /// No description provided for @recoverAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover Account'**
  String get recoverAccount;

  /// No description provided for @enterBackupPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Backup PIN'**
  String get enterBackupPin;

  /// No description provided for @invalidBackupPin.
  ///
  /// In en, this message translates to:
  /// **'Invalid Backup PIN'**
  String get invalidBackupPin;

  /// No description provided for @verifyAndReset.
  ///
  /// In en, this message translates to:
  /// **'Verify & Reset PIN'**
  String get verifyAndReset;

  /// No description provided for @resetAppData.
  ///
  /// In en, this message translates to:
  /// **'Reset App Data'**
  String get resetAppData;

  /// No description provided for @resetDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Reset App Data?'**
  String get resetDataConfirmation;

  /// No description provided for @resetDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This will delete ALL data including locked/hidden files. This action cannot be undone.'**
  String get resetDataWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get resetEverything;

  /// Text to display when general code is required
  ///
  /// In en, this message translates to:
  /// **'Enter the code to unlock the application'**
  String get enterCodeToUnlockApp;

  /// Text to display when custom code is required
  ///
  /// In en, this message translates to:
  /// **'Enter the custom code to unlock the application'**
  String get enterCustomCodeToUnlockApp;

  /// Unlock generic text
  ///
  /// In en, this message translates to:
  /// **'Unlock to use app'**
  String get unlockToUseApp;

  /// Set Custom PIN button text
  ///
  /// In en, this message translates to:
  /// **'Set Custom PIN'**
  String get setCustomPin;

  /// Change Custom PIN button text
  ///
  /// In en, this message translates to:
  /// **'Change Custom PIN'**
  String get changeCustomPin;

  /// Lock Method section title
  ///
  /// In en, this message translates to:
  /// **'Lock Method'**
  String get lockMethod;

  /// Fingerprint and Global PIN option
  ///
  /// In en, this message translates to:
  /// **'Fingerprint + Global PIN'**
  String get fingerprintGlobalPin;

  /// Fingerprint and Global PIN description
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or global app PIN'**
  String get fingerprintGlobalPinDesc;

  /// Fingerprint and Custom PIN option
  ///
  /// In en, this message translates to:
  /// **'Fingerprint + Custom PIN'**
  String get fingerprintCustomPin;

  /// Fingerprint and Custom PIN description
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or custom app PIN'**
  String get fingerprintCustomPinDesc;

  /// Fingerprint and System Lock option
  ///
  /// In en, this message translates to:
  /// **'Fingerprint + System Lock'**
  String get fingerprintSystemLock;

  /// Fingerprint and System Lock description
  ///
  /// In en, this message translates to:
  /// **'Use device security (fingerprint/pattern)'**
  String get fingerprintSystemLockDesc;

  /// PIN Only option
  ///
  /// In en, this message translates to:
  /// **'PIN Only'**
  String get pinOnly;

  /// PIN Only description
  ///
  /// In en, this message translates to:
  /// **'Use PIN only (no fingerprint)'**
  String get pinOnlyDesc;

  /// Fingerprint Only option
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Only'**
  String get fingerprintOnly;

  /// Fingerprint Only description
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint only (no PIN)'**
  String get fingerprintOnlyDesc;

  /// Label indicating global PIN is selected
  ///
  /// In en, this message translates to:
  /// **'Selected: Global PIN'**
  String get selectedGlobalPin;

  /// Label indicating custom PIN is selected
  ///
  /// In en, this message translates to:
  /// **'Selected: Custom PIN'**
  String get selectedCustomPin;

  /// Switch button text
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAction;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
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

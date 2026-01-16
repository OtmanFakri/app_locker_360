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
  /// **'To access the dashboard'**
  String get accessDashboard;

  /// Use PIN button
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

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

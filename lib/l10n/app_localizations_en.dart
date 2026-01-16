// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'App Locker 360';

  @override
  String get settings => 'Settings';

  @override
  String get security => 'Security';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get fingerprintDesc => 'Use fingerprint to unlock apps';

  @override
  String get intruderSelfie => 'Intruder Selfie';

  @override
  String get intruderSelfieDesc => 'Capture photo when wrong PIN is entered';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Enable dark mode';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Choose app language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get privacy => 'Privacy';

  @override
  String get stealthMode => 'Stealth Mode';

  @override
  String get stealthModeDesc => 'Hide app from app list';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDesc => 'Show notifications';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get apps => 'Apps';

  @override
  String get vault => 'Vault';

  @override
  String get searchApp => 'Search for an app...';

  @override
  String get noApps => 'No apps found';

  @override
  String get noResults => 'No results found';

  @override
  String get errorLoadingApps => 'Error loading apps';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get accessDashboard => 'To access the dashboard';

  @override
  String get usePin => 'Use PIN';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get noFilesInVault => 'No files in vault';

  @override
  String get tapToAddFiles => 'Tap + to add files';

  @override
  String get images => 'Images';

  @override
  String get videos => 'Videos';

  @override
  String get audio => 'Audio';

  @override
  String get documents => 'Documents';

  @override
  String get chooseFileType => 'Choose File Type';

  @override
  String get otherFiles => 'Other (MP3, PDF, APK...)';

  @override
  String fileEncryptedSuccess(int count) {
    return '$count file(s) encrypted successfully';
  }

  @override
  String get fileDeleted => 'File deleted';

  @override
  String get fileDeleteFailed => 'Failed to delete file';

  @override
  String get storagePermissionRequired => 'Storage permission is required';
}

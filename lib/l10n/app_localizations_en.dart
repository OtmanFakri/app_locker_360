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
  String get cameraPermissionDenied => 'Camera permission is required for intruder selfie feature';

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
  String get accessDashboard => 'To access the App Locker 360';

  @override
  String get usePin => 'Use PIN';

  @override
  String get useFingerprint => 'Use Fingerprint';

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

  @override
  String get permissionsRequired => 'Required Permissions';

  @override
  String get permissionsSubtitle => 'We need these permissions to protect your apps and files';

  @override
  String get continueButton => 'Continue';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get storagePermission => 'File Access';

  @override
  String get storagePermissionDesc => 'To save and encrypt your photos and videos in the vault';

  @override
  String get usageStatsPermission => 'Usage Statistics';

  @override
  String get usageStatsPermissionDesc => 'To monitor and protect locked apps';

  @override
  String get systemAlertPermission => 'Display Over Apps';

  @override
  String get systemAlertPermissionDesc => 'To show lock screen when opening a protected app';

  @override
  String get xiaomiPopupPermission => 'Display Popup Windows in Background';

  @override
  String get xiaomiPopupPermissionDesc => 'To allow lock screen display while apps are running in background (Xiaomi)';

  @override
  String get importantInstructions => 'Important Instructions';

  @override
  String get xiaomiInstructions => 'On the next page:\n\n1. Tap on \"Other permissions\"\n2. Find \"Display popup windows while running in the background\"\n3. Enable this permission\n4. Return to the app';

  @override
  String get understoodOpenSettings => 'Got it, Open Settings';

  @override
  String get skip => 'Skip';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get onboardingWelcomeDesc => 'Advanced protection for your apps and personal files\\nwith top-level security';

  @override
  String get powerfulFeatures => 'Powerful Features';

  @override
  String get featuresSubtitle => 'Everything you need to protect your privacy';

  @override
  String get lockApps => 'Lock Apps';

  @override
  String get lockAppsDesc => 'Protect your apps with PIN or fingerprint';

  @override
  String get fileVault => 'File Vault';

  @override
  String get fileVaultDesc => 'Hide and encrypt your photos and videos';

  @override
  String get intruderDetection => 'Intruder Detection';

  @override
  String get intruderDetectionDesc => 'Capture photo of anyone trying to open your apps';

  @override
  String get topLevelSecurity => 'Top-Level Security';

  @override
  String get securityDesc => 'We use the latest encryption technologies to protect your data.\\nYour privacy is our top priority.';

  @override
  String get aes256Encryption => 'AES-256 Encryption';

  @override
  String get fingerprintProtection => 'Fingerprint Protection';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get createPin => 'Create New PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get enterFourDigitPin => 'Enter a 4-digit PIN';

  @override
  String get reEnterPin => 'Re-enter PIN for confirmation';

  @override
  String get pinMismatch => 'PINs do not match. Try again.';

  @override
  String get backupPin => 'Backup PIN';

  @override
  String get backupPinTitle => 'Save Your Backup PIN';

  @override
  String get backupPinDescription => 'This backup PIN can be used to recover access if you forget your main PIN. Save it in a safe place.';

  @override
  String get backupPinWarning => 'You won\'t be able to see this again!';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get saveToGallery => 'Save to Gallery';

  @override
  String get copiedToClipboard => 'Copied to clipboard!';

  @override
  String get savedToGallery => 'Saved to gallery!';

  @override
  String get continueToApp => 'Continue to App';

  @override
  String get createPinDesc => 'Enter a new 4-digit PIN for your locker';

  @override
  String get confirmPinDesc => 'Re-enter your new PIN to confirm';

  @override
  String get recoverAccount => 'Recover Account';

  @override
  String get enterBackupPin => 'Enter Backup PIN';

  @override
  String get invalidBackupPin => 'Invalid Backup PIN';

  @override
  String get verifyAndReset => 'Verify & Reset PIN';

  @override
  String get resetAppData => 'Reset App Data';

  @override
  String get resetDataConfirmation => 'Reset App Data?';

  @override
  String get resetDataWarning => 'This will delete ALL data including locked/hidden files. This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get resetEverything => 'Reset Everything';
}

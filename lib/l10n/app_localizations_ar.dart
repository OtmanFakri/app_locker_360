// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'App Locker 360';

  @override
  String get settings => 'الإعدادات';

  @override
  String get security => 'الأمان';

  @override
  String get fingerprint => 'البصمة';

  @override
  String get fingerprintDesc => 'استخدام البصمة لفتح التطبيقات';

  @override
  String get intruderSelfie => 'صور المتطفلين';

  @override
  String get intruderSelfieDesc => 'التقاط صورة عند إدخال رمز خاطئ';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get darkModeDesc => 'تفعيل الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get languageDesc => 'اختر لغة التطبيق';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get stealthMode => 'الوضع الخفي';

  @override
  String get stealthModeDesc => 'إخفاء التطبيق من قائمة التطبيقات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsDesc => 'إظهار الإشعارات';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get developer => 'المطور';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get apps => 'التطبيقات';

  @override
  String get vault => 'الخزنة';

  @override
  String get searchApp => 'ابحث عن تطبيق...';

  @override
  String get noApps => 'لا توجد تطبيقات';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get errorLoadingApps => 'خطأ في تحميل التطبيقات';

  @override
  String get enterPin => 'أدخل الرمز السري';

  @override
  String get accessDashboard => 'للوصول إلى لوحة التحكم';

  @override
  String get usePin => 'استخدام الرمز السري';

  @override
  String get forgotPassword => 'نسيت كلمة السر؟';

  @override
  String get noFilesInVault => 'لا توجد ملفات في الخزنة';

  @override
  String get tapToAddFiles => 'اضغط على + لإضافة ملفات';

  @override
  String get images => 'صور';

  @override
  String get videos => 'فيديو';

  @override
  String get audio => 'صوت';

  @override
  String get documents => 'مستندات';

  @override
  String get chooseFileType => 'اختر نوع الملف';

  @override
  String get otherFiles => 'أخرى (MP3, PDF, APK...)';

  @override
  String fileEncryptedSuccess(int count) {
    return 'تم تشفير $count ملف بنجاح';
  }

  @override
  String get fileDeleted => 'تم حذف الملف';

  @override
  String get fileDeleteFailed => 'فشل حذف الملف';

  @override
  String get storagePermissionRequired => 'يجب منح صلاحية الوصول للملفات';
}

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

  @override
  String get permissionsRequired => 'الأذونات المطلوبة';

  @override
  String get permissionsSubtitle => 'نحتاج هذه الأذونات لحماية تطبيقاتك وملفاتك';

  @override
  String get continueButton => 'متابعة';

  @override
  String get grantPermission => 'منح الإذن';

  @override
  String get storagePermission => 'الوصول للملفات';

  @override
  String get storagePermissionDesc => 'لحفظ وتشفير صورك وفيديوهاتك في الخزنة';

  @override
  String get usageStatsPermission => 'إحصائيات الاستخدام';

  @override
  String get usageStatsPermissionDesc => 'لمراقبة التطبيقات المقفلة وحمايتها';

  @override
  String get systemAlertPermission => 'العرض فوق التطبيقات';

  @override
  String get systemAlertPermissionDesc => 'لعرض شاشة القفل عند فتح تطبيق محمي';

  @override
  String get xiaomiPopupPermission => 'عرض النوافذ المنبثقة في الخلفية';

  @override
  String get xiaomiPopupPermissionDesc => 'للسماح بعرض شاشة القفل أثناء تشغيل التطبيقات في الخلفية (Xiaomi)';

  @override
  String get importantInstructions => 'تعليمات مهمة';

  @override
  String get xiaomiInstructions => 'في الصفحة التالية:\\n\\n1. اضغط على \"أذونات أخرى\"\\n2. ابحث عن \"عرض النوافذ المنبثقة أثناء التشغيل في الخلفية\"\\n3. قم بتفعيل هذا الإذن\\n4. ارجع للتطبيق';

  @override
  String get understoodOpenSettings => 'فهمت، افتح الإعدادات';

  @override
  String get skip => 'تخطي';

  @override
  String get welcomeTo => 'مرحباً بك في';

  @override
  String get onboardingWelcomeDesc => 'حماية متقدمة لتطبيقاتك وملفاتك الشخصية\\nمع أمان من الدرجة الأولى';

  @override
  String get powerfulFeatures => 'مميزات قوية';

  @override
  String get featuresSubtitle => 'كل ما تحتاجه لحماية خصوصيتك';

  @override
  String get lockApps => 'قفل التطبيقات';

  @override
  String get lockAppsDesc => 'حماية تطبيقاتك برمز سري أو بصمة';

  @override
  String get fileVault => 'خزنة الملفات';

  @override
  String get fileVaultDesc => 'إخفاء وتشفير صورك وفيديوهاتك';

  @override
  String get intruderDetection => 'كشف المتطفلين';

  @override
  String get intruderDetectionDesc => 'التقاط صورة لمن يحاول فتح تطبيقاتك';

  @override
  String get topLevelSecurity => 'أمان من الدرجة الأولى';

  @override
  String get securityDesc => 'نستخدم أحدث تقنيات التشفير لحماية بياناتك.\\nخصوصيتك هي أولويتنا القصوى.';

  @override
  String get aes256Encryption => 'تشفير AES-256';

  @override
  String get fingerprintProtection => 'حماية بالبصمة';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get createPin => 'إنشاء رمز سري';

  @override
  String get confirmPin => 'تأكيد الرمز السري';

  @override
  String get enterFourDigitPin => 'أدخل رمز سري مكون من 4 أرقام';

  @override
  String get reEnterPin => 'أدخل الرمز مرة أخرى للتأكيد';

  @override
  String get pinMismatch => 'الرمز غير متطابق، حاول مرة أخرى';
}

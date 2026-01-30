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
  String get cameraPermissionDenied => 'إذن الكاميرا مطلوب لتفعيل خاصية صور المتطفلين';

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
  String get accessDashboard => 'للوصول إلى التطبيق';

  @override
  String get usePin => 'استخدام الرمز السري';

  @override
  String get useFingerprint => 'استخدام البصمة';

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
  String get permissionsRequired => 'صلاحية المطلوبة';

  @override
  String get permissionsSubtitle => 'نحتاج هذه صلاحية لحماية تطبيقاتك وملفاتك';

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
  String get createPin => 'إنشاء رمز جديد';

  @override
  String get confirmPin => 'تأكيد الرمز';

  @override
  String get enterFourDigitPin => 'أدخل رمز سري مكون من 4 أرقام';

  @override
  String get reEnterPin => 'أدخل الرمز مرة أخرى للتأكيد';

  @override
  String get pinMismatch => 'الرموز غير متطابقة. حاول مرة أخرى.';

  @override
  String get backupPin => 'رمز النسخ الاحتياطي';

  @override
  String get backupPinTitle => 'احفظ رمز النسخ الاحتياطي';

  @override
  String get backupPinDescription => 'يمكن استخدام رمز النسخ الاحتياطي هذا لاستعادة الوصول إذا نسيت الرمز السري الرئيسي. احفظه في مكان آمن.';

  @override
  String get backupPinWarning => 'لن تتمكن من رؤية هذا مرة أخرى!';

  @override
  String get copyToClipboard => 'نسخ إلى الحافظة';

  @override
  String get saveToGallery => 'حفظ في المعرض';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة!';

  @override
  String get savedToGallery => 'تم الحفظ في المعرض!';

  @override
  String get continueToApp => 'المتابعة إلى التطبيق';

  @override
  String get createPinDesc => 'أدخل رمز مرور جديد مكون من 4 أرقام';

  @override
  String get confirmPinDesc => 'أعد إدخال الرمز الجديد للتأكيد';

  @override
  String get recoverAccount => 'استرجاع الحساب';

  @override
  String get enterBackupPin => 'أدخل رمز النسخ الاحتياطي';

  @override
  String get invalidBackupPin => 'رمز النسخ الاحتياطي غير صحيح';

  @override
  String get verifyAndReset => 'تحقق وإعادة تعيين';

  @override
  String get resetAppData => 'إعادة تعيين البيانات';

  @override
  String get resetDataConfirmation => 'إعادة تعيين بيانات التطبيق؟';

  @override
  String get resetDataWarning => 'سيتم حذف جميع البيانات بما في ذلك الملفات المقفلة والمخفية. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get resetEverything => 'إعادة تعيين الكل';

  @override
  String get enterCodeToUnlockApp => 'ادخل الرمز لفتح التطبيق';

  @override
  String get enterCustomCodeToUnlockApp => 'ادخل الرمز الخاص لفتح التطبيق';

  @override
  String get unlockToUseApp => 'افتح القفل لاستخدام التطبيق';

  @override
  String get setCustomPin => 'تعيين رمز خاص';

  @override
  String get changeCustomPin => 'تغيير الرمز الخاص';

  @override
  String get lockMethod => 'طريقة القفل';

  @override
  String get fingerprintGlobalPin => 'بصمة + رمز عام';

  @override
  String get fingerprintGlobalPinDesc => 'القفل بالبصمة أو الرمز العام للتطبيق';

  @override
  String get fingerprintCustomPin => 'بصمة + رمز خاص';

  @override
  String get fingerprintCustomPinDesc => 'القفل بالبصمة أو رمز خاص لهذا التطبيق';

  @override
  String get fingerprintSystemLock => 'بصمة + رمز الهاتف';

  @override
  String get fingerprintSystemLockDesc => 'القفل باستخدام أمان الهاتف (بصمة/نمط)';

  @override
  String get pinOnly => 'رمز فقط';

  @override
  String get pinOnlyDesc => 'القفل بالرمز فقط (بدون بصمة)';

  @override
  String get fingerprintOnly => 'بصمة فقط';

  @override
  String get fingerprintOnlyDesc => 'القفل بالبصمة فقط (بدون رمز)';

  @override
  String get selectedGlobalPin => 'المحدد: رمز عام';

  @override
  String get selectedCustomPin => 'المحدد: رمز خاص';

  @override
  String get switchAction => 'تبديل';

  @override
  String get save => 'حفظ';
}

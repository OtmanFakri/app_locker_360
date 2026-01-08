import 'package:hive/hive.dart';

part 'global_settings.g.dart';

@HiveType(typeId: 2)
class GlobalSettings extends HiveObject {
  /// الرمز السري الرئيسي للتطبيق
  @HiveField(0)
  String masterPin;

  /// ثيم التطبيق (Light, Dark, System)
  @HiveField(1)
  String appTheme;

  /// مدة إعادة القفل بالثواني (0 = فوري)
  @HiveField(2)
  int reLockTimeout;

  /// تفعيل البصمة
  @HiveField(3)
  bool fingerprintEnabled;

  /// تفعيل صور المتطفلين
  @HiveField(4)
  bool intruderSelfie;

  /// اللغة المفضلة
  @HiveField(5)
  String? preferredLanguage;

  /// تفعيل الإشعارات
  @HiveField(6)
  bool notificationsEnabled;

  /// عدد المحاولات المسموح بها قبل التنبيه
  @HiveField(7)
  int maxAttempts;

  /// إخفاء التطبيق من قائمة التطبيقات
  @HiveField(8)
  bool hideAppIcon;

  /// تفعيل الوضع الخفي (Stealth Mode)
  @HiveField(9)
  bool stealthMode;

  /// هل أكمل المستخدم شاشة الإعداد الأولي
  @HiveField(10)
  bool hasCompletedOnboarding;

  /// Salt for encryption key derivation
  @HiveField(11)
  List<int>? encryptionSalt;

  GlobalSettings({
    this.masterPin = "",
    this.appTheme = "Light",
    this.reLockTimeout = 0,
    this.fingerprintEnabled = false,
    this.intruderSelfie = true,
    this.preferredLanguage,
    this.notificationsEnabled = true,
    this.maxAttempts = 3,
    this.hideAppIcon = false,
    this.stealthMode = false,
    this.hasCompletedOnboarding = false,
    this.encryptionSalt,
  });

  /// Create a copy with modified fields
  GlobalSettings copyWith({
    String? masterPin,
    String? appTheme,
    int? reLockTimeout,
    bool? fingerprintEnabled,
    bool? intruderSelfie,
    String? preferredLanguage,
    bool? notificationsEnabled,
    int? maxAttempts,
    bool? hideAppIcon,
    bool? stealthMode,
    bool? hasCompletedOnboarding,
    List<int>? encryptionSalt,
  }) {
    return GlobalSettings(
      masterPin: masterPin ?? this.masterPin,
      appTheme: appTheme ?? this.appTheme,
      reLockTimeout: reLockTimeout ?? this.reLockTimeout,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      intruderSelfie: intruderSelfie ?? this.intruderSelfie,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      hideAppIcon: hideAppIcon ?? this.hideAppIcon,
      stealthMode: stealthMode ?? this.stealthMode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      encryptionSalt: encryptionSalt ?? this.encryptionSalt,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'masterPin': masterPin,
      'appTheme': appTheme,
      'reLockTimeout': reLockTimeout,
      'fingerprintEnabled': fingerprintEnabled,
      'intruderSelfie': intruderSelfie,
      'preferredLanguage': preferredLanguage,
      'notificationsEnabled': notificationsEnabled,
      'maxAttempts': maxAttempts,
      'hideAppIcon': hideAppIcon,
      'stealthMode': stealthMode,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'encryptionSalt': encryptionSalt,
    };
  }

  /// Create from Map
  factory GlobalSettings.fromMap(Map<String, dynamic> map) {
    return GlobalSettings(
      masterPin: map['masterPin'] as String? ?? "",
      appTheme: map['appTheme'] as String? ?? "Light",
      reLockTimeout: map['reLockTimeout'] as int? ?? 0,
      fingerprintEnabled: map['fingerprintEnabled'] as bool? ?? false,
      intruderSelfie: map['intruderSelfie'] as bool? ?? true,
      preferredLanguage: map['preferredLanguage'] as String?,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      maxAttempts: map['maxAttempts'] as int? ?? 3,
      hideAppIcon: map['hideAppIcon'] as bool? ?? false,
      stealthMode: map['stealthMode'] as bool? ?? false,
      hasCompletedOnboarding: map['hasCompletedOnboarding'] as bool? ?? false,
      encryptionSalt: map['encryptionSalt'] as List<int>?,
    );
  }

  /// Check if master PIN is set
  bool get hasMasterPin => masterPin.isNotEmpty;

  /// Check if dark theme is enabled
  bool get isDarkTheme => appTheme.toLowerCase() == 'dark';

  /// Check if system theme is enabled
  bool get isSystemTheme => appTheme.toLowerCase() == 'system';

  /// Get re-lock timeout in minutes
  double get reLockTimeoutMinutes => reLockTimeout / 60.0;

  @override
  String toString() {
    return 'GlobalSettings(masterPin: ${masterPin.isNotEmpty ? "***" : "not set"}, appTheme: $appTheme, reLockTimeout: $reLockTimeout, fingerprintEnabled: $fingerprintEnabled, intruderSelfie: $intruderSelfie, notificationsEnabled: $notificationsEnabled, maxAttempts: $maxAttempts, hideAppIcon: $hideAppIcon, stealthMode: $stealthMode)';
  }
}

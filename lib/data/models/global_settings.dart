class GlobalSettings {
  /// الرمز السري الرئيسي للتطبيق
  String masterPin;

  /// رمز النسخ الاحتياطي للاسترجاع
  String backupPin;

  /// ثيم التطبيق (Light, Dark, System)
  String appTheme;

  /// مدة إعادة القفل بالثواني (0 = فوري)
  int reLockTimeout;

  /// تفعيل البصمة
  bool fingerprintEnabled;

  /// تفعيل صور المتطفلين
  bool intruderSelfie;

  /// اللغة المفضلة (ar = العربية, en = English)
  String preferredLanguage;

  /// تفعيل الإشعارات
  bool notificationsEnabled;

  /// عدد المحاولات المسموح بها قبل التنبيه
  int maxAttempts;

  /// إخفاء التطبيق من قائمة التطبيقات
  bool hideAppIcon;

  /// تفعيل الوضع الخفي (Stealth Mode)
  bool stealthMode;

  /// هل أكمل المستخدم شاشة الإعداد الأولي
  bool hasCompletedOnboarding;

  /// Salt for encryption key derivation
  List<int>? encryptionSalt;

  GlobalSettings({
    this.masterPin = "",
    this.backupPin = "",
    this.appTheme = "Light",
    this.reLockTimeout = 0,
    this.fingerprintEnabled = false,
    this.intruderSelfie = true,
    this.preferredLanguage = 'ar',
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
    String? backupPin,
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
      backupPin: backupPin ?? this.backupPin,
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
      'backupPin': backupPin,
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
      backupPin: map['backupPin'] as String? ?? "",
      appTheme: map['appTheme'] as String? ?? "Light",
      reLockTimeout: map['reLockTimeout'] as int? ?? 0,
      fingerprintEnabled: map['fingerprintEnabled'] as bool? ?? false,
      intruderSelfie: map['intruderSelfie'] as bool? ?? true,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'ar',
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

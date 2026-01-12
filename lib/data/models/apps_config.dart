/// Enum for lock type
enum LockType {
  global, // استخدام  الرمز العام
  custom, // استخدام رمز خاص
}

/// Enum for network blocking
enum NetBlock {
  none, // النت خدام عادي
  wifi, // قطع الواي فاي فقط
  mobile, // قطع بيانات الموبايل فقط
  all, // قطع كل الإنترنت
}

class AppsConfig {
  /// معرف التطبيق (Package Name) - Primary Key
  final String packageName;

  /// اسم التطبيق
  String appName;

  /// هل التطبيق مقفول؟
  bool isLocked;

  /// هل التطبيق مخفي؟
  bool isHidden;

  /// نوع القفل (عام أو خاص)
  LockType lockType;

  /// الرمز الخاص (إذا كان نوع القفل custom)
  String? customPin;

  /// حظر الإنترنت
  NetBlock blockInternet;

  /// إظهار أيقونة العين في شاشة القفل
  bool eyeIconVisible;

  AppsConfig({
    required this.packageName,
    this.appName = "Unknown App",
    this.isLocked = false,
    this.isHidden = false,
    this.lockType = LockType.global,
    this.customPin,
    this.blockInternet = NetBlock.none,
    this.eyeIconVisible = true,
  });

  /// Create a copy with modified fields
  AppsConfig copyWith({
    String? packageName,
    String? appName,
    bool? isLocked,
    bool? isHidden,
    LockType? lockType,
    String? customPin,
    NetBlock? blockInternet,
    bool? eyeIconVisible,
  }) {
    return AppsConfig(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      lockType: lockType ?? this.lockType,
      customPin: customPin ?? this.customPin,
      blockInternet: blockInternet ?? this.blockInternet,
      eyeIconVisible: eyeIconVisible ?? this.eyeIconVisible,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'isLocked': isLocked,
      'isHidden': isHidden,
      'lockType': lockType.index,
      'customPin': customPin,
      'blockInternet': blockInternet.index,
      'eyeIconVisible': eyeIconVisible,
    };
  }

  /// Create from Map
  factory AppsConfig.fromMap(Map<String, dynamic> map) {
    return AppsConfig(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String? ?? "Unknown App",
      isLocked: map['isLocked'] as bool? ?? false,
      isHidden: map['isHidden'] as bool? ?? false,
      lockType: LockType.values[map['lockType'] as int? ?? 0],
      customPin: map['customPin'] as String?,
      blockInternet: NetBlock.values[map['blockInternet'] as int? ?? 0],
      eyeIconVisible: map['eyeIconVisible'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'AppsConfig(packageName: $packageName, appName: $appName, isLocked: $isLocked, isHidden: $isHidden, lockType: $lockType, customPin: $customPin, blockInternet: $blockInternet, eyeIconVisible: $eyeIconVisible)';
  }
}

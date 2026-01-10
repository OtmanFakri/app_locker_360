import 'package:hive/hive.dart';

part 'apps_config.g.dart';

/// Enum for lock type
@HiveType(typeId: 5)
enum LockType {
  @HiveField(0)
  global, // استخدام  الرمز العام
  @HiveField(1)
  custom, // استخدام رمز خاص
}

/// Enum for network blocking
@HiveType(typeId: 6)
enum NetBlock {
  @HiveField(0)
  none, // النت خدام عادي
  @HiveField(1)
  wifi, // قطع الواي فاي فقط
  @HiveField(2)
  mobile, // قطع بيانات الموبايل فقط
  @HiveField(3)
  all, // قطع كل الإنترنت
}

@HiveType(typeId: 0)
class AppsConfig extends HiveObject {
  /// معرف التطبيق (Package Name) - Primary Key
  @HiveField(0)
  final String packageName;

  /// اسم التطبيق
  @HiveField(1)
  String appName;

  /// هل التطبيق مقفول؟
  @HiveField(2)
  bool isLocked;

  /// هل التطبيق مخفي؟
  @HiveField(3)
  bool isHidden;

  /// نوع القفل (عام أو خاص)
  @HiveField(4)
  LockType lockType;

  /// الرمز الخاص (إذا كان نوع القفل custom)
  @HiveField(5)
  String? customPin;

  /// حظر الإنترنت
  @HiveField(6)
  NetBlock blockInternet;

  /// إظهار أيقونة العين في شاشة القفل
  @HiveField(7)
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

import 'package:hive/hive.dart';

part 'log_entry.g.dart';

/// Enum for log status
enum LogStatus {
  success, // نجح في فتح التطبيق
  failed, // فشل في فتح التطبيق
}

@HiveType(typeId: 3)
class LogEntry extends HiveObject {
  /// معرف السجل (Auto-increment)
  @HiveField(0)
  final int id;

  /// اسم حزمة التطبيق الذي تم محاولة فتحه
  @HiveField(1)
  String packageName;

  /// اسم التطبيق (للعرض)
  @HiveField(2)
  String? appName;

  /// وقت وتاريخ المحاولة
  @HiveField(3)
  DateTime timestamp;

  /// حالة المحاولة (نجاح أو فشل)
  @HiveField(4)
  LogStatus status;

  /// مسار صورة المتطفل (إذا فشلت المحاولة)
  @HiveField(5)
  String? photoPath;

  /// الرمز الذي تم إدخاله (للتحليل - اختياري)
  @HiveField(6)
  String? attemptedPin;

  /// عدد المحاولات الفاشلة المتتالية
  @HiveField(7)
  int failedAttempts;

  /// عنوان IP (إذا كان متاحاً)
  @HiveField(8)
  String? ipAddress;

  /// معلومات الجهاز
  @HiveField(9)
  String? deviceInfo;

  LogEntry({
    required this.id,
    required this.packageName,
    this.appName,
    DateTime? timestamp,
    required this.status,
    this.photoPath,
    this.attemptedPin,
    this.failedAttempts = 0,
    this.ipAddress,
    this.deviceInfo,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a copy with modified fields
  LogEntry copyWith({
    int? id,
    String? packageName,
    String? appName,
    DateTime? timestamp,
    LogStatus? status,
    String? photoPath,
    String? attemptedPin,
    int? failedAttempts,
    String? ipAddress,
    String? deviceInfo,
  }) {
    return LogEntry(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      photoPath: photoPath ?? this.photoPath,
      attemptedPin: attemptedPin ?? this.attemptedPin,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'appName': appName,
      'timestamp': timestamp.toIso8601String(),
      'status': status.index,
      'photoPath': photoPath,
      'attemptedPin': attemptedPin,
      'failedAttempts': failedAttempts,
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }

  /// Create from Map
  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as int,
      packageName: map['packageName'] as String,
      appName: map['appName'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      status: LogStatus.values[map['status'] as int? ?? 0],
      photoPath: map['photoPath'] as String?,
      attemptedPin: map['attemptedPin'] as String?,
      failedAttempts: map['failedAttempts'] as int? ?? 0,
      ipAddress: map['ipAddress'] as String?,
      deviceInfo: map['deviceInfo'] as String?,
    );
  }

  /// Check if this is a failed attempt
  bool get isFailed => status == LogStatus.failed;

  /// Check if this is a successful attempt
  bool get isSuccess => status == LogStatus.success;

  /// Check if intruder photo exists
  bool get hasIntruderPhoto => photoPath != null && photoPath!.isNotEmpty;

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  String toString() {
    return 'LogEntry(id: $id, packageName: $packageName, appName: $appName, timestamp: $timestamp, status: $status, failedAttempts: $failedAttempts, hasPhoto: $hasIntruderPhoto)';
  }
}

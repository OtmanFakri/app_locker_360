import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// خدمة كشف المتطفلين - تلتقط صورة عند إدخال رمز خاطئ
class IntruderDetectionService {
  /// التقاط صورة المتطفل وحفظها بشكل صامت (بدون فتح الكاميرا)
  /// Returns: مسار الملف المحفوظ أو null في حالة الفشل
  static Future<String?> captureIntruderPhoto() async {
    CameraController? controller;

    try {
      // 1. التحقق من الأذونات وطلبها إذا لزم الأمر
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        print('⚠️ IntruderDetection: Camera permission denied');
        return null;
      }

      // 2. الحصول على قائمة الكاميرات المتاحة
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('⚠️ IntruderDetection: No cameras available');
        return null;
      }

      // 3. العثور على الكاميرا الأمامية
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras
            .first, // استخدام أول كاميرا متاحة إذا لم تكن هناك كاميرا أمامية
      );

      // 4. تهيئة مراقب الكاميرا
      controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false, // لا حاجة للصوت
      );

      await controller.initialize();

      // 5. التقاط الصورة
      final image = await controller.takePicture();

      // 6. حفظ الصورة في مجلد مخصص
      final savedPath = await _saveIntruderPhoto(image.path);

      // 7. تنظيف الملف المؤقت
      final tempFile = File(image.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (savedPath != null) {
        print('✅ IntruderDetection: Photo saved to: $savedPath');
      }

      return savedPath;
    } catch (e) {
      print('❌ IntruderDetection: Error capturing photo: $e');
      return null;
    } finally {
      // 8. تحرير موارد الكاميرا
      await controller?.dispose();
    }
  }

  /// حفظ صورة المتطفل في مجلد مخصص
  static Future<String?> _saveIntruderPhoto(String tempPath) async {
    try {
      // الحصول على مجلد التخزين
      final directory = await getIntruderPhotosDirectory();

      // إنشاء اسم ملف فريد بالتاريخ والوقت
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'intruder_$timestamp.jpg';
      final filePath = '${directory.path}/$fileName';

      // نسخ الملف إلى المجلد المخصص
      final File sourceFile = File(tempPath);
      await sourceFile.copy(filePath);

      return filePath;
    } catch (e) {
      print('❌ IntruderDetection: Error saving photo: $e');
      return null;
    }
  }

  /// الحصول على مجلد صور المتطفلين
  static Future<Directory> getIntruderPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final intruderDir = Directory('${appDir.path}/intruder_photos');

    // إنشاء المجلد إذا لم يكن موجوداً
    if (!await intruderDir.exists()) {
      await intruderDir.create(recursive: true);
    }

    return intruderDir;
  }

  /// التحقق من أذونات الكاميرا والتخزين وطلبها إذا لزم الأمر
  static Future<bool> checkAndRequestPermissions() async {
    try {
      // التحقق من إذن الكاميرا
      PermissionStatus cameraStatus = await Permission.camera.status;

      if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
        // طلب الإذن
        cameraStatus = await Permission.camera.request();
      }

      // التحقق من حالة الإذن النهائية
      if (!cameraStatus.isGranted) {
        return false;
      }

      // ملاحظة: في Android 10+ (API 29+)، لا نحتاج إلى إذن التخزين
      // لحفظ الملفات في مجلد التطبيق الخاص

      return true;
    } catch (e) {
      print('❌ IntruderDetection: Error checking permissions: $e');
      return false;
    }
  }

  /// الحصول على قائمة بجميع صور المتطفلين المحفوظة
  static Future<List<File>> getIntruderPhotos() async {
    try {
      final directory = await getIntruderPhotosDirectory();
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .toList();

      // ترتيب حسب الأحدث أولاً
      files.sort((a, b) => b.path.compareTo(a.path));

      return files;
    } catch (e) {
      print('❌ IntruderDetection: Error getting photos: $e');
      return [];
    }
  }

  /// حذف جميع صور المتطفلين
  static Future<bool> clearAllIntruderPhotos() async {
    try {
      final directory = await getIntruderPhotosDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(); // إعادة إنشاء المجلد فارغاً
      }
      return true;
    } catch (e) {
      print('❌ IntruderDetection: Error clearing photos: $e');
      return false;
    }
  }

  /// حذف صورة متطفل معينة
  static Future<bool> deleteIntruderPhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ IntruderDetection: Error deleting photo: $e');
      return false;
    }
  }
}

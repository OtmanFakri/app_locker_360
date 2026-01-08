import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

/// File manager service for handling file operations
class FileManagerService {
  static final ImagePicker _picker = ImagePicker();

  /// Request storage permissions
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isGranted) return true;

      final manageStatus = await Permission.manageExternalStorage.status;
      return manageStatus.isGranted;
    }
    return true;
  }

  /// Get app's private directory for storing encrypted files
  static Future<Directory> getVaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/vault');

    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }

    return vaultDir;
  }

  /// Get temporary directory for decrypted files
  static Future<Directory> getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final decryptedDir = Directory('${tempDir.path}/decrypted');

    if (!await decryptedDir.exists()) {
      await decryptedDir.create(recursive: true);
    }

    return decryptedDir;
  }

  /// Pick images from gallery
  static Future<List<File>?> pickImages({bool allowMultiple = true}) async {
    try {
      if (allowMultiple) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          return images.map((xfile) => File(xfile.path)).toList();
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          return [File(image.path)];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Image picking failed: $e');
    }
  }

  /// Pick a video from gallery
  static Future<File?> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      throw Exception('Video picking failed: $e');
    }
  }

  /// Copy file to vault directory
  static Future<File> copyToVault({
    required File sourceFile,
    required String fileName,
  }) async {
    try {
      final vaultDir = await getVaultDirectory();
      final destinationPath = '${vaultDir.path}/$fileName';
      final destinationFile = File(destinationPath);

      // Copy file
      await sourceFile.copy(destinationPath);

      return destinationFile;
    } catch (e) {
      throw Exception('Copy to vault failed: $e');
    }
  }

  /// Delete original file securely
  static Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('File deletion failed: $e');
    }
  }

  /// Delete file with secure overwrite (optional, slower)
  static Future<bool> secureDeleteFile(File file) async {
    try {
      if (await file.exists()) {
        final fileSize = await file.length();

        // Overwrite with random data
        final randomData = List.generate(fileSize, (index) => 0);
        await file.writeAsBytes(randomData);

        // Delete
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Secure deletion failed: $e');
    }
  }

  /// Get file size in bytes
  static Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = filePath.split('/').last;
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
    }
    return parts.join('.');
  }

  /// Determine file type from extension
  static String getFileType(String extension) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    const videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv'];
    const audioExtensions = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'];
    const documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'];

    final ext = extension.toLowerCase();

    if (imageExtensions.contains(ext)) return 'image';
    if (videoExtensions.contains(ext)) return 'video';
    if (audioExtensions.contains(ext)) return 'audio';
    if (documentExtensions.contains(ext)) return 'document';

    return 'other';
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Clean up temporary decrypted files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTempDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Get all files in vault directory
  static Future<List<File>> getVaultFiles() async {
    try {
      final vaultDir = await getVaultDirectory();
      if (!await vaultDir.exists()) {
        return [];
      }

      final entities = await vaultDir.list().toList();
      return entities.whereType<File>().toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/vault_item.dart';
import 'package:app_locker360/data/services/encryption_service.dart';
import 'package:app_locker360/data/services/file_manager_service.dart';

/// Service for managing vault operations
/// Handles the complete workflow: Selection → Processing → Storage → Cleanup
class VaultService {
  /// Add a file to the vault
  /// Complete workflow:
  /// 1. Generate thumbnail (if image/video)
  /// 2. Encrypt file using stream encryption
  /// 3. Save encrypted file to private directory
  /// 4. Create and store VaultItem in Hive
  /// 5. Cleanup temporary files
  static Future<VaultItem> addFileToVault({
    required File sourceFile,
    required String masterPin,
    required Uint8List encryptionSalt,
    AssetEntity? originalAsset, // NEW: Optional asset for direct deletion
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Get file info
      final fileName = sourceFile.path.split('/').last;
      final extension = FileManagerService.getFileExtension(sourceFile.path);
      final fileTypeString = FileManagerService.getFileType(extension);
      final fileType = _parseFileType(fileTypeString);
      final fileSize = await FileManagerService.getFileSize(sourceFile);

      // Update progress
      onProgress?.call(0.1);

      print(
        '📦 Processing file: $fileName (type: $fileTypeString, size: $fileSize bytes)',
      );

      // Generate thumbnail for images and videos
      Uint8List? thumbnail;
      if (fileType == FileType.image) {
        thumbnail = await _generateImageThumbnail(sourceFile);
      } else if (fileType == FileType.video) {
        thumbnail = await _generateVideoThumbnail(sourceFile);
      } else {
        print('ℹ️  No thumbnail needed for file type: $fileTypeString');
      }

      // Update progress
      onProgress?.call(0.3);

      // Generate unique encrypted filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final encryptedFileName = 'enc_$timestamp.$extension';

      // Get vault directory
      final vaultDir = await FileManagerService.getVaultDirectory();
      final encryptedFile = File('${vaultDir.path}/$encryptedFileName');

      // Encrypt file using streaming in a background isolate
      await compute(
        _encryptFileTask,
        _EncryptionTaskArgs(
          sourcePath: sourceFile.path,
          destinationPath: encryptedFile.path,
          pin: masterPin,
          salt: encryptionSalt,
        ),
      );

      // Update progress
      onProgress?.call(0.7);

      // Verify encrypted file exists
      if (!await encryptedFile.exists()) {
        throw Exception('Encrypted file was not created');
      }

      // Create vault item
      final vaultItem = VaultItem(
        id: timestamp.toString(),
        originalPath: sourceFile.path,
        encryptedPath: encryptedFile.path,
        fileType: fileType,
        addedDate: DateTime.now(),
        fileName: fileName,
        fileSizeBytes: fileSize,
        thumbnail: thumbnail,
      );

      // Save to Hive
      await MMKVService.addVaultItem(vaultItem);

      // Update progress
      onProgress?.call(0.9);

      // Delete original file from gallery (pass the AssetEntity if available)
      await _deleteOriginalFile(sourceFile.path, originalAsset);

      // Update progress
      onProgress?.call(1.0);

      return vaultItem;
    } catch (e) {
      throw Exception('Failed to add file to vault: $e');
    }
  }

  /// Generate thumbnail for image files
  static Future<Uint8List?> _generateImageThumbnail(File imageFile) async {
    try {
      print('🖼️ Generating image thumbnail for: ${imageFile.path}');
      // Run heavy image processing in an isolate
      return await compute(_generateImageThumbnailTask, imageFile.path);
    } catch (e) {
      print('❌ Failed to generate image thumbnail: $e');
      return null;
    }
  }

  /// Generate thumbnail for video files
  static Future<Uint8List?> _generateVideoThumbnail(File videoFile) async {
    try {
      print('🎬 Generating video thumbnail for: ${videoFile.path}');

      // Extract thumbnail from video
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        maxHeight: 300,
        quality: 80,
      );

      if (thumbnail != null) {
        print('  ✅ Video thumbnail generated: ${thumbnail.length} bytes');
      } else {
        print('  ⚠️ Video thumbnail returned null');
      }

      return thumbnail;
    } catch (e) {
      print('❌ Failed to generate video thumbnail: $e');
      return null;
    }
  }

  /// Delete the original file from the gallery/storage
  /// Uses direct filesystem deletion (SILENT - no dialogs!)
  static Future<bool> _deleteOriginalFile(
    String filePath,
    AssetEntity? originalAsset,
  ) async {
    try {
      print('🗑️ Cleanup: Processing file: $filePath');
      final file = File(filePath);

      // SILENT DELETION: Delete the original file directly from filesystem
      // This works with MANAGE_EXTERNAL_STORAGE permission without any dialogs!
      if (originalAsset != null) {
        print('✅ Have original AssetEntity - deleting from filesystem');
        try {
          // Get the original file path from the asset
          final originalFile = await originalAsset.file;
          if (originalFile != null && await originalFile.exists()) {
            // Delete directly from filesystem (SILENT!)
            await originalFile.delete();
            print(
              '✅ Original file deleted silently from: ${originalFile.path}',
            );
            print('   Asset ID: ${originalAsset.id}');
            print('   Title: ${originalAsset.title}');
          } else {
            print('⚠️ Original file not found or already deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete original file: $e');
        }
      } else {
        print('ℹ️  No AssetEntity provided - skipping gallery deletion');
      }

      // Always delete the cache copy if it's different from original
      if (await file.exists()) {
        try {
          await file.delete();
          print('✅ Cache file deleted');
          return true;
        } catch (e) {
          print('⚠️ Failed to delete cache file: $e');
        }
      }

      return false;
    } catch (e) {
      print('❌ Error in deletion process: $e');
      return false;
    }
  }

  /// Parse string file type to FileType enum
  static FileType _parseFileType(String typeString) {
    switch (typeString) {
      case 'image':
        return FileType.image;
      case 'video':
        return FileType.video;
      case 'audio':
        return FileType.audio;
      case 'document':
        return FileType.document;
      default:
        return FileType.other;
    }
  }

  /// Delete a vault item and its encrypted file
  static Future<void> deleteVaultItem(VaultItem item) async {
    try {
      // Delete encrypted file
      final file = File(item.encryptedPath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from Hive
      await MMKVService.deleteVaultItem(item.id);
    } catch (e) {
      throw Exception('Failed to delete vault item: $e');
    }
  }

  /// Decrypt a vault item to a temporary location for viewing
  static Future<File> decryptVaultItem({
    required VaultItem item,
    required String masterPin,
    required Uint8List encryptionSalt,
  }) async {
    try {
      final encryptedFile = File(item.encryptedPath);

      if (!await encryptedFile.exists()) {
        throw Exception('Encrypted file not found');
      }

      // Get temp directory for decrypted files
      final tempDir = await FileManagerService.getTempDirectory();
      final decryptedFile = File('${tempDir.path}/${item.fileName}');

      // Decrypt file
      await EncryptionService.decryptFile(
        encryptedFile: encryptedFile,
        destinationFile: decryptedFile,
        pin: masterPin,
        salt: encryptionSalt,
      );

      return decryptedFile;
    } catch (e) {
      throw Exception('Failed to decrypt vault item: $e');
    }
  }
}

/// Arguments for encryption task
class _EncryptionTaskArgs {
  final String sourcePath;
  final String destinationPath;
  final String pin;
  final Uint8List salt;

  _EncryptionTaskArgs({
    required this.sourcePath,
    required this.destinationPath,
    required this.pin,
    required this.salt,
  });
}

/// Top-level function for encryption task
Future<void> _encryptFileTask(_EncryptionTaskArgs args) async {
  final sourceFile = File(args.sourcePath);
  final destinationFile = File(args.destinationPath);

  await EncryptionService.encryptFileStreaming(
    sourceFile: sourceFile,
    destinationFile: destinationFile,
    pin: args.pin,
    salt: args.salt,
  );
}

/// Top-level function for image thumbnail generation
Future<Uint8List?> _generateImageThumbnailTask(String path) async {
  try {
    final file = File(path);
    final bytes = await file.readAsBytes();

    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    // Resize to 300x300 thumbnail
    final thumbnail = img.copyResize(
      image,
      width: 300,
      height: 300,
      interpolation: img.Interpolation.average,
    );

    // Encode as JPEG with 80% quality
    return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));
  } catch (e) {
    print('Error in thumbnail isolate: $e');
    return null;
  }
}

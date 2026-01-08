import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
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
  /// 5. Delete original file from gallery
  static Future<VaultItem> addFileToVault({
    required File sourceFile,
    required String masterPin,
    required Uint8List encryptionSalt,
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

      // Encrypt file using streaming (prevents app blocking for large files)
      await EncryptionService.encryptFileStreaming(
        sourceFile: sourceFile,
        destinationFile: encryptedFile,
        pin: masterPin,
        salt: encryptionSalt,
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
      await HiveService.addVaultItem(vaultItem);

      // Update progress
      onProgress?.call(0.9);

      // Delete original file from gallery
      await _deleteOriginalFile(sourceFile.path);

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

      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      print('  ✓ Read ${bytes.length} bytes');

      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        print('  ❌ Failed to decode image');
        return null;
      }
      print('  ✓ Decoded image: ${image.width}x${image.height}');

      // Resize to 300x300 thumbnail
      final thumbnail = img.copyResize(
        image,
        width: 300,
        height: 300,
        interpolation: img.Interpolation.average,
      );
      print('  ✓ Resized to thumbnail');

      // Encode as JPEG with 80% quality
      final encoded = Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));
      print('  ✅ Thumbnail generated: ${encoded.length} bytes');
      return encoded;
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

  /// Delete original file from gallery using MediaStore
  /// This properly deletes files from Android gallery
  /// Delete original file from gallery
  /// Uses photo_manager to find and delete the actual gallery file
  static Future<bool> _deleteOriginalFile(String filePath) async {
    try {
      print('🗑️ Attempting to delete file from gallery: $filePath');

      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        print('ℹ️  File does not exist');
        return false;
      }

      // Get file info for matching
      final fileName = filePath.split('/').last;
      final fileSize = await file.length();

      print('📋 Looking for file: $fileName (size: $fileSize bytes)');

      // Try to find and delete from gallery using photo_manager
      if (Platform.isAndroid) {
        try {
          // Request permission
          final PermissionState ps =
              await PhotoManager.requestPermissionExtend();
          if (!ps.isAuth) {
            print('⚠️  Gallery permission denied');
            return false;
          }

          // Get all assets (limit to recent files for performance)
          final List<AssetPathEntity> paths =
              await PhotoManager.getAssetPathList(
                type: RequestType.image | RequestType.video,
              );

          // Search for matching file
          for (final path in paths) {
            final int totalCount = await path.assetCountAsync;
            final int checkCount = totalCount > 1000 ? 1000 : totalCount;

            final List<AssetEntity> assets = await path.getAssetListRange(
              start: 0,
              end: checkCount,
            );

            for (final asset in assets) {
              final assetFile = await asset.file;
              if (assetFile != null) {
                final assetSize = await assetFile.length();
                final assetName = assetFile.path.split('/').last;

                // Match by name and size
                if (assetName == fileName && assetSize == fileSize) {
                  print('✅ Found matching file: ${assetFile.path}');

                  // Try direct file deletion first (faster, no dialog)
                  try {
                    await File(assetFile.path).delete();
                    print('✅ File deleted directly from storage!');
                    return true;
                  } catch (e) {
                    print('⚠️ Direct delete failed: $e');

                    // Fallback: Use PhotoManager (shows system dialog)
                    try {
                      final List<String> result = await PhotoManager.editor
                          .deleteWithIds([asset.id]);

                      if (result.isNotEmpty) {
                        print('✅ File deleted via PhotoManager!');
                        return true;
                      }
                    } catch (e2) {
                      print('❌ PhotoManager delete also failed: $e2');
                    }
                  }

                  break;
                }
              }
            }
          }

          print('⚠️  File not found in gallery');
        } catch (e) {
          print('❌ Photo manager error: $e');
        }
      }

      // Fallback: delete cache file
      try {
        await file.delete();
        print('✅ Cache file deleted');
      } catch (e) {
        print('⚠️  Could not delete cache: $e');
      }

      return false;
    } catch (e) {
      print('❌ Error in _deleteOriginalFile: $e');
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
      await HiveService.deleteVaultItem(item.id);
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

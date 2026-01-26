import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/vault_item.dart';
import 'package:app_locker360/data/services/encryption_service.dart';
import 'package:app_locker360/data/services/file_manager_service.dart';
import 'package:app_locker360/data/services/vault_service.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_locker360/data/services/ad_helper.dart';

/// Vault page - shows encrypted files
class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  FileType _selectedType = FileType.image;
  bool _isLoading = false;

  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = AdHelper.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        print('Banner ad failed to load: $error');
        ad.dispose();
      },
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final vaultItems = MMKVService.getVaultItemsByType(_selectedType);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.vault,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _addFilesToVault,
          ),
        ],
      ),
      body: Column(
        children: [
          // File type selector
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(
                    FileType.image,
                    Icons.image_rounded,
                    l10n.images,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    FileType.video,
                    Icons.videocam_rounded,
                    l10n.videos,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    FileType.audio,
                    Icons.audiotrack_rounded,
                    l10n.audio,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    FileType.document,
                    Icons.description_rounded,
                    l10n.documents,
                  ),
                ],
              ),
            ),
          ),

          // Vault items
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF667EEA),
                      ),
                    ),
                  )
                : vaultItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noFilesInVault,
                          style: GoogleFonts.cairo(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tapToAddFiles,
                          style: GoogleFonts.cairo(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: vaultItems.length,
                    itemBuilder: (context, index) {
                      final item = vaultItems[index];
                      return _VaultItemCard(
                        item: item,
                        onDelete: () => _deleteVaultItem(item),
                      );
                    },
                  ),
          ),

          // Banner Ad at bottom
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              color: Theme.of(context).cardColor,
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(FileType type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isSelected
              ? null
              : Theme.of(context).dividerColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFilesToVault() async {
    try {
      // Check permissions
      final hasPermission = await FileManagerService.hasStoragePermission();
      if (!hasPermission) {
        final granted = await FileManagerService.requestStoragePermission();
        if (!granted) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            _showError(l10n.storagePermissionRequired);
          }
          return;
        }
      }

      // Show dialog to choose file type
      if (!mounted) return;
      final fileType = await _showFileTypeDialog();
      if (fileType == null) return;

      // Pick files based on type
      if (fileType == 'image') {
        // Use wechat_assets_picker for proper UI selection
        final List<AssetEntity>? selectedAssets = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: 10,
            requestType: RequestType.image,
            textDelegate: const EnglishAssetPickerTextDelegate(),
          ),
        );

        if (selectedAssets != null && selectedAssets.isNotEmpty) {
          // SILENT DELETION STRATEGY:
          // We pass the AssetEntity to vault_service, which will delete the
          // original file directly from the filesystem (no dialog needed!)

          setState(() => _isLoading = true);
          int successCount = 0;
          int failCount = 0;

          for (final asset in selectedAssets) {
            try {
              // Get the file from the asset
              final file = await asset.file;
              if (file != null) {
                // vault_service will handle silent deletion
                await _addSingleFileToVault(file, originalAsset: asset);
                successCount++;
              }
            } catch (e) {
              failCount++;
              print('Failed to add asset: $e');
            }
          }

          setState(() => _isLoading = false);

          if (mounted) {
            if (successCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تشفير $successCount ملف بنجاح' +
                        (failCount > 0 ? ' و فشل $failCount' : ''),
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: const Color(0xFF667EEA),
                ),
              );
            } else {
              _showError('فشل تشفير جميع الملفات');
            }
          }
        }
        return; // Early return for images
      } else if (fileType == 'video') {
        // Use wechat_assets_picker for videos too (silent deletion!)
        final List<AssetEntity>? selectedAssets = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: 5,
            requestType: RequestType.video,
            textDelegate: const EnglishAssetPickerTextDelegate(),
          ),
        );

        if (selectedAssets != null && selectedAssets.isNotEmpty) {
          // Same silent deletion strategy as images
          setState(() => _isLoading = true);
          int successCount = 0;
          int failCount = 0;

          for (final asset in selectedAssets) {
            try {
              // Get the file from the asset
              final file = await asset.file;
              if (file != null) {
                // vault_service will handle silent deletion
                await _addSingleFileToVault(file, originalAsset: asset);
                successCount++;
              }
            } catch (e) {
              failCount++;
              print('Failed to add video asset: $e');
            }
          }

          setState(() => _isLoading = false);

          if (mounted) {
            if (successCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تشفير $successCount فيديو بنجاح' +
                        (failCount > 0 ? ' و فشل $failCount' : ''),
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: const Color(0xFF667EEA),
                ),
              );
            } else {
              _showError('فشل تشفير جميع الفيديوهات');
            }
          }
        }
        return; // Early return for videos
      } else if (fileType == 'other') {
        // Use file_picker for any other file type (MP3, PDF, APK, DOCX, etc.)
        // Note: file_picker creates a cache copy, but we want to delete the ORIGINAL file too

        picker.FilePickerResult? result;
        try {
          result = await picker.FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: picker.FileType.any,
          );
        } catch (e) {
          print('⚠️ File picker error: $e');
          if (mounted) {
            _showError('فشل في اختيار الملفات. حاول مرة أخرى.');
          }
          return;
        }

        if (result != null && result.files.isNotEmpty) {
          setState(() => _isLoading = true);
          int successCount = 0;
          int failCount = 0;

          for (final platformFile in result.files) {
            try {
              // Skip files without a path (e.g., from cloud storage)
              if (platformFile.path == null) {
                print('⚠️ Skipping file without path: ${platformFile.name}');
                failCount++;
                continue;
              }

              final file = File(platformFile.path!);

              // Verify file exists before processing
              if (!await file.exists()) {
                print('⚠️ File does not exist: ${platformFile.path}');
                failCount++;
                continue;
              }

              // Try to find and delete the original file
              // file_picker gives us a cache copy, but we need to delete the original
              String? originalPath;

              // If the file is in cache, try to find the original
              if (platformFile.path!.contains('cache/file_picker')) {
                // The original file is likely in Downloads or Documents
                // We'll search common locations for a file with the same name and size
                final fileName = platformFile.name;
                final fileSize = await file.length();

                // Common document locations
                final searchPaths = [
                  '/storage/emulated/0/Download',
                  '/storage/emulated/0/Documents',
                  '/storage/emulated/0/Music',
                ];

                for (final searchPath in searchPaths) {
                  final possibleOriginal = File('$searchPath/$fileName');
                  if (await possibleOriginal.exists()) {
                    final originalSize = await possibleOriginal.length();
                    if (originalSize == fileSize) {
                      originalPath = possibleOriginal.path;
                      break;
                    }
                  }
                }
              }

              // Encrypt and vault the file
              await _addSingleFileToVault(file, originalAsset: null);

              // Delete the original file if we found it
              if (originalPath != null) {
                try {
                  await File(originalPath).delete();
                  print('✅ Deleted original file: $originalPath');
                } catch (e) {
                  print('⚠️ Failed to delete original file: $e');
                }
              }

              successCount++;
            } catch (e) {
              failCount++;
              print('Failed to add file: $e');
            }
          }

          setState(() => _isLoading = false);

          if (mounted) {
            if (successCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تشفير $successCount ملف بنجاح' +
                        (failCount > 0 ? ' و فشل $failCount' : ''),
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: const Color(0xFF667EEA),
                ),
              );
            } else {
              _showError('فشل تشفير جميع الملفات');
            }
          }
        }
        return; // Early return for other files
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('حدث خطأ: $e');
      }
    }
  }

  Future<void> _addSingleFileToVault(
    File file, {
    AssetEntity? originalAsset, // NEW: Optional asset for direct deletion
  }) async {
    // Get master PIN and salt
    final settings = MMKVService.getGlobalSettings();
    final masterPin = settings.masterPin;

    // Get or generate salt
    Uint8List salt;
    if (settings.encryptionSalt != null &&
        settings.encryptionSalt!.isNotEmpty) {
      salt = Uint8List.fromList(settings.encryptionSalt!);
    } else {
      salt = EncryptionService.generateSalt();
      final updatedSettings = settings.copyWith(encryptionSalt: salt);
      await MMKVService.updateGlobalSettings(updatedSettings);
    }

    // Use VaultService to add file to vault
    await VaultService.addFileToVault(
      sourceFile: file,
      originalAsset: originalAsset, // Pass the AssetEntity for direct deletion
      masterPin: masterPin,
      encryptionSalt: salt,
      onProgress: (progress) {
        // Optional: Update UI with progress
        print('Progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
    );
  }

  Future<String?> _showFileTypeDialog() async {
    final l10n = AppLocalizations.of(context)!;

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.chooseFileType,
          style: GoogleFonts.cairo(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.image_rounded,
                color: Color(0xFF667EEA),
              ),
              title: Text(
                l10n.images,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(
                Icons.videocam_rounded,
                color: Color(0xFF667EEA),
              ),
              title: Text(
                l10n.videos,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () => Navigator.pop(context, 'video'),
            ),
            ListTile(
              leading: const Icon(
                Icons.insert_drive_file_rounded,
                color: Color(0xFF667EEA),
              ),
              title: Text(
                l10n.otherFiles,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () => Navigator.pop(context, 'other'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVaultItem(VaultItem item) async {
    try {
      await VaultService.deleteVaultItem(item);

      setState(() {});

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileDeleted, style: GoogleFonts.cairo())),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showError('${l10n.fileDeleteFailed}: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

class _VaultItemCard extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onDelete;

  const _VaultItemCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Display thumbnail if available, otherwise show icon
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: item.thumbnail != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.memory(
                            item.thumbnail!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if thumbnail fails to load
                              return Center(
                                child: Icon(
                                  _getIconForType(item.fileType),
                                  size: 48,
                                  color: const Color(0xFF667EEA),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            _getIconForType(item.fileType),
                            size: 48,
                            color: const Color(0xFF667EEA),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName ?? 'ملف',
                  style: GoogleFonts.cairo(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.fileSizeFormatted,
                  style: GoogleFonts.cairo(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(FileType type) {
    switch (type) {
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.videocam_rounded;
      case FileType.audio:
        return Icons.audiotrack_rounded;
      case FileType.document:
        return Icons.description_rounded;
      case FileType.other:
        return Icons.insert_drive_file_rounded;
    }
  }
}

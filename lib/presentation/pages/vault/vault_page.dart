import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
import 'package:app_locker360/data/models/vault_item.dart';
import 'package:app_locker360/data/services/encryption_service.dart';
import 'package:app_locker360/data/services/file_manager_service.dart';
import 'package:app_locker360/data/services/vault_service.dart';

/// Vault page - shows encrypted files
class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  FileType _selectedType = FileType.image;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final vaultItems = HiveService.getVaultItemsByType(_selectedType);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        title: Text(
          'الخزنة',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: _addFilesToVault,
          ),
        ],
      ),
      body: Column(
        children: [
          // File type selector
          Container(
            color: const Color(0xFF1A1F3A),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(FileType.image, Icons.image_rounded, 'صور'),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    FileType.video,
                    Icons.videocam_rounded,
                    'فيديو',
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    FileType.audio,
                    Icons.audiotrack_rounded,
                    'صوت',
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    FileType.document,
                    Icons.description_rounded,
                    'مستندات',
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
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد ملفات في الخزنة',
                          style: GoogleFonts.cairo(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط على + لإضافة ملفات',
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.4),
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
          color: isSelected ? null : Colors.white.withOpacity(0.05),
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
                color: Colors.white,
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
            _showError('يجب منح صلاحية الوصول للملفات');
          }
          return;
        }
      }

      // Show dialog to choose file type
      if (!mounted) return;
      final fileType = await _showFileTypeDialog();
      if (fileType == null) return;

      List<File>? files;

      // Pick files based on type
      if (fileType == 'image') {
        files = await FileManagerService.pickImages(allowMultiple: true);
      } else if (fileType == 'video') {
        final video = await FileManagerService.pickVideo();
        if (video != null) {
          files = [video];
        }
      }

      if (files == null || files.isEmpty) return;

      // Show confirmation dialog
      if (mounted) {
        final confirmed = await _showConfirmationDialog(files.length);
        if (!confirmed) return;
      }

      // Process files
      setState(() => _isLoading = true);

      int successCount = 0;
      int failCount = 0;

      for (final file in files) {
        try {
          await _addSingleFileToVault(file);
          successCount++;
        } catch (e) {
          failCount++;
          print('Failed to add file ${file.path}: $e');
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
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('حدث خطأ: $e');
      }
    }
  }

  Future<void> _addSingleFileToVault(File file) async {
    // Get master PIN and salt
    final settings = HiveService.getGlobalSettings();
    final masterPin = settings.masterPin;

    // Get or generate salt
    Uint8List salt;
    if (settings.encryptionSalt != null &&
        settings.encryptionSalt!.isNotEmpty) {
      salt = Uint8List.fromList(settings.encryptionSalt!);
    } else {
      salt = EncryptionService.generateSalt();
      final updatedSettings = settings.copyWith(encryptionSalt: salt);
      await HiveService.updateGlobalSettings(updatedSettings);
    }

    // Use VaultService to add file to vault
    await VaultService.addFileToVault(
      sourceFile: file,
      masterPin: masterPin,
      encryptionSalt: salt,
      onProgress: (progress) {
        // Optional: Update UI with progress
        print('Progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
    );
  }

  Future<String?> _showFileTypeDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'اختر نوع الملف',
          style: GoogleFonts.cairo(
            color: Colors.white,
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
              title: Text('صور', style: GoogleFonts.cairo(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(
                Icons.videocam_rounded,
                color: Color(0xFF667EEA),
              ),
              title: Text(
                'فيديو',
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(int fileCount) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'تأكيد التشفير',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'سيتم تشفير $fileCount ملف وحذف النسخة الأصلية.\nهل تريد المتابعة؟',
              style: GoogleFonts.cairo(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(color: Colors.white60),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                ),
                child: Text(
                  'تشفير',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteVaultItem(VaultItem item) async {
    try {
      await VaultService.deleteVaultItem(item);

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الملف', style: GoogleFonts.cairo())),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('فشل حذف الملف: $e');
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
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.fileSizeFormatted,
                  style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
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

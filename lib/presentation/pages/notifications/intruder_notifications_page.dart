import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/core/services/intruder_detection_service.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// صفحة إشعارات المتطفلين - عرض جميع الصور الملتقطة
class IntruderNotificationsPage extends StatefulWidget {
  const IntruderNotificationsPage({super.key});

  @override
  State<IntruderNotificationsPage> createState() =>
      _IntruderNotificationsPageState();
}

class _IntruderNotificationsPageState extends State<IntruderNotificationsPage> {
  List<File> _intruderPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    final photos = await IntruderDetectionService.getIntruderPhotos();
    setState(() {
      _intruderPhotos = photos;
      _isLoading = false;
    });
  }

  Future<void> _deletePhoto(File photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Photo?',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this intruder photo?',
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.cairo(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
            ),
            child: Text('Delete', style: GoogleFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await IntruderDetectionService.deleteIntruderPhoto(
        photo.path,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo deleted', style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
        _loadPhotos();
      }
    }
  }

  Future<void> _clearAllPhotos() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Photos?',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete all intruder photos? This cannot be undone.',
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.cairo(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await IntruderDetectionService.clearAllIntruderPhotos();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All photos cleared', style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
        _loadPhotos();
      }
    }
  }

  void _viewPhotoFullScreen(File photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenPhotoViewer(photo: photo),
      ),
    );
  }

  String _formatTimestamp(String filename) {
    try {
      // Extract timestamp from filename: intruder_2026-01-22T20-15-30.123456.jpg
      final parts = filename.replaceAll('intruder_', '').replaceAll('.jpg', '');
      final timestamp = parts.replaceAll('-', ':').substring(0, 19);
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return filename;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        title: Text(
          'Intruder Photos',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_intruderPhotos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: _clearAllPhotos,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF667EEA)),
            )
          : _intruderPhotos.isEmpty
          ? _buildEmptyState()
          : _buildPhotosList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Intruder Photos',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photos will appear here when someone\nenters wrong PIN 3 times',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _intruderPhotos.length,
      itemBuilder: (context, index) {
        final photo = _intruderPhotos[index];
        final filename = photo.path.split('/').last;
        final timestamp = _formatTimestamp(filename);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                photo,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                ),
              ),
            ),
            title: Text(
              'Intruder Detected',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        timestamp,
                        style: GoogleFonts.cairo(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deletePhoto(photo),
              tooltip: 'Delete',
            ),
            onTap: () => _viewPhotoFullScreen(photo),
          ),
        );
      },
    );
  }
}

/// Full screen photo viewer
class _FullScreenPhotoViewer extends StatelessWidget {
  final File photo;

  const _FullScreenPhotoViewer({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            photo,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 100, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Utility class to generate and save backup PIN as an image
class BackupPinImageGenerator {
  /// Generate and save backup PIN image to gallery
  /// Returns true if successful, false otherwise
  static Future<bool> saveToGallery(String backupPin, String appTitle) async {
    try {
      // Request storage permission
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        return false;
      }

      // Generate the image
      final imageBytes = await _generateImage(backupPin, appTitle);

      // Save to temporary file first
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/backup_pin_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(imageBytes);

      // Save to gallery using gal package
      await Gal.putImage(tempFile.path);

      // Clean up temp file
      await tempFile.delete();

      return true;
    } catch (e) {
      print('Error saving backup PIN image: $e');
      return false;
    }
  }

  /// Generate backup PIN image as bytes
  static Future<Uint8List> _generateImage(
    String backupPin,
    String appTitle,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1080, 1920);

    // Background gradient
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A0E21), Color(0xFF1a2332)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw app icon/logo background
    final iconPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      ).createShader(const Rect.fromLTWH(390, 300, 300, 300));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(390, 300, 300, 300),
        const Radius.circular(60),
      ),
      iconPaint,
    );

    // Draw lock icon
    final lockIconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Lock body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(490, 450, 100, 100),
        const Radius.circular(10),
      ),
      lockIconPaint,
    );

    // Lock shackle
    final shacklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    canvas.drawArc(
      const Rect.fromLTWH(510, 400, 60, 80),
      3.14159, // π (180 degrees)
      3.14159, // π (180 degrees)
      false,
      shacklePaint,
    );

    // Draw app title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: appTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset((size.width - titlePainter.width) / 2, 700),
    );

    // Draw "Backup PIN" label
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'Backup PIN',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 40,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset((size.width - labelPainter.width) / 2, 850),
    );

    // Draw backup PIN with gradient background
    final pinBoxPaint = Paint()..color = Colors.white.withOpacity(0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(240, 950, 600, 150),
        const Radius.circular(20),
      ),
      pinBoxPaint,
    );

    final pinPainter = TextPainter(
      text: TextSpan(
        text: backupPin,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 70,
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pinPainter.layout();
    pinPainter.paint(canvas, Offset((size.width - pinPainter.width) / 2, 985));

    // Draw warning text
    final warningPainter = TextPainter(
      text: const TextSpan(
        text: '⚠️ Keep this PIN safe and secure',
        style: TextStyle(
          color: Color(0xFFF5576C),
          fontSize: 35,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    warningPainter.layout();
    warningPainter.paint(
      canvas,
      Offset((size.width - warningPainter.width) / 2, 1200),
    );

    // Draw description
    final descPainter = TextPainter(
      text: const TextSpan(
        text: 'Use this PIN to recover access\nif you forget your main PIN',
        style: TextStyle(color: Colors.white60, fontSize: 32, height: 1.5),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    descPainter.layout(maxWidth: 900);
    descPainter.paint(
      canvas,
      Offset((size.width - descPainter.width) / 2, 1300),
    );

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}

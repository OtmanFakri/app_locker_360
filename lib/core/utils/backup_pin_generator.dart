import 'dart:math';

/// Utility class to generate secure backup PINs
/// Format: XXX-XXX-XXX (e.g., X7d-9P2-mQ4)
class BackupPinGenerator {
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
  static final Random _random = Random.secure();

  /// Generate a backup PIN in format XXX-XXX-XXX
  /// Each segment contains 3 alphanumeric characters
  static String generate() {
    final segment1 = _generateSegment();
    final segment2 = _generateSegment();
    final segment3 = _generateSegment();

    return '$segment1-$segment2-$segment3';
  }

  /// Generate a single 3-character segment
  static String _generateSegment() {
    final buffer = StringBuffer();
    for (int i = 0; i < 3; i++) {
      buffer.write(_chars[_random.nextInt(_chars.length)]);
    }
    return buffer.toString();
  }

  /// Validate if a string matches the backup PIN format
  static bool isValidFormat(String pin) {
    final regex = RegExp(r'^[A-Za-z0-9]{3}-[A-Za-z0-9]{3}-[A-Za-z0-9]{3}$');
    return regex.hasMatch(pin);
  }
}

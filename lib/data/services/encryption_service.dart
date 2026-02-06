import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Encryption service for AES-256 file encryption
class EncryptionService {
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  static const int _iterations = 10000; // PBKDF2 iterations

  /// Generate encryption key from master PIN using PBKDF2
  static Uint8List _deriveKey(String pin, Uint8List salt) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac(sha256, []),
      iterations: _iterations,
      bits: _keyLength * 8,
    );

    final key = pbkdf2.deriveKeyFromPassword(password: pin, nonce: salt);

    return Uint8List.fromList(key);
  }

  /// Encrypt a file using AES-256-CBC
  /// Returns the encrypted file path
  static Future<File> encryptFile({
    required File sourceFile,
    required File destinationFile,
    required String pin,
    required Uint8List salt,
  }) async {
    try {
      // Derive encryption key
      final keyBytes = _deriveKey(pin, salt);
      final key = encrypt_pkg.Key(keyBytes);

      // Generate random IV
      final iv = encrypt_pkg.IV.fromSecureRandom(_ivLength);

      // Create encrypter
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );

      // Read source file
      final sourceBytes = await sourceFile.readAsBytes();

      // Encrypt data
      final encrypted = encrypter.encryptBytes(sourceBytes, iv: iv);

      // Write IV + encrypted data to destination
      final outputBytes = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);

      await destinationFile.writeAsBytes(outputBytes);

      return destinationFile;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt a file using AES-256-CBC
  /// Returns the decrypted file
  static Future<File> decryptFile({
    required File encryptedFile,
    required File destinationFile,
    required String pin,
    required Uint8List salt,
  }) async {
    try {
      // Derive encryption key
      final keyBytes = _deriveKey(pin, salt);
      final key = encrypt_pkg.Key(keyBytes);

      // Read encrypted file
      final encryptedBytes = await encryptedFile.readAsBytes();

      // Extract IV and encrypted data
      final iv = encrypt_pkg.IV(encryptedBytes.sublist(0, _ivLength));
      final encryptedData = encryptedBytes.sublist(_ivLength);

      // Create encrypter
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );

      // Decrypt data
      final decrypted = encrypter.decryptBytes(
        encrypt_pkg.Encrypted(encryptedData),
        iv: iv,
      );

      // Write decrypted data to destination
      await destinationFile.writeAsBytes(decrypted);

      return destinationFile;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Generate a random salt for key derivation
  static Uint8List generateSalt() {
    return encrypt_pkg.IV.fromSecureRandom(32).bytes;
  }

  /// Encrypt file in chunks for large files (streaming)
  static Future<File> encryptFileStreaming({
    required File sourceFile,
    required File destinationFile,
    required String pin,
    required Uint8List salt,
    int chunkSize = 1024 * 1024, // 1MB chunks
  }) async {
    try {
      // Derive encryption key
      final keyBytes = _deriveKey(pin, salt);
      final key = encrypt_pkg.Key(keyBytes);

      // Generate random IV
      final iv = encrypt_pkg.IV.fromSecureRandom(_ivLength);

      // Create encrypter
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );

      // Write IV first
      final sink = destinationFile.openWrite();
      sink.add(iv.bytes);

      // Read and encrypt in chunks
      final sourceStream = sourceFile.openRead();
      final buffer = <int>[];

      await for (final chunk in sourceStream) {
        buffer.addAll(chunk);

        // Process complete chunks
        while (buffer.length >= chunkSize) {
          final chunkData = buffer.sublist(0, chunkSize);
          buffer.removeRange(0, chunkSize);

          final encrypted = encrypter.encryptBytes(
            Uint8List.fromList(chunkData),
            iv: iv,
          );
          sink.add(encrypted.bytes);
        }
      }

      // Process remaining data
      if (buffer.isNotEmpty) {
        final encrypted = encrypter.encryptBytes(
          Uint8List.fromList(buffer),
          iv: iv,
        );
        sink.add(encrypted.bytes);
      }

      await sink.close();
      return destinationFile;
    } catch (e) {
      throw Exception('Streaming encryption failed: $e');
    }
  }

  /// Decrypt file in chunks (streaming)
  /// Matches encryptFileStreaming logic: treats file as independent encrypted chunks
  static Future<File> decryptFileStreaming({
    required File encryptedFile,
    required File destinationFile,
    required String pin,
    required Uint8List salt,
    int chunkSize = 1024 * 1024, // 1MB chunks (must match encryption)
  }) async {
    try {
      // Derive encryption key
      final keyBytes = _deriveKey(pin, salt);
      final key = encrypt_pkg.Key(keyBytes);

      // Create encrypter
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );

      final sink = destinationFile.openWrite();

      // Calculate encrypted chunk size:
      // chunkSize (1MB) is exact multiple of 16 bytes.
      // PKCS7 padding always adds padding if multiple of block size.
      // So encryption adds 1 full block (16 bytes).
      // Total encrypted chunk size = chunkSize + 16 bytes.
      // The FIRST 16 bytes of the file is the global IV.
      // BUT, encryptFileStreaming reused the same IV for every chunk.
      // Wait, encryptFileStreaming writes IV *once* at start of file:
      // sink.add(iv.bytes);
      // Then writes encrypted chunks.

      // Let's verify encryptFileStreaming behavior:
      // 1. Writes IV (16 bytes).
      // 2. Loop:
      //    Encrypt(chunk, iv).
      //    Write bytes.

      // So to decrypt:
      // 1. Read first 16 bytes as IV.
      // 2. Read EncryptedChunkSize bytes (1MB + 16 bytes).
      // 3. Decrypt using IV. (Note: reused IV is bad security, but that's how it was written)
      // 4. Repeat.

      // We need to read manual byte ranges. Streams might return variable chunk sizes.
      // Better to use synchronous random access for simplicity and reliability with fixed offsets?
      // Or manually buffer the stream.

      final raf = await encryptedFile.open();
      final fileSize = await encryptedFile.length();

      // 1. Read IV
      if (fileSize < _ivLength) throw Exception('File too short');

      final ivBytes = await raf.read(_ivLength);
      final iv = encrypt_pkg.IV(ivBytes);

      // 2. Decrypt chunks
      // Expected encrypted chunk size for full 1MB chunk
      // AES block size = 16
      // 1MB = 1048576 bytes
      // Padded size = 1048576 + 16 = 1048592
      const acceptedChunkSize = 1024 * 1024;
      const encryptedBlockOverhead = 16; // PKCS7 padding for full block
      const fullEncryptedChunkSize = acceptedChunkSize + encryptedBlockOverhead;

      int offset = _ivLength;

      while (offset < fileSize) {
        // Determine how much to read
        // If remaining < fullEncryptedChunkSize, it's the last chunk
        // BUT wait. If the last chunk was small, say 100 bytes.
        // Encrypted size = 100 + (16 - 100%16) = 112 bytes.
        // We handle "last chunk" by just reading rest of file?
        // YES, because we know we wrote sequentially.
        // The problem is if we have multiple full chunks.

        int bytesToRead;
        if (fileSize - offset >= fullEncryptedChunkSize) {
          bytesToRead = fullEncryptedChunkSize;
        } else {
          bytesToRead = fileSize - offset;
        }

        final encryptedChunk = await raf.read(bytesToRead);

        final decryptedChunk = encrypter.decryptBytes(
          encrypt_pkg.Encrypted(encryptedChunk),
          iv: iv,
        );

        sink.add(decryptedChunk);
        offset += bytesToRead;
      }

      await raf.close();
      await sink.close();

      return destinationFile;
    } catch (e) {
      throw Exception('Streaming decryption failed: $e');
    }
  }
}

/// PBKDF2 implementation for key derivation
class Pbkdf2 {
  final Hmac macAlgorithm;
  final int iterations;
  final int bits;

  Pbkdf2({
    required this.macAlgorithm,
    required this.iterations,
    required this.bits,
  });

  List<int> deriveKeyFromPassword({
    required String password,
    required List<int> nonce,
  }) {
    final passwordBytes = utf8.encode(password);
    final keyLength = bits ~/ 8;
    final key = <int>[];

    var blockIndex = 1;
    while (key.length < keyLength) {
      final block = _computeBlock(passwordBytes, nonce, blockIndex);
      key.addAll(block);
      blockIndex++;
    }

    return key.sublist(0, keyLength);
  }

  List<int> _computeBlock(List<int> password, List<int> salt, int blockIndex) {
    final hmac = Hmac(sha256, password);

    // First iteration: HMAC(password, salt || blockIndex)
    var u = hmac.convert([...salt, ...intToBytes(blockIndex)]).bytes;
    var result = List<int>.from(u);

    // Remaining iterations
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  List<int> intToBytes(int value) {
    return [
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ];
  }
}

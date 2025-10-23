import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class RealAesService {
  static const int keyLength = 32; // 256 bits
  static const int ivLength = 12; // 96 bits for GCM

  /// Generate a cryptographically secure random AES key
  static String generateAesKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(keyLength, (i) => random.nextInt(256));
    return base64Encode(keyBytes);
  }

  /// Generate a cryptographically secure random IV
  static String generateIV() {
    final random = Random.secure();
    final ivBytes = List<int>.generate(ivLength, (i) => random.nextInt(256));
    return base64Encode(ivBytes);
  }

  /// Encrypt file data using AES-256-GCM (real encryption)
  static EncryptedFileData encryptFile(Uint8List fileData, String aesKey) {
    try {
      // Create key and IV
      final key = Key.fromBase64(aesKey);
      final iv = IV.fromBase64(generateIV());
      
      // Create encrypter with AES-256-GCM
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      
      // Encrypt the file data
      final encrypted = encrypter.encryptBytes(fileData, iv: iv);
      
      // Calculate SHA-256 hash for integrity verification
      final fileHash = sha256.convert(fileData).toString();
      
      return EncryptedFileData(
        encryptedData: encrypted.bytes,
        iv: iv.base64,
        key: aesKey,
        hash: fileHash,
        authTag: encrypted.bytes.sublist(encrypted.bytes.length - 16), // GCM auth tag
      );
    } catch (e) {
      throw Exception('Real AES encryption failed: $e');
    }
  }

  /// Decrypt file data using AES-256-GCM (real decryption)
  static Uint8List decryptFile(EncryptedFileData encryptedData) {
    try {
      // Create key and IV
      final key = Key.fromBase64(encryptedData.key);
      final iv = IV.fromBase64(encryptedData.iv);
      
      // Create encrypter with AES-256-GCM
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      
      // Decrypt the file data
      final encrypted = Encrypted(Uint8List.fromList(encryptedData.encryptedData));
      final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
      
      // Verify integrity using SHA-256
      final decryptedHash = sha256.convert(decrypted).toString();
      if (decryptedHash != encryptedData.hash) {
        throw Exception('File integrity check failed - file may be corrupted');
      }
      
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw Exception('Real AES decryption failed: $e');
    }
  }

  /// Verify file integrity using SHA-256
  static bool verifyFileIntegrity(Uint8List fileData, String expectedHash) {
    final actualHash = sha256.convert(fileData).toString();
    return actualHash == expectedHash;
  }

  /// Generate a secure random salt for key derivation
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
}

/// Data class to hold encrypted file information
class EncryptedFileData {
  final List<int> encryptedData;
  final String iv;
  final String key;
  final String hash;
  final List<int> authTag;

  EncryptedFileData({
    required this.encryptedData,
    required this.iv,
    required this.key,
    required this.hash,
    required this.authTag,
  });

  Map<String, dynamic> toJson() {
    return {
      'encryptedData': base64Encode(encryptedData),
      'iv': iv,
      'key': key,
      'hash': hash,
      'authTag': base64Encode(authTag),
    };
  }

  factory EncryptedFileData.fromJson(Map<String, dynamic> json) {
    return EncryptedFileData(
      encryptedData: base64Decode(json['encryptedData']),
      iv: json['iv'],
      key: json['key'],
      hash: json['hash'],
      authTag: base64Decode(json['authTag']),
    );
  }
}

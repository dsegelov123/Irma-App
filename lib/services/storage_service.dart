import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service managing the encrypted Hive database storage and security credentials.
class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'irma_encryption_key';
  
  static List<int>? _encryptionKey;

  static Box? _settingsBox;

  /// Retrieves the active encryption key in memory.
  static List<int>? get encryptionKey => _encryptionKey;

  /// Retrieves the opened settings box.
  static Box get settingsBox => _settingsBox!;

  /// Initializes the local database sandbox and loads/generates the AES key.
  static Future<void> init() async {
    await Hive.initFlutter();
    await loadOrGenerateKey();
    _settingsBox = await openEncryptedBox('irma_settings');
  }

  /// Loads the AES encryption key from secure storage, generating a new one if not present.
  static Future<void> loadOrGenerateKey() async {
    final keyString = await _secureStorage.read(key: _keyName);
    if (keyString == null) {
      // Hive.generateSecureKey() produces a cryptographically secure 512-bit (64 bytes) key.
      final newKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _keyName,
        value: base64UrlEncode(newKey),
      );
      _encryptionKey = newKey;
    } else {
      _encryptionKey = base64Url.decode(keyString);
    }
  }

  /// Opens a cryptographically secure Hive box using AES-256 encryption.
  static Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    if (_encryptionKey == null) {
      throw StateError('Encryption key is not loaded in memory.');
    }
    return await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(_encryptionKey!),
    );
  }

  /// Deletes the encryption key from in-memory cache to prevent cold boot extraction.
  static void wipeKeyFromMemory() {
    _encryptionKey = null;
  }

  /// Deletes all local database records and secure credentials permanently.
  static Future<void> purgeAllData() async {
    // Wipe memory
    wipeKeyFromMemory();
    _settingsBox = null;
    
    // Clear all files from disk
    await Hive.deleteFromDisk();
    
    // Clear secure keychain/keystore records
    await _secureStorage.deleteAll();
  }
}

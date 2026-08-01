// lib/utils/secure_storage_helper.dart
import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class SecureStorageHelper {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      preferencesKeyPrefix: 'secure_app_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked,
    ),
  );

  // Ensure AES key exists once
  static Future<String> _ensureAesKey() async {
    String? key = await _storage.read(key: 'aesKey');
    if (key == null) {
      final rand = Random.secure();
      final values = List<int>.generate(32, (_) => rand.nextInt(256));
      key = base64UrlEncode(values);
      await _storage.write(key: 'aesKey', value: key);
    }
    return key;
  }

  // Encrypt a value
  static Future<Map<String, String>> encryptValue(String plainText) async {
    final base64Key = await _ensureAesKey();
    final key = encrypt.Key(base64Decode(base64Key));
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    /*debugPrint("BAHU AUTH ENCRYPT");
    debugPrint(plainText);
    debugPrint(encrypted.base64);*/
    return {
      'cipherText': encrypted.base64,
      'iv': base64Encode(iv.bytes),
    };
  }

  // Decrypt a value
  static Future<String?> decryptValue(String? cipherText, String? base64Iv) async {
    if (cipherText == null || base64Iv == null) return null;
    final base64Key = await _ensureAesKey();
    final key = encrypt.Key(base64Decode(base64Key));
    final iv = encrypt.IV(base64Decode(base64Iv));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt64(cipherText, iv: iv);
  }

  // Save encrypted value
  static Future<void> saveEncrypted(String key, String value) async {
    final enc = await encryptValue(value);
    await _storage.write(key: "${key}_cipher", value: enc['cipherText']);
    await _storage.write(key: "${key}_iv", value: enc['iv']);
  }

  // Read and decrypt value
  static Future<String?> readDecrypted(String key) async {
    final cipher = await _storage.read(key: "${key}_cipher");
    final iv = await _storage.read(key: "${key}_iv");
    return await decryptValue(cipher, iv);
  }

  // Delete stored value
  static Future<void> delete(String key) async {
    await _storage.delete(key: "${key}_cipher");
    await _storage.delete(key: "${key}_iv");
  }
  //
  static Future<void> saveRefreshToken(String refreshToken) async => saveEncrypted("refresh_token", refreshToken);
  static Future<String?> readRefreshToken() async => readDecrypted("refresh_token");
  // Clear all
  static Future<void> clearAll() async => _storage.deleteAll();
}
///
Future<bool> isEmulator() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  // Common emulator indicators
  return androidInfo.isPhysicalDevice == false ||
      androidInfo.brand.toLowerCase() == 'generic' ||
      androidInfo.device.toLowerCase().contains('emulator');
}
//
Future<bool> isRooted() async {
  return await false;//FlutterJailbreakDetection.jailbroken;
}

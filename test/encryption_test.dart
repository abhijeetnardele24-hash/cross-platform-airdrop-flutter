import 'package:flutter_test/flutter_test.dart';
import 'package:cross_platform_airdrop/utils/encryption_utils.dart';
import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart' as pc;

void main() {
  group('EncryptionUtils Tests', () {
    test('AES-GCM encryption/decryption roundtrip', () {
      final sharedSecret = Uint8List.fromList(List.generate(32, (i) => i));
      final key = EncryptionUtils.deriveAESKey(sharedSecret);
      final data = Uint8List.fromList('Hello, World!'.codeUnits);

      final encrypted = EncryptionUtils.encryptBytes(data, key);
      final decrypted = EncryptionUtils.decryptBytes(encrypted, key);

      expect(decrypted, equals(data));
    });

    test('ECDH key exchange', () {
      final keyPair1 = EncryptionUtils.generateECDHKeyPair();
      final keyPair2 = EncryptionUtils.generateECDHKeyPair();

      final sharedSecret1 = EncryptionUtils.deriveSharedSecret(
        keyPair1.privateKey as pc.ECPrivateKey,
        keyPair2.publicKey as pc.ECPublicKey,
      );

      final sharedSecret2 = EncryptionUtils.deriveSharedSecret(
        keyPair2.privateKey as pc.ECPrivateKey,
        keyPair1.publicKey as pc.ECPublicKey,
      );

      expect(sharedSecret1, equals(sharedSecret2));
    });

    test('SHA-256 checksum', () {
      final data = Uint8List.fromList('test data'.codeUnits);
      final checksum = EncryptionUtils.computeChecksum(data);

      expect(checksum.length, equals(64)); // SHA-256 hex length
    });

    test('Device fingerprint generation', () {
      final fingerprint = EncryptionUtils.generateDeviceFingerprint(
        deviceId: '12345',
        deviceName: 'TestDevice',
        deviceModel: 'Pixel 5',
        osVersion: 'Android 12',
        platform: 'Android',
      );

      expect(fingerprint.length, equals(64)); // SHA-256 hex length
    });
  });
}

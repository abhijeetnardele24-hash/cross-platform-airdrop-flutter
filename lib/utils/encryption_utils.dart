import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/pointycastle.dart' as pc;
import 'package:pointycastle/export.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionUtils {
  static const int aesKeyLength = 32; // 256 bits
  static const int ivLength = 16; // 128 bits for GCM
  static const int saltLength = 16;

  // Generate ECDH key pair
  static AsymmetricKeyPair<PublicKey, PrivateKey> generateECDHKeyPair() {
    final secureRandom = pc.SecureRandom('Fortuna')
      ..seed(pc.KeyParameter(Uint8List.fromList(
          List.generate(32, (i) => Random.secure().nextInt(256)))));
    final keyGen = ECKeyGenerator()
      ..init(pc.ParametersWithRandom(
          ECKeyGeneratorParameters(ECCurve_secp256r1()), secureRandom));
    return keyGen.generateKeyPair();
  }

  // Derive shared secret from private key and peer's public key
  static Uint8List deriveSharedSecret(
      ECPrivateKey privateKey, ECPublicKey publicKey) {
    final agreement = ECDHBasicAgreement()..init(privateKey);
    final sharedSecretBigInt = agreement.calculateAgreement(publicKey);
    // Convert BigInt to bytes (pad to 32 bytes for secp256r1)
    final sharedSecretBytes = bigIntToBytes(sharedSecretBigInt, 32);
    return sharedSecretBytes;
  }

  // Helper to convert BigInt to bytes
  static Uint8List bigIntToBytes(BigInt bigInt, int length) {
    final byteData = ByteData(length);
    var value = bigInt;
    for (int i = length - 1; i >= 0; i--) {
      byteData.setUint8(i, value.toUnsigned(8).toInt());
      value = value >> 8;
    }
    return byteData.buffer.asUint8List();
  }

  // Derive AES key from shared secret using PBKDF2
  static encrypt.Key deriveAESKey(Uint8List sharedSecret,
      {String info = 'encryption'}) {
    final salt = utf8.encode('encryption_salt'); // Fixed salt for consistency
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(
          salt, 10000, aesKeyLength)); // Higher iterations for security
    final keyBytes = pbkdf2.process(sharedSecret);
    return encrypt.Key(keyBytes);
  }

  // Encrypt bytes with AES-GCM
  static Uint8List encryptBytes(Uint8List data, encrypt.Key key,
      {Uint8List? iv}) {
    iv ??= Uint8List.fromList(
        List.generate(ivLength, (i) => Random.secure().nextInt(256)));
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    final encrypted = encrypter.encryptBytes(data, iv: encrypt.IV(iv));
    // Prepend IV to encrypted data for decryption
    return Uint8List.fromList(iv + encrypted.bytes);
  }

  // Decrypt bytes with AES-GCM
  static Uint8List decryptBytes(Uint8List encryptedData, encrypt.Key key) {
    final iv = encryptedData.sublist(0, ivLength);
    final data = encryptedData.sublist(ivLength);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    final decrypted =
        encrypter.decryptBytes(encrypt.Encrypted(data), iv: encrypt.IV(iv));
    return Uint8List.fromList(decrypted);
  }

  // Legacy methods for backward compatibility (deprecated)
  static encrypt.Key deriveKey(String sessionCode) {
    final salt = utf8.encode('fixed_salt'); // Insecure, but for legacy
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, 1000, aesKeyLength));
    final keyBytes = pbkdf2.process(utf8.encode(sessionCode));
    return encrypt.Key(keyBytes);
  }

  static Uint8List encryptBytesLegacy(Uint8List data, String sessionCode) {
    final key = deriveKey(sessionCode);
    final iv = encrypt.IV.fromLength(ivLength);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    return encrypted.bytes;
  }

  static Uint8List decryptBytesLegacy(
      Uint8List encryptedData, String sessionCode) {
    final key = deriveKey(sessionCode);
    final iv = encrypt.IV.fromLength(ivLength);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedData), iv: iv);
    return Uint8List.fromList(decrypted);
  }

  // Compute SHA-256 checksum
  static String computeChecksum(Uint8List data) {
    return sha256.convert(data).toString();
  }

  // Verify checksum
  static bool verifyChecksum(Uint8List data, String expectedChecksum) {
    return computeChecksum(data) == expectedChecksum;
  }

  // Generate device fingerprint from device info
  static String generateDeviceFingerprint({
    required String deviceId,
    required String deviceName,
    required String deviceModel,
    required String osVersion,
    required String platform,
  }) {
    final infoString =
        '$deviceId|$deviceName|$deviceModel|$osVersion|$platform';
    return computeChecksum(utf8.encode(infoString));
  }

  // Stream encryption utilities for large files
  static const int chunkSize = 64 * 1024; // 64KB chunks for streaming

  // Encrypt stream of data with AES-GCM
  static Stream<Uint8List> encryptStream(
      Stream<Uint8List> dataStream, encrypt.Key key) {
    return dataStream.transform(_StreamEncryptor(key));
  }

  // Decrypt stream of data with AES-GCM
  static Stream<Uint8List> decryptStream(
      Stream<Uint8List> encryptedStream, encrypt.Key key) {
    return encryptedStream.transform(_StreamDecryptor(key));
  }

  // Nonce/IV management for GCM
  static final Map<String, Uint8List> _nonceCache = {};

  static Uint8List generateNonce(String sessionId) {
    if (_nonceCache.containsKey(sessionId)) {
      // Increment nonce for this session
      final currentNonce = _nonceCache[sessionId]!;
      final newNonce = Uint8List.fromList(currentNonce);
      for (int i = newNonce.length - 1; i >= 0; i--) {
        if (newNonce[i] < 255) {
          newNonce[i]++;
          break;
        } else {
          newNonce[i] = 0;
        }
      }
      _nonceCache[sessionId] = newNonce;
      return newNonce;
    } else {
      // Generate initial nonce
      final nonce = Uint8List.fromList(
          List.generate(ivLength, (i) => Random.secure().nextInt(256)));
      _nonceCache[sessionId] = nonce;
      return nonce;
    }
  }

  static void clearNonceCache(String sessionId) {
    _nonceCache.remove(sessionId);
  }

  // Secure random bytes generation
  static Uint8List generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(length, (i) => random.nextInt(256)));
  }

  // Key rotation utilities
  static encrypt.Key rotateKey(encrypt.Key oldKey, String rotationInfo) {
    final combined = oldKey.bytes + utf8.encode(rotationInfo);
    final hash = sha256.convert(combined);
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }
}

// Stream encryption transformer
class _StreamEncryptor implements StreamTransformer<Uint8List, Uint8List> {
  final encrypt.Key _key;
  bool _isFirstChunk = true;
  late encrypt.IV _iv;

  _StreamEncryptor(this._key) {
    _iv = encrypt.IV.fromSecureRandom(EncryptionUtils.ivLength);
  }

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) async* {
    await for (final chunk in stream) {
      if (_isFirstChunk) {
        // Send IV first
        yield _iv.bytes;
        _isFirstChunk = false;
      }

      final encrypter =
          encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.gcm));
      final encrypted = encrypter.encryptBytes(chunk, iv: _iv);
      yield encrypted.bytes;

      // Update IV for next chunk (GCM nonce increment)
      _iv =
          encrypt.IV(Uint8List.fromList(_iv.bytes.map((b) => b + 1).toList()));
    }
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom<Uint8List, Uint8List, RS, RT>(this);
  }
}

// Stream decryption transformer
class _StreamDecryptor implements StreamTransformer<Uint8List, Uint8List> {
  final encrypt.Key _key;
  bool _isFirstChunk = true;
  late encrypt.IV _iv;

  _StreamDecryptor(this._key);

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) async* {
    await for (final chunk in stream) {
      if (_isFirstChunk) {
        // First chunk is the IV
        _iv = encrypt.IV(chunk);
        _isFirstChunk = false;
        continue;
      }

      final encrypter =
          encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.gcm));
      final decrypted =
          encrypter.decryptBytes(encrypt.Encrypted(chunk), iv: _iv);
      yield Uint8List.fromList(decrypted);

      // Update IV for next chunk
      _iv =
          encrypt.IV(Uint8List.fromList(_iv.bytes.map((b) => b + 1).toList()));
    }
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom<Uint8List, Uint8List, RS, RT>(this);
  }
}

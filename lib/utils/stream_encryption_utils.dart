import 'dart:async';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'encryption_utils.dart';

/// Streaming encryption utilities for large files
class StreamEncryptionUtils {
  static const int defaultChunkSize = 64 * 1024; // 64KB chunks

  /// Encrypt a stream of data with AES-GCM
  static Stream<Uint8List> encryptStream(
    Stream<Uint8List> dataStream,
    encrypt.Key key, {
    String? sessionId,
  }) async* {
    final encryptor = _StreamEncryptor(key, sessionId: sessionId);

    try {
      await for (final chunk in dataStream) {
        yield* encryptor.encryptChunk(chunk);
      }
    } finally {
      encryptor.dispose();
    }
  }

  /// Decrypt a stream of data with AES-GCM
  static Stream<Uint8List> decryptStream(
    Stream<Uint8List> encryptedStream,
    encrypt.Key key, {
    String? sessionId,
  }) async* {
    final decryptor = _StreamDecryptor(key, sessionId: sessionId);

    try {
      await for (final chunk in encryptedStream) {
        yield* decryptor.decryptChunk(chunk);
      }
    } finally {
      decryptor.dispose();
    }
  }
}

/// Stream encryption handler
class _StreamEncryptor {
  final encrypt.Key _key;
  final String? _sessionId;
  bool _isFirstChunk = true;
  late encrypt.IV _iv;

  _StreamEncryptor(this._key, {String? sessionId}) : _sessionId = sessionId {
    _iv = encrypt.IV.fromSecureRandom(EncryptionUtils.ivLength);
  }

  Stream<Uint8List> encryptChunk(Uint8List chunk) async* {
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
    _iv = encrypt.IV(Uint8List.fromList(_iv.bytes.map((b) => b + 1).toList()));
  }

  void dispose() {
    // Clear nonce cache after stream ends
    if (_sessionId != null) {
      EncryptionUtils.clearNonceCache(_sessionId!);
    }
  }
}

/// Stream decryption handler
class _StreamDecryptor {
  final encrypt.Key _key;
  final String? _sessionId;
  bool _isFirstChunk = true;
  late encrypt.IV _iv;

  _StreamDecryptor(this._key, {String? sessionId}) : _sessionId = sessionId;

  Stream<Uint8List> decryptChunk(Uint8List chunk) async* {
    if (_isFirstChunk) {
      // First chunk is the IV
      _iv = encrypt.IV(chunk);
      _isFirstChunk = false;
      return;
    }

    final encrypter =
        encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.gcm));
    final decrypted = encrypter.decryptBytes(encrypt.Encrypted(chunk), iv: _iv);
    yield Uint8List.fromList(decrypted);

    // Update IV for next chunk
    _iv = encrypt.IV(Uint8List.fromList(_iv.bytes.map((b) => b + 1).toList()));
  }

  void dispose() {
    // Clear nonce cache after stream ends
    if (_sessionId != null) {
      EncryptionUtils.clearNonceCache(_sessionId!);
    }
  }
}

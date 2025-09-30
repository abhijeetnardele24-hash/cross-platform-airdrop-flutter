import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import '../utils/encryption_utils.dart';

/// SignalingService: WebSocket-based signaling for WebRTC with ECDH key exchange.
/// Usage: Connect to ws://your-signaling-server, join a room, exchange keys, SDP/ICE.
class SignalingService {
  static const String SIGNALING_SERVER_URL =
      'wss://airdrop-signaling.onrender.com';

  final String serverUrl;
  final String roomCode;
  WebSocketChannel? _channel;

  Function(Map<String, dynamic> message)? onMessage;
  Function(Uint8List sharedSecret)? onKeyExchangeComplete;

  // ECDH key pair
  pc.AsymmetricKeyPair<pc.PublicKey, pc.PrivateKey>? _keyPair;
  Uint8List? _sharedSecret;

  SignalingService({required this.serverUrl, required this.roomCode});

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    _channel!.stream.listen((event) {
      final msg = jsonDecode(event);
      if (msg['room'] == roomCode) {
        _handleMessage(msg);
      }
    });
    // Join room
    send({'type': 'join', 'room': roomCode});
    // Generate ECDH key pair and send public key
    _generateAndSendPublicKey();
  }

  void _generateAndSendPublicKey() {
    _keyPair = EncryptionUtils.generateECDHKeyPair();
    final publicKey = _keyPair!.publicKey as pc.ECPublicKey;
    final q = publicKey.Q!;
    final x = EncryptionUtils.bigIntToBytes(q.x!.toBigInteger()!, 32);
    final y = EncryptionUtils.bigIntToBytes(q.y!.toBigInteger()!, 32);
    final publicKeyData = Uint8List.fromList(x + y);
    send({
      'type': 'key_exchange',
      'publicKey': base64Encode(publicKeyData),
    });
  }

  void _handleMessage(Map<String, dynamic> msg) {
    switch (msg['type']) {
      case 'key_exchange':
        _handleKeyExchange(msg);
        break;
      default:
        if (onMessage != null) {
          onMessage!(msg);
        }
    }
  }

  void _handleKeyExchange(Map<String, dynamic> msg) {
    final peerPublicKeyBase64 = msg['publicKey'] as String?;
    if (_keyPair != null && peerPublicKeyBase64 != null) {
      final peerPublicKeyData = base64Decode(peerPublicKeyBase64);
      final xBytes = peerPublicKeyData.sublist(0, 32);
      final yBytes = peerPublicKeyData.sublist(32, 64);
      final xBigInt = _bytesToBigInt(xBytes);
      final yBigInt = _bytesToBigInt(yBytes);
      final domainParams = pc.ECDomainParameters('secp256r1');
      final peerPublicKey = pc.ECPublicKey(
        domainParams.curve.createPoint(xBigInt, yBigInt),
        domainParams,
      );
      _sharedSecret = EncryptionUtils.deriveSharedSecret(
        _keyPair!.privateKey as pc.ECPrivateKey,
        peerPublicKey,
      );
      onKeyExchangeComplete?.call(_sharedSecret!);
    }
  }

  BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  Uint8List? get sharedSecret => _sharedSecret;

  void send(Map<String, dynamic> message) {
    message['room'] = roomCode;
    _channel?.sink.add(jsonEncode(message));
  }

  void close() {
    _channel?.sink.close();
    _keyPair = null;
    _sharedSecret = null;
  }
}

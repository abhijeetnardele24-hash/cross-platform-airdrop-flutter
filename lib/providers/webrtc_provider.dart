import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/webrtc_service.dart';
import '../services/signaling_service.dart';
import '../models/chat_file_preview.dart';

/// WebRTCProvider manages P2P connection and chat/file transfer state.
class WebRTCProvider extends ChangeNotifier {
  final String roomCode;
  final String signalingUrl;
  late final WebRTCService _webrtc;
  late final SignalingService _signaling;
  bool _connected = false;
  List<String> _chatMessages = [];
  List<ChatFilePreview> _filePreviews = [];
  List<ChatFilePreview> get filePreviews => List.unmodifiable(_filePreviews);
  double _fileProgress = 0.0;
  bool _fileTransferActive = false;
  bool _fileTransferSuccess = false;
  String? _fileTransferError;
  bool _peerTyping = false;
  bool get peerTyping => _peerTyping;

  bool get connected => _connected;
  List<String> get chatMessages => List.unmodifiable(_chatMessages);
  double get fileProgress => _fileProgress;
  bool get fileTransferActive => _fileTransferActive;
  bool get fileTransferSuccess => _fileTransferSuccess;
  String? get fileTransferError => _fileTransferError;

  WebRTCProvider({required this.roomCode, required this.signalingUrl}) {
    _webrtc = WebRTCService();
    _signaling = SignalingService(serverUrl: signalingUrl, roomCode: roomCode);
    _signaling.onMessage = _onSignalingMessage;
    _webrtc.onMessage.listen((msg) {
      if (msg == '__typing__') {
        _peerTyping = true;
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), () {
          _peerTyping = false;
          notifyListeners();
        });
      } else {
        _chatMessages.add('Peer: $msg');
        notifyListeners();
      }
    });
    _signaling.connect();
    // Listen for file transfer progress
    _webrtc.onFileProgress.listen((progress) {
      if (progress != null) {
        _fileTransferActive = true;
        _fileProgress = progress;
        notifyListeners();
      }
    });
    _webrtc.onFileComplete.listen((_) {
      _fileTransferActive = false;
      _fileProgress = 1.0;
      _fileTransferSuccess = true;
      notifyListeners();
    });
    _webrtc.onFile.listen((fileBytes) {
      // File received (handle saving in UI)
      _fileTransferActive = false;
      _fileProgress = 1.0;
      _fileTransferSuccess = true;
      notifyListeners();
    });
  }

  Future<void> start({required bool isCaller}) async {
    await _webrtc.createConnection(isCaller: isCaller);
    if (isCaller) {
      final offer = await _webrtc.createOffer();
      await _webrtc.setLocalDescription(offer);
      _signaling.send({'type': 'offer', 'sdp': offer.sdp, 'sdpType': offer.type});
    }
  }

  void _onSignalingMessage(Map<String, dynamic> msg) async {
    switch (msg['type']) {
      case 'offer':
        final offer = RTCSessionDescription(msg['sdp'], msg['sdpType']);
        await _webrtc.setRemoteDescription(offer);
        final answer = await _webrtc.createAnswer();
        await _webrtc.setLocalDescription(answer);
        _signaling.send({
          'type': 'answer',
          'sdp': answer.sdp,
          'sdpType': answer.type
        });
        break;
      case 'answer':
        final answer = RTCSessionDescription(msg['sdp'], msg['sdpType']);
        await _webrtc.setRemoteDescription(answer);
        break;
      case 'candidate':
        if (msg['candidate'] != null) {
          final candidate = RTCIceCandidate(
            msg['candidate'],
            msg['sdpMid'],
            msg['sdpMLineIndex'],
          );
          await _webrtc.addIceCandidate(candidate);
        }
        break;
      case 'join':
        // Room joined, ready to connect
        break;
    }
    _connected = true;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    await _webrtc.sendMessage(text);
    _chatMessages.add('Me: $text');
    notifyListeners();
  }

  void sendTyping() {
    _webrtc.sendMessage('__typing__');
  }

  Future<void> sendFile(List<int> bytes, {String? fileName, int? fileSize}) async {
    _fileTransferActive = true;
    _fileProgress = 0.0;
    _fileTransferSuccess = false;
    _fileTransferError = null;
    notifyListeners();
    try {
      await _webrtc.sendFile(bytes, onProgress: (progress) {
        _fileProgress = progress;
        notifyListeners();
      });
      _fileTransferActive = false;
      _fileProgress = 1.0;
      _fileTransferSuccess = true;
      if (fileName != null && fileSize != null) {
        _filePreviews.add(ChatFilePreview(
          fileName: fileName,
          fileSize: fileSize,
          isImage: _isImageFile(fileName),
          imageBytes: _isImageFile(fileName) ? Uint8List.fromList(bytes) : null,
          isMe: true,
        ));
      }
      notifyListeners();
    } catch (e) {
      _fileTransferActive = false;
      _fileTransferSuccess = false;
      _fileTransferError = e.toString();
      notifyListeners();
    }
  }

  // Call this when receiving a file
  void addReceivedFilePreview(List<int> bytes, String fileName, int fileSize) {
    _filePreviews.add(ChatFilePreview(
      fileName: fileName,
      fileSize: fileSize,
      isImage: _isImageFile(fileName),
      imageBytes: _isImageFile(fileName) ? Uint8List.fromList(bytes) : null,
      isMe: false,
    ));
    notifyListeners();
  }

  bool _isImageFile(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.gif') || lower.endsWith('.bmp') || lower.endsWith('.webp');
  }

  // Fallback logic stub
  bool get shouldUseWebRTC => connected; // In real app, check platform/capabilities

  void dispose() {
    _webrtc.close();
    _signaling.close();
    super.dispose();
  }
}

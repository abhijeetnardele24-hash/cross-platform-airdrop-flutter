import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// WebRTCService handles peer-to-peer file and chat transfer using WebRTC data channels.
/// Signaling must be handled externally (e.g., via WebSocket, Firebase, or custom server).
class WebRTCService {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  final _onMessageController = StreamController<String>.broadcast();
  final _onFileController = StreamController<List<int>>.broadcast();
  final _onFileProgressController = StreamController<double>.broadcast();
  final _onFileCompleteController = StreamController<void>.broadcast();

  Stream<String> get onMessage => _onMessageController.stream;
  Stream<List<int>> get onFile => _onFileController.stream;
  Stream<double> get onFileProgress => _onFileProgressController.stream;
  Stream<void> get onFileComplete => _onFileCompleteController.stream;

  Future<void> createConnection({required bool isCaller}) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };
    
    final constraints = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };
    
    _peerConnection = await createPeerConnection(config, constraints);
    
    _peerConnection!.onIceCandidate = (candidate) {
      // TODO: Send candidate to peer via signaling
      // This will be handled by the signaling service
      print('ICE Candidate: ${candidate.candidate}');
    };
    
    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannel();
    };
    
    _peerConnection!.onConnectionState = (state) {
      print('Connection State: $state');
    };
    
    _peerConnection!.onIceConnectionState = (state) {
      print('ICE Connection State: $state');
    };
    
    if (isCaller) {
      _dataChannel = await _peerConnection!.createDataChannel(
        'fileTransfer',
        RTCDataChannelInit()..ordered = true,
      );
      _setupDataChannel();
    }
  }

  void _setupDataChannel() {
    List<int> fileBuffer = [];
    int expectedFileSize = 0;
    
    _dataChannel?.onDataChannelState = (state) {
      print('Data Channel State: $state');
    };
    
    _dataChannel?.onMessage = (RTCDataChannelMessage message) {
      if (message.isBinary) {
        fileBuffer.addAll(message.binary);
        
        // Calculate progress if we know the expected size
        if (expectedFileSize > 0) {
          final progress = fileBuffer.length / expectedFileSize;
          _onFileProgressController.add(progress);
        }
        
        // For demo: Assume end of file if chunk is less than chunkSize
        if (message.binary.length < 16 * 1024) {
          _onFileController.add(List<int>.from(fileBuffer));
          _onFileCompleteController.add(null);
          fileBuffer.clear();
          expectedFileSize = 0;
        }
      } else {
        final text = message.text;
        // Check if this is a file metadata message
        if (text.startsWith('FILE_META:')) {
          final parts = text.split(':');
          if (parts.length >= 2) {
            expectedFileSize = int.tryParse(parts[1]) ?? 0;
          }
        } else {
          _onMessageController.add(text);
        }
      }
    };
  }

  Future<void> sendMessage(String text) async {
    await _dataChannel?.send(RTCDataChannelMessage(text));
  }

  Future<void> sendFile(List<int> bytes, {void Function(double progress)? onProgress}) async {
    if (_dataChannel == null) {
      throw Exception('Data channel not established');
    }
    
    // Send file metadata first
    await _dataChannel!.send(RTCDataChannelMessage('FILE_META:${bytes.length}'));
    
    // Wait a bit for metadata to be processed
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Chunked send for large files
    const int chunkSize = 16 * 1024; // 16KB
    int sent = 0;
    
    while (sent < bytes.length) {
      final end = (sent + chunkSize < bytes.length) ? sent + chunkSize : bytes.length;
      final chunk = bytes.sublist(sent, end);
      
      // Convert List<int> to Uint8List for RTCDataChannelMessage
      await _dataChannel!.send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(chunk)));
      
      sent = end;
      final progress = sent / bytes.length;
      _onFileProgressController.add(progress);
      if (onProgress != null) onProgress(progress);
      
      // Small delay to prevent overwhelming the channel
      if (sent < bytes.length) {
        await Future.delayed(const Duration(microseconds: 100));
      }
    }
    
    _onFileCompleteController.add(null);
  }

  Future<RTCSessionDescription> createOffer() async {
    return await _peerConnection!.createOffer({'offerToReceiveAudio': false, 'offerToReceiveVideo': false});
  }

  Future<RTCSessionDescription> createAnswer() async {
    return await _peerConnection!.createAnswer({'offerToReceiveAudio': false, 'offerToReceiveVideo': false});
  }

  Future<void> setLocalDescription(RTCSessionDescription desc) async {
    await _peerConnection?.setLocalDescription(desc);
  }

  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    await _peerConnection?.setRemoteDescription(desc);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection?.addCandidate(candidate);
  }

  void close() {
    _dataChannel?.close();
    _peerConnection?.close();
    _onMessageController.close();
    _onFileController.close();
    _onFileProgressController.close();
    _onFileCompleteController.close();
  }
}

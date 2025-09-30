import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../utils/encryption_utils.dart';
import '../utils/stream_encryption_utils.dart';
import '../models/transfer_model.dart';
import '../models/device_model.dart';
import 'room_socket_service.dart';
import 'signaling_service.dart';

/// Comprehensive file transfer service with encryption and progress tracking
class FileTransferService {
  final RoomSocketService _socketService = RoomSocketService();

  // Transfer queue and management
  final List<TransferModel> _transferQueue = [];
  final Map<String, TransferModel> _activeTransfers = {};
  final Map<String, StreamSubscription?> _transferSubscriptions = {};
  final Map<String, Timer?> _retryTimers = {};

  // Bandwidth throttling
  int _maxConcurrentTransfers = 3;
  int _bandwidthLimit = 0; // 0 = unlimited, bytes per second

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 2);
  static const double _retryBackoffMultiplier = 2.0;

  // Callbacks
  Function(String fileName, int fileSize)? onFileReceiveStart;
  Function(String fileName, double progress)? onFileReceiveProgress;
  Function(String fileName, String filePath)? onFileReceiveComplete;
  Function(String fileName, String error)? onFileReceiveError;

  Function(String fileName, double progress)? onFileSendProgress;
  Function(String fileName)? onFileSendComplete;
  Function(String fileName, String error)? onFileSendError;

  Function(String deviceName)? onDeviceFound;
  Function(String deviceId)? onDeviceConnected;
  Function()? onDeviceDisconnected;

  Function(TransferModel transfer)? onTransferUpdated;
  Function(List<TransferModel> queue)? onQueueUpdated;

  bool _isInitialized = false;
  String _sessionCode = '';

  // ECDH key exchange
  SignalingService? _signalingService;
  encrypt.Key? _encryptionKey;
  Uint8List? _sharedSecret;
  String? _currentSessionId; // For nonce management
  StreamController<Uint8List>? _receiveStreamController;
  StreamSubscription<Uint8List>? _receiveStreamSubscription;

  /// Initialize the file transfer service with ECDH key exchange
  Future<void> initialize(String sessionCode, {bool isHost = true}) async {
    if (_isInitialized) {
      debugPrint('⚠️ FileTransferService already initialized');
      return;
    }

    _sessionCode = sessionCode;

    // Initialize signaling service for key exchange
    _signalingService = SignalingService(
      serverUrl: SignalingService.SIGNALING_SERVER_URL,
      roomCode: sessionCode,
    );

    _signalingService!.onKeyExchangeComplete = (sharedSecret) {
      _sharedSecret = sharedSecret;
      _encryptionKey = EncryptionUtils.deriveAESKey(sharedSecret);
      debugPrint('🔐 ECDH key exchange completed, encryption ready');
    };

    _signalingService!.connect();

    // Set up socket service callbacks
    _socketService.setOnDeviceFound((deviceName) {
      debugPrint('📱 Device found: $deviceName');
      onDeviceFound?.call(deviceName);
    });

    _socketService.setOnDeviceConnected((deviceId) {
      debugPrint('✅ Device connected: $deviceId');
      onDeviceConnected?.call(deviceId);
    });

    _socketService.setOnDeviceDisconnected(() {
      debugPrint('🔌 Device disconnected');
      onDeviceDisconnected?.call();
    });

    // Start server or connect
    if (isHost) {
      await _socketService.startServer(8888, _handleReceivedData);
      debugPrint('📢 Started as host');
    } else {
      await _socketService.connectToHost(
          'localhost', 8888, _handleReceivedData);
      debugPrint('🔍 Started as client');
    }

    _isInitialized = true;
    debugPrint('✅ FileTransferService initialized with ECDH');
  }

  /// Wait for ECDH key exchange to complete
  Future<void> _waitForKeyExchange() async {
    const maxWaitTime = Duration(seconds: 30);
    final startTime = DateTime.now();

    while (_encryptionKey == null) {
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        throw Exception('ECDH key exchange timeout');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Send a single file with ECDH encryption
  Future<void> sendFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Wait for key exchange to complete if not ready
      if (_encryptionKey == null) {
        debugPrint('⏳ Waiting for ECDH key exchange...');
        await _waitForKeyExchange();
      }

      final fileName = path.basename(filePath);
      final fileSize = await file.length();

      debugPrint('📤 Sending file: $fileName ($fileSize bytes)');

      // For large files, use streaming encryption
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB threshold
        await _sendFileStreaming(filePath, fileName, fileSize);
      } else {
        await _sendFileBuffered(filePath, fileName, fileSize);
      }

      onFileSendComplete?.call(fileName);
      debugPrint('✅ File sent successfully: $fileName');
    } catch (e) {
      final fileName = path.basename(filePath);
      debugPrint('❌ Error sending file: $e');
      onFileSendError?.call(fileName, e.toString());
      rethrow;
    }
  }

  /// Send large files using streaming encryption
  Future<void> _sendFileStreaming(
      String filePath, String fileName, int fileSize) async {
    final file = File(filePath);

    // Compute checksum for integrity verification
    final checksum = await _computeFileChecksum(filePath);

    // Create file metadata with checksum
    final metadata = _createFileMetadata(fileName, fileSize, checksum);
    final metadataBytes = Uint8List.fromList(metadata.codeUnits);

    // Send metadata first (unencrypted for compatibility)
    await _socketService.sendFile(
      metadataBytes,
      _sessionCode,
      onProgress: (progress) => debugPrint(
          '📊 Metadata send progress: ${(progress * 100).toStringAsFixed(1)}%'),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Generate session ID for nonce management
    _currentSessionId ??= 'session_${DateTime.now().millisecondsSinceEpoch}';

    // Create encrypted stream
    final fileStream =
        file.openRead().map((event) => Uint8List.fromList(event));
    final encryptedStream = StreamEncryptionUtils.encryptStream(
        fileStream, _encryptionKey!,
        sessionId: _currentSessionId);

    // Send encrypted data with progress tracking
    int bytesSent = 0;
    await for (final chunk in encryptedStream) {
      await _socketService.sendFile(
        chunk,
        _sessionCode,
        onProgress: (progress) {
          final chunkProgress = bytesSent + (chunk.length * progress);
          final totalProgress = chunkProgress /
              (fileSize + (fileSize * 0.1)); // Account for encryption overhead
          debugPrint(
              '📊 File send progress: ${(totalProgress * 100).toStringAsFixed(1)}%');
          onFileSendProgress?.call(fileName, totalProgress.clamp(0.0, 1.0));
        },
      );
      bytesSent += chunk.length;
    }

    // Clear nonce cache after transfer
    if (_currentSessionId != null) {
      EncryptionUtils.clearNonceCache(_currentSessionId!);
    }
  }

  /// Send smaller files using buffered encryption
  Future<void> _sendFileBuffered(
      String filePath, String fileName, int fileSize) async {
    final file = File(filePath);

    // Read file bytes
    final fileBytes = await file.readAsBytes();

    // Compute checksum for integrity verification
    final checksum = EncryptionUtils.computeChecksum(fileBytes);

    // Encrypt file data
    final encryptedData =
        EncryptionUtils.encryptBytes(fileBytes, _encryptionKey!);

    // Create file metadata with checksum
    final metadata = _createFileMetadata(fileName, fileSize, checksum);
    final metadataBytes = Uint8List.fromList(metadata.codeUnits);

    // Send metadata first (unencrypted for compatibility)
    await _socketService.sendFile(
      metadataBytes,
      _sessionCode,
      onProgress: (progress) => debugPrint(
          '📊 Metadata send progress: ${(progress * 100).toStringAsFixed(1)}%'),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Send encrypted file data with progress tracking
    await _socketService.sendFile(
      encryptedData,
      _sessionCode,
      onProgress: (progress) {
        debugPrint(
            '📊 File send progress: ${(progress * 100).toStringAsFixed(1)}%');
        onFileSendProgress?.call(fileName, progress);
      },
    );
  }

  /// Compute checksum for large files without loading entire file into memory
  Future<String> _computeFileChecksum(String filePath) async {
    final file = File(filePath);
    final stream = file.openRead();
    final hash = await sha256.bind(stream).first;
    return hash.toString();
  }

  /// Send multiple files sequentially
  Future<void> sendFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      try {
        await sendFile(filePath);
        // Small delay between files
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('❌ Error sending file $filePath: $e');
        // Continue with next file
      }
    }
  }

  /// Handle received data (metadata or file content)
  Future<void> _handleReceivedData(Uint8List data) async {
    try {
      // Try to parse as metadata first
      final dataString = String.fromCharCodes(data);

      if (dataString.startsWith('FILE_META:')) {
        // This is metadata
        final metadata = _parseFileMetadata(dataString);
        final fileName = metadata['fileName'] as String;
        final fileSize = metadata['fileSize'] as int;
        final checksum = metadata['checksum'] as String;

        debugPrint('📥 Receiving file: $fileName ($fileSize bytes)');
        onFileReceiveStart?.call(fileName, fileSize);
      } else {
        // This is encrypted file content - save it
        await _saveReceivedFile(data);
      }
    } catch (e) {
      debugPrint('❌ Error handling received data: $e');
      onFileReceiveError?.call('unknown', e.toString());
    }
  }

  /// Save received file to downloads directory
  Future<void> _saveReceivedFile(Uint8List encryptedData) async {
    try {
      // Wait for key exchange to complete if not ready
      if (_encryptionKey == null) {
        debugPrint('⏳ Waiting for ECDH key exchange for decryption...');
        await _waitForKeyExchange();
      }

      // Decrypt the data using ECDH key
      final decryptedData =
          EncryptionUtils.decryptBytes(encryptedData, _encryptionKey!);

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'received_file_$timestamp';
      final filePath = path.join(downloadsDir.path, fileName);

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(decryptedData);

      debugPrint('✅ File saved: $filePath');
      onFileReceiveComplete?.call(fileName, filePath);
    } catch (e) {
      debugPrint('❌ Error saving file: $e');
      onFileReceiveError?.call('unknown', e.toString());
    }
  }

  /// Create file metadata string with checksum
  String _createFileMetadata(String fileName, int fileSize, String checksum) {
    return 'FILE_META:$fileName:$fileSize:$checksum';
  }

  /// Parse file metadata string
  Map<String, dynamic> _parseFileMetadata(String metadata) {
    final parts = metadata.split(':');
    if (parts.length < 4) {
      throw Exception('Invalid metadata format');
    }

    return {
      'fileName': parts[1],
      'fileSize': int.parse(parts[2]),
      'checksum': parts[3],
    };
  }

  /// Get connection state
  ConnectionState get connectionState => _socketService.connectionState;

  /// Close all connections
  Future<void> close() async {
    // Cancel all active transfers and timers
    for (final subscription in _transferSubscriptions.values) {
      subscription?.cancel();
    }
    for (final timer in _retryTimers.values) {
      timer?.cancel();
    }

    _transferQueue.clear();
    _activeTransfers.clear();
    _transferSubscriptions.clear();
    _retryTimers.clear();

    _signalingService?.close();
    await _socketService.close();
    _isInitialized = false;
    debugPrint('🔌 FileTransferService closed');
  }

  /// Queue a file for transfer
  Future<String> queueFileTransfer(
    String filePath,
    DeviceModel toDevice, {
    int priority = 1,
    TransferDirection direction = TransferDirection.send,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final fileName = path.basename(filePath);
    final fileSize = await file.length();
    final mimeType = _getMimeType(filePath);

    final transfer = TransferModel(
      id: _generateTransferId(),
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      mimeType: mimeType,
      fromDevice: DeviceModel(
        id: 'local',
        name: 'This Device',
        ipAddress: '127.0.0.1',
        type: DeviceType.unknown,
        lastSeen: DateTime.now(),
      ), // TODO: Get actual device info
      toDevice: toDevice,
      status: TransferStatus.pending,
      direction: direction,
      startTime: DateTime.now(),
      priority: priority,
    );

    _transferQueue.add(transfer);
    _sortQueueByPriority();
    _updateQueuePositions();
    onQueueUpdated?.call(List.from(_transferQueue));

    debugPrint('📋 Queued transfer: $fileName (${transfer.id})');
    _processQueue();

    return transfer.id;
  }

  /// Pause a transfer
  Future<void> pauseTransfer(String transferId) async {
    final transfer = _activeTransfers[transferId];
    if (transfer != null && transfer.status.canPause) {
      final updatedTransfer = transfer.copyWith(
        status: TransferStatus.paused,
        isPaused: true,
      );
      _activeTransfers[transferId] = updatedTransfer;
      _transferSubscriptions[transferId]?.pause();
      onTransferUpdated?.call(updatedTransfer);
      debugPrint('⏸️ Paused transfer: ${transfer.fileName}');
    }
  }

  /// Resume a transfer
  Future<void> resumeTransfer(String transferId) async {
    final transfer = _activeTransfers[transferId];
    if (transfer != null && transfer.status.canResume) {
      final updatedTransfer = transfer.copyWith(
        status: TransferStatus.pending,
        isPaused: false,
      );
      _activeTransfers[transferId] = updatedTransfer;
      _transferSubscriptions[transferId]?.resume();
      onTransferUpdated?.call(updatedTransfer);
      debugPrint('▶️ Resumed transfer: ${transfer.fileName}');
      _processQueue();
    }
  }

  /// Cancel a transfer
  Future<void> cancelTransfer(String transferId) async {
    final transfer = _activeTransfers[transferId] ??
        _transferQueue
            .cast<TransferModel?>()
            .firstWhere((t) => t?.id == transferId, orElse: () => null);

    if (transfer != null) {
      final updatedTransfer =
          transfer.copyWith(status: TransferStatus.cancelled);
      _activeTransfers.remove(transferId);
      _transferQueue.removeWhere((t) => t.id == transferId);
      _transferSubscriptions[transferId]?.cancel();
      _retryTimers[transferId]?.cancel();
      _transferSubscriptions.remove(transferId);
      _retryTimers.remove(transferId);
      onTransferUpdated?.call(updatedTransfer);
      onQueueUpdated?.call(List.from(_transferQueue));
      debugPrint('❌ Cancelled transfer: ${transfer.fileName}');
      _processQueue();
    }
  }

  /// Set bandwidth limit (0 = unlimited)
  void setBandwidthLimit(int bytesPerSecond) {
    _bandwidthLimit = bytesPerSecond;
    debugPrint(
        '📊 Bandwidth limit set to: ${bytesPerSecond == 0 ? 'unlimited' : '$bytesPerSecond B/s'}');
  }

  /// Set maximum concurrent transfers
  void setMaxConcurrentTransfers(int max) {
    _maxConcurrentTransfers = max;
    debugPrint('🔢 Max concurrent transfers set to: $max');
    _processQueue();
  }

  /// Get current transfer queue
  List<TransferModel> getTransferQueue() => List.from(_transferQueue);

  /// Get active transfers
  List<TransferModel> getActiveTransfers() => _activeTransfers.values.toList();

  /// Process the transfer queue
  void _processQueue() {
    // Remove completed/failed/cancelled transfers from active list
    _activeTransfers.removeWhere((id, transfer) =>
        transfer.status == TransferStatus.completed ||
        transfer.status == TransferStatus.failed ||
        transfer.status == TransferStatus.cancelled);

    // Start new transfers if we have capacity
    while (_activeTransfers.length < _maxConcurrentTransfers &&
        _transferQueue.isNotEmpty) {
      final transfer = _transferQueue.removeAt(0);
      _updateQueuePositions();
      onQueueUpdated?.call(List.from(_transferQueue));

      _startTransfer(transfer);
    }
  }

  /// Start a transfer
  Future<void> _startTransfer(TransferModel transfer) async {
    _activeTransfers[transfer.id] =
        transfer.copyWith(status: TransferStatus.connecting);
    onTransferUpdated?.call(_activeTransfers[transfer.id]!);

    try {
      if (transfer.direction == TransferDirection.send) {
        await _executeSendTransfer(transfer);
      } else {
        await _executeReceiveTransfer(transfer);
      }
    } catch (e) {
      await _handleTransferError(transfer, e);
    }
  }

  /// Execute send transfer with throttling
  Future<void> _executeSendTransfer(TransferModel transfer) async {
    final file = File(transfer.filePath);
    final fileBytes = await file.readAsBytes();

    // Update status to transferring
    _activeTransfers[transfer.id] =
        transfer.copyWith(status: TransferStatus.transferring);
    onTransferUpdated?.call(_activeTransfers[transfer.id]!);

    // Compute checksum for integrity verification
    final checksum = EncryptionUtils.computeChecksum(fileBytes);

    // Send metadata first
    final metadata =
        _createFileMetadata(transfer.fileName, transfer.fileSize, checksum);
    final metadataBytes = Uint8List.fromList(metadata.codeUnits);
    await _socketService.sendFile(
      metadataBytes,
      _sessionCode,
      onProgress: (progress) => debugPrint(
          '📊 Metadata send progress: ${(progress * 100).toStringAsFixed(1)}%'),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Send file data with throttling
    int bytesSent = 0;
    final chunkSize = _bandwidthLimit > 0
        ? min(64 * 1024, _bandwidthLimit ~/ 10)
        : 64 * 1024; // 64KB chunks or bandwidth-based

    for (int i = 0; i < fileBytes.length; i += chunkSize) {
      if (_activeTransfers[transfer.id]?.isPaused == true) {
        // Wait while paused
        while (_activeTransfers[transfer.id]?.isPaused == true) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      final end = min(i + chunkSize, fileBytes.length);
      final chunk = fileBytes.sublist(i, end);

      await _socketService.sendFile(
        chunk,
        _sessionCode,
        onProgress: (progress) {
          final totalProgress =
              (bytesSent + (chunk.length * progress)) / fileBytes.length;
          _updateTransferProgress(transfer.id, totalProgress,
              bytesSent + (chunk.length * progress).toInt());
        },
      );

      bytesSent += chunk.length;

      // Apply bandwidth throttling
      if (_bandwidthLimit > 0) {
        final expectedTime = chunk.length / _bandwidthLimit;
        await Future.delayed(
            Duration(milliseconds: (expectedTime * 1000).toInt()));
      }
    }

    _completeTransfer(transfer.id);
  }

  /// Execute receive transfer
  Future<void> _executeReceiveTransfer(TransferModel transfer) async {
    // For receive transfers, we wait for incoming data
    // This would be triggered by the socket service receiving metadata
    _activeTransfers[transfer.id] =
        transfer.copyWith(status: TransferStatus.connecting);
    onTransferUpdated?.call(_activeTransfers[transfer.id]!);
  }

  /// Handle transfer error with retry logic
  Future<void> _handleTransferError(
      TransferModel transfer, dynamic error) async {
    final transferError = _categorizeError(error);
    final updatedTransfer = transfer.copyWith(
      status: TransferStatus.failed,
      error: transferError,
      errorMessage: transferError.displayMessage,
      retryCount: transfer.retryCount + 1,
      lastRetryTime: DateTime.now(),
    );

    _activeTransfers[transfer.id] = updatedTransfer;
    onTransferUpdated?.call(updatedTransfer);

    // Retry if applicable
    if (transferError.isRetryable && updatedTransfer.retryCount < _maxRetries) {
      final delay = _calculateRetryDelay(updatedTransfer.retryCount);
      debugPrint(
          '🔄 Retrying transfer ${transfer.fileName} in ${delay.inSeconds}s (attempt ${updatedTransfer.retryCount})');

      _retryTimers[transfer.id] = Timer(delay, () {
        _retryTransfer(updatedTransfer);
      });
    } else {
      debugPrint(
          '❌ Transfer failed permanently: ${transfer.fileName} - ${transferError.displayMessage}');
    }
  }

  /// Retry a failed transfer
  Future<void> _retryTransfer(TransferModel transfer) async {
    _retryTimers.remove(transfer.id);
    final updatedTransfer = transfer.copyWith(
      status: TransferStatus.pending,
      error: null,
      errorMessage: null,
    );
    _activeTransfers[transfer.id] = updatedTransfer;
    onTransferUpdated?.call(updatedTransfer);
    _startTransfer(updatedTransfer);
  }

  /// Complete a transfer
  void _completeTransfer(String transferId) {
    final transfer = _activeTransfers[transferId];
    if (transfer != null) {
      final updatedTransfer = transfer.copyWith(
        status: TransferStatus.completed,
        endTime: DateTime.now(),
        progress: 1.0,
      );
      _activeTransfers[transferId] = updatedTransfer;
      onTransferUpdated?.call(updatedTransfer);
      debugPrint('✅ Transfer completed: ${transfer.fileName}');
      _processQueue();
    }
  }

  /// Update transfer progress
  void _updateTransferProgress(
      String transferId, double progress, int bytesTransferred) {
    final transfer = _activeTransfers[transferId];
    if (transfer != null) {
      final updatedTransfer = transfer.copyWith(
        progress: progress,
        bytesTransferred: bytesTransferred,
      );
      _activeTransfers[transferId] = updatedTransfer;
      onTransferUpdated?.call(updatedTransfer);
    }
  }

  /// Sort queue by priority (higher priority first, then by file size for same priority)
  void _sortQueueByPriority() {
    _transferQueue.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority); // Higher priority first
      }
      return a.fileSize
          .compareTo(b.fileSize); // Smaller files first for same priority
    });
  }

  /// Update queue positions
  void _updateQueuePositions() {
    for (int i = 0; i < _transferQueue.length; i++) {
      _transferQueue[i] = _transferQueue[i].copyWith(queuePosition: i + 1);
    }
  }

  /// Generate unique transfer ID
  String _generateTransferId() {
    return 'transfer_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// Get MIME type from file path
  String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.txt':
        return 'text/plain';
      case '.zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  /// Categorize error into TransferError enum
  TransferError _categorizeError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return TransferError.networkError;
    } else if (errorString.contains('device') ||
        errorString.contains('disconnected')) {
      return TransferError.deviceDisconnected;
    } else if (errorString.contains('file') &&
        errorString.contains('not found')) {
      return TransferError.fileNotFound;
    } else if (errorString.contains('permission') ||
        errorString.contains('denied')) {
      return TransferError.permissionDenied;
    } else if (errorString.contains('storage') ||
        errorString.contains('full')) {
      return TransferError.storageFull;
    } else if (errorString.contains('checksum') ||
        errorString.contains('integrity')) {
      return TransferError.checksumMismatch;
    } else if (errorString.contains('encryption') ||
        errorString.contains('decrypt')) {
      return TransferError.encryptionError;
    } else if (errorString.contains('timeout')) {
      return TransferError.timeout;
    } else {
      return TransferError.unknown;
    }
  }

  /// Calculate retry delay with exponential backoff
  Duration _calculateRetryDelay(int retryCount) {
    final delaySeconds = _baseRetryDelay.inSeconds *
        pow(_retryBackoffMultiplier, retryCount - 1);
    return Duration(seconds: delaySeconds.toInt());
  }
}

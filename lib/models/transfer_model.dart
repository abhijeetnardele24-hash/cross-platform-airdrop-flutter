import 'dart:convert';
import 'device_model.dart';

class TransferModel {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final DeviceModel fromDevice;
  final DeviceModel toDevice;
  final TransferStatus status;
  final TransferDirection direction;
  final DateTime startTime;
  final DateTime? endTime;
  final int bytesTransferred;
  final double progress;
  final String? errorMessage;
  final TransferError? error;
  final int retryCount;
  final DateTime? lastRetryTime;
  final bool isPaused;
  final int priority; // 0: low, 1: normal, 2: high
  final int queuePosition;

  final String? checksum;
  final bool isEncrypted;

  const TransferModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.fromDevice,
    required this.toDevice,
    required this.status,
    required this.direction,
    required this.startTime,
    this.endTime,
    this.bytesTransferred = 0,
    this.progress = 0.0,
    this.errorMessage,
    this.error,
    this.retryCount = 0,
    this.lastRetryTime,
    this.isPaused = false,
    this.priority = 1,
    this.queuePosition = 0,
    this.checksum,
    this.isEncrypted = true,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      fromDevice: json['fromDevice'] != null
          ? (json['fromDevice'] is Map<String, dynamic>
              ? DeviceModel.fromJson(json['fromDevice'] as Map<String, dynamic>)
              : DeviceModel.fromJson(jsonDecode(json['fromDevice'] as String)
                  as Map<String, dynamic>))
          : DeviceModel(
              id: '',
              name: '',
              ipAddress: '',
              type: DeviceType.unknown,
              lastSeen: DateTime.now()),
      toDevice: json['toDevice'] != null
          ? (json['toDevice'] is Map<String, dynamic>
              ? DeviceModel.fromJson(json['toDevice'] as Map<String, dynamic>)
              : DeviceModel.fromJson(jsonDecode(json['toDevice'] as String)
                  as Map<String, dynamic>))
          : DeviceModel(
              id: '',
              name: '',
              ipAddress: '',
              type: DeviceType.unknown,
              lastSeen: DateTime.now()),
      status: TransferStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      direction: TransferDirection.values.firstWhere(
        (e) => e.toString().split('.').last == json['direction'],
        orElse: () => TransferDirection.send,
      ),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      bytesTransferred: json['bytesTransferred'] as int? ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['errorMessage'] as String?,
      checksum: json['checksum'] as String?,
      isEncrypted: json['isEncrypted'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'fromDevice': fromDevice.toJson(),
      'toDevice': toDevice.toJson(),
      'status': status.toString().split('.').last,
      'direction': direction.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'bytesTransferred': bytesTransferred,
      'progress': progress,
      'errorMessage': errorMessage,
      'checksum': checksum,
      'isEncrypted': isEncrypted,
    };
  }

  TransferModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    DeviceModel? fromDevice,
    DeviceModel? toDevice,
    TransferStatus? status,
    TransferDirection? direction,
    DateTime? startTime,
    DateTime? endTime,
    int? bytesTransferred,
    double? progress,
    String? errorMessage,
    TransferError? error,
    int? retryCount,
    DateTime? lastRetryTime,
    bool? isPaused,
    int? priority,
    int? queuePosition,
    String? checksum,
    bool? isEncrypted,
  }) {
    return TransferModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      fromDevice: fromDevice ?? this.fromDevice,
      toDevice: toDevice ?? this.toDevice,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      retryCount: retryCount ?? this.retryCount,
      lastRetryTime: lastRetryTime ?? this.lastRetryTime,
      isPaused: isPaused ?? this.isPaused,
      priority: priority ?? this.priority,
      queuePosition: queuePosition ?? this.queuePosition,
      checksum: checksum ?? this.checksum,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    }
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  double get transferSpeed {
    if (bytesTransferred == 0) return 0.0;
    final duration = DateTime.now().difference(startTime).inSeconds;
    if (duration == 0) return 0.0;
    return bytesTransferred / duration; // bytes per second
  }

  String get formattedTransferSpeed {
    final speed = transferSpeed;
    if (speed < 1024) return '${speed.toStringAsFixed(0)} B/s';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransferModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransferModel(id: $id, fileName: $fileName, status: $status, progress: $progress)';
  }
}

enum TransferStatus {
  pending,
  connecting,
  transferring,
  paused,
  completed,
  failed,
  cancelled,
}

enum TransferDirection {
  send,
  receive,
}

enum TransferError {
  networkError,
  deviceDisconnected,
  fileNotFound,
  permissionDenied,
  storageFull,
  checksumMismatch,
  encryptionError,
  timeout,
  unknown,
}

extension TransferErrorExtension on TransferError {
  String get displayMessage {
    switch (this) {
      case TransferError.networkError:
        return 'Network connection lost. Please check your internet connection.';
      case TransferError.deviceDisconnected:
        return 'Device disconnected unexpectedly. Please try again.';
      case TransferError.fileNotFound:
        return 'File not found. Please check if the file exists.';
      case TransferError.permissionDenied:
        return 'Permission denied. Please check file permissions.';
      case TransferError.storageFull:
        return 'Storage is full. Please free up space.';
      case TransferError.checksumMismatch:
        return 'File integrity check failed. The file may be corrupted.';
      case TransferError.encryptionError:
        return 'Encryption error occurred. Please try again.';
      case TransferError.timeout:
        return 'Connection timed out. Please try again.';
      case TransferError.unknown:
        return 'An unknown error occurred. Please try again.';
    }
  }

  bool get isRetryable {
    return this == TransferError.networkError ||
        this == TransferError.deviceDisconnected ||
        this == TransferError.timeout ||
        this == TransferError.encryptionError;
  }
}

extension TransferStatusExtension on TransferStatus {
  String get displayName {
    switch (this) {
      case TransferStatus.pending:
        return 'Pending';
      case TransferStatus.connecting:
        return 'Connecting';
      case TransferStatus.transferring:
        return 'Transferring';
      case TransferStatus.paused:
        return 'Paused';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.failed:
        return 'Failed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive {
    return this == TransferStatus.connecting ||
        this == TransferStatus.transferring;
  }

  bool get canResume {
    return this == TransferStatus.paused || this == TransferStatus.failed;
  }

  bool get canPause {
    return this == TransferStatus.transferring;
  }

  bool get canCancel {
    return this != TransferStatus.completed && this != TransferStatus.cancelled;
  }
}

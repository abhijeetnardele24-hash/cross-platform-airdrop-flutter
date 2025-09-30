import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/encryption_utils.dart';

/// Platform-specific socket connection for file transfer.
/// - Android: Uses Google Nearby Connections API
/// - iOS: Uses Multipeer Connectivity via platform channels
/// - Desktop/Web: Uses standard Dart sockets
class RoomSocketService {
  static final RoomSocketService _instance = RoomSocketService._internal();
  factory RoomSocketService() => _instance;
  RoomSocketService._internal();

  Socket? _socket;
  ServerSocket? _serverSocket;

  // Platform channels for iOS Multipeer Connectivity
  static const MethodChannel _iosChannel =
      MethodChannel('com.teamnarcos.airdrop/multipeer');

  // Nearby Connections for Android
  final Nearby _nearby = Nearby();
  String? _connectedEndpointId;
  bool _isAdvertising = false;
  bool _isDiscovering = false;

  // Connection state
  ConnectionState _connectionState = ConnectionState.disconnected;
  ConnectionState get connectionState => _connectionState;

  // Callbacks
  Function(Uint8List data)? _onFileReceived;
  Function(String deviceName)? _onDeviceFound;
  Function(String deviceId)? _onDeviceConnected;
  Function()? _onDeviceDisconnected;

  /// Start advertising/hosting for connections
  /// Platform-specific: Android uses Nearby Connections, iOS uses Multipeer Connectivity
  Future<void> startServer(
      int port, void Function(Uint8List data) onFileReceived) async {
    _onFileReceived = onFileReceived;

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop/Web: Use standard sockets
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _serverSocket!.listen((client) {
        _socket = client;
        client.listen((data) {
          onFileReceived(Uint8List.fromList(data));
        });
      });
      _connectionState = ConnectionState.listening;
    } else if (Platform.isAndroid) {
      // Android: Use Nearby Connections
      await _startAndroidAdvertising();
    } else if (Platform.isIOS) {
      // iOS: Use Multipeer Connectivity
      await _startIOSAdvertising();
    }
  }

  /// Android: Start advertising using Nearby Connections
  Future<void> _startAndroidAdvertising() async {
    try {
      // Request permissions
      bool permissionsGranted = await _requestAndroidPermissions();

      if (!permissionsGranted) {
        debugPrint('❌ Permissions not granted');
        return;
      }

      // Start advertising
      await _nearby.startAdvertising(
        'AirDrop_User',
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: (String endpointId, ConnectionInfo info) {
          debugPrint('📡 Connection initiated with: ${info.endpointName}');
          _onDeviceFound?.call(info.endpointName);

          // Auto-accept connection
          _nearby.acceptConnection(
            endpointId,
            onPayLoadRecieved: (endpointId, payload) {
              if (payload.type == PayloadType.BYTES) {
                _onFileReceived?.call(payload.bytes!);
              }
            },
            onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {
              if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
                debugPrint('✅ Payload received successfully');
              }
            },
          );
        },
        onConnectionResult: (String endpointId, Status status) {
          if (status == Status.CONNECTED) {
            _connectedEndpointId = endpointId;
            _connectionState = ConnectionState.connected;
            _onDeviceConnected?.call(endpointId);
            debugPrint('✅ Connected to endpoint: $endpointId');
          } else {
            debugPrint('❌ Connection failed: ${status.toString()}');
          }
        },
        onDisconnected: (String endpointId) {
          _connectedEndpointId = null;
          _connectionState = ConnectionState.disconnected;
          _onDeviceDisconnected?.call();
          debugPrint('🔌 Disconnected from: $endpointId');
        },
      );

      _isAdvertising = true;
      _connectionState = ConnectionState.listening;
      debugPrint('📢 Started advertising on Android');
    } catch (e) {
      debugPrint('❌ Error starting Android advertising: $e');
    }
  }

  /// iOS: Start advertising using Multipeer Connectivity
  Future<void> _startIOSAdvertising() async {
    try {
      await _iosChannel.invokeMethod('startAdvertising', {
        'serviceName': 'airdrop-flutter',
        'displayName': 'AirDrop_User',
      });

      // Set up method call handler for iOS callbacks
      _iosChannel.setMethodCallHandler(_handleIOSCallback);

      _connectionState = ConnectionState.listening;
      debugPrint('📢 Started advertising on iOS');
    } catch (e) {
      debugPrint('❌ Error starting iOS advertising: $e');
    }
  }

  /// Start discovering/connecting to hosts
  /// Platform-specific: Android uses Nearby Connections, iOS uses Multipeer Connectivity
  Future<void> connectToHost(String host, int port,
      void Function(Uint8List data) onFileReceived) async {
    _onFileReceived = onFileReceived;

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop/Web: Use standard sockets
      _socket = await Socket.connect(host, port);
      _socket!.listen((data) {
        onFileReceived(Uint8List.fromList(data));
      });
      _connectionState = ConnectionState.connected;
    } else if (Platform.isAndroid) {
      // Android: Use Nearby Connections
      await _startAndroidDiscovery();
    } else if (Platform.isIOS) {
      // iOS: Use Multipeer Connectivity
      await _startIOSBrowsing();
    }
  }

  /// Android: Start discovering using Nearby Connections
  Future<void> _startAndroidDiscovery() async {
    try {
      // Request permissions
      bool permissionsGranted = await _requestAndroidPermissions();

      if (!permissionsGranted) {
        debugPrint('❌ Permissions not granted');
        return;
      }

      // Start discovery
      await _nearby.startDiscovery(
        'AirDrop_User',
        Strategy.P2P_CLUSTER,
        onEndpointFound:
            (String endpointId, String endpointName, String serviceId) {
          debugPrint('🔍 Found endpoint: $endpointName');
          _onDeviceFound?.call(endpointName);

          // Auto-request connection
          _nearby.requestConnection(
            'AirDrop_User',
            endpointId,
            onConnectionInitiated: (String id, ConnectionInfo info) {
              debugPrint('📡 Connection initiated with: ${info.endpointName}');

              // Auto-accept connection
              _nearby.acceptConnection(
                id,
                onPayLoadRecieved: (endpointId, payload) {
                  if (payload.type == PayloadType.BYTES) {
                    _onFileReceived?.call(payload.bytes!);
                  }
                },
                onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {
                  if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
                    debugPrint('✅ Payload received successfully');
                  }
                },
              );
            },
            onConnectionResult: (String id, Status status) {
              if (status == Status.CONNECTED) {
                _connectedEndpointId = id;
                _connectionState = ConnectionState.connected;
                _onDeviceConnected?.call(id);
                debugPrint('✅ Connected to endpoint: $id');
              } else {
                debugPrint('❌ Connection failed: ${status.toString()}');
              }
            },
            onDisconnected: (String id) {
              _connectedEndpointId = null;
              _connectionState = ConnectionState.disconnected;
              _onDeviceDisconnected?.call();
              debugPrint('🔌 Disconnected from: $id');
            },
          );
        },
        onEndpointLost: (String? endpointId) {
          debugPrint('📵 Lost endpoint: $endpointId');
        },
      );

      _isDiscovering = true;
      _connectionState = ConnectionState.discovering;
      debugPrint('🔍 Started discovery on Android');
    } catch (e) {
      debugPrint('❌ Error starting Android discovery: $e');
    }
  }

  /// iOS: Start browsing using Multipeer Connectivity
  Future<void> _startIOSBrowsing() async {
    try {
      await _iosChannel.invokeMethod('startBrowsing', {
        'serviceName': 'airdrop-flutter',
      });

      _connectionState = ConnectionState.discovering;
      debugPrint('🔍 Started browsing on iOS');
    } catch (e) {
      debugPrint('❌ Error starting iOS browsing: $e');
    }
  }

  /// Handle callbacks from iOS platform channel
  Future<dynamic> _handleIOSCallback(MethodCall call) async {
    switch (call.method) {
      case 'onPeerFound':
        final String peerName = call.arguments['peerName'];
        _onDeviceFound?.call(peerName);
        debugPrint('🔍 iOS: Found peer: $peerName');
        break;

      case 'onPeerConnected':
        final String peerId = call.arguments['peerId'];
        _connectionState = ConnectionState.connected;
        _onDeviceConnected?.call(peerId);
        debugPrint('✅ iOS: Connected to peer: $peerId');
        break;

      case 'onPeerDisconnected':
        _connectionState = ConnectionState.disconnected;
        _onDeviceDisconnected?.call();
        debugPrint('🔌 iOS: Peer disconnected');
        break;

      case 'onDataReceived':
        final Uint8List data = call.arguments['data'];
        _onFileReceived?.call(data);
        debugPrint('📦 iOS: Received data: ${data.length} bytes');
        break;
    }
  }

  /// Send file with progress callback
  /// Platform-specific implementation for Android/iOS/Desktop
  Future<void> sendFile(Uint8List fileBytes, String sessionCode,
      {void Function(double progress)? onProgress,
      bool Function()? shouldCancel}) async {
    final encrypted =
        EncryptionUtils.encryptBytesLegacy(fileBytes, sessionCode);

    if (Platform.isAndroid && _connectedEndpointId != null) {
      // Android: Send via Nearby Connections
      await _sendFileAndroid(encrypted, onProgress, shouldCancel);
    } else if (Platform.isIOS) {
      // iOS: Send via Multipeer Connectivity
      await _sendFileIOS(encrypted, onProgress);
    } else if (_socket != null) {
      // Desktop/Web: Send via socket
      await _sendFileSocket(encrypted, onProgress, shouldCancel);
    } else {
      debugPrint('❌ No connection available to send file');
    }
  }

  /// Android: Send file using Nearby Connections
  Future<void> _sendFileAndroid(
      Uint8List data,
      void Function(double progress)? onProgress,
      bool Function()? shouldCancel) async {
    try {
      await _nearby.sendBytesPayload(
        _connectedEndpointId!,
        data,
      );

      // Note: Nearby Connections doesn't provide granular progress for bytes payload
      // For large files, consider using sendFilePayload instead
      onProgress?.call(1.0);
      debugPrint('✅ Android: File sent successfully');
    } catch (e) {
      debugPrint('❌ Android: Error sending file: $e');
    }
  }

  /// iOS: Send file using Multipeer Connectivity
  Future<void> _sendFileIOS(
      Uint8List data, void Function(double progress)? onProgress) async {
    try {
      await _iosChannel.invokeMethod('sendData', {
        'data': data,
      });

      onProgress?.call(1.0);
      debugPrint('✅ iOS: File sent successfully');
    } catch (e) {
      debugPrint('❌ iOS: Error sending file: $e');
    }
  }

  /// Desktop/Web: Send file using socket
  Future<void> _sendFileSocket(
      Uint8List data,
      void Function(double progress)? onProgress,
      bool Function()? shouldCancel) async {
    const chunkSize = 32 * 1024; // 32KB
    int sent = 0;

    while (sent < data.length) {
      if (shouldCancel != null && shouldCancel()) break;

      final end =
          (sent + chunkSize < data.length) ? sent + chunkSize : data.length;
      _socket!.add(data.sublist(sent, end));
      await _socket!.flush();

      sent = end;
      onProgress?.call(sent / data.length);
    }

    onProgress?.call(1.0);
  }

  /// Stop all connections and clean up resources
  Future<void> close() async {
    // Close socket connections
    _socket?.destroy();
    _serverSocket?.close();
    _socket = null;
    _serverSocket = null;

    // Stop Android Nearby Connections
    if (Platform.isAndroid) {
      if (_isAdvertising) {
        await _nearby.stopAdvertising();
        _isAdvertising = false;
      }
      if (_isDiscovering) {
        await _nearby.stopDiscovery();
        _isDiscovering = false;
      }
      if (_connectedEndpointId != null) {
        await _nearby.disconnectFromEndpoint(_connectedEndpointId!);
        _connectedEndpointId = null;
      }
      await _nearby.stopAllEndpoints();
    }

    // Stop iOS Multipeer Connectivity
    if (Platform.isIOS) {
      try {
        await _iosChannel.invokeMethod('stopSession');
      } catch (e) {
        debugPrint('Error stopping iOS session: $e');
      }
    }

    _connectionState = ConnectionState.disconnected;
    debugPrint('🔌 All connections closed');
  }

  /// Set callback for when a device is found
  void setOnDeviceFound(Function(String deviceName) callback) {
    _onDeviceFound = callback;
  }

  /// Set callback for when a device connects
  void setOnDeviceConnected(Function(String deviceId) callback) {
    _onDeviceConnected = callback;
  }

  /// Set callback for when a device disconnects
  void setOnDeviceDisconnected(Function() callback) {
    _onDeviceDisconnected = callback;
  }

  /// Request Android permissions for Nearby Connections
  Future<bool> _requestAndroidPermissions() async {
    try {
      // For Android 12+ (API 31+), need BLUETOOTH_ADVERTISE, BLUETOOTH_CONNECT, BLUETOOTH_SCAN
      // For Android 6-11, need ACCESS_FINE_LOCATION
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
        Permission.nearbyWifiDevices,
      ].request();

      // Check if all required permissions are granted
      bool allGranted = statuses.values
          .every((status) => status.isGranted || status.isLimited);

      if (!allGranted) {
        debugPrint('❌ Some permissions were denied');
        statuses.forEach((permission, status) {
          debugPrint('  $permission: $status');
        });
      }

      return allGranted;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }
}

/// Connection state enum
enum ConnectionState {
  disconnected,
  discovering,
  listening,
  connecting,
  connected,
}

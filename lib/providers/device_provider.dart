import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/device_model.dart';

class DeviceProvider extends ChangeNotifier {
  // Callback for file available notification
  void Function(Map<String, dynamic> file)? onFileAvailable;

  final List<DeviceModel> _discoveredDevices = [];
  DeviceModel? _currentDevice;
  Timer? _discoveryTimer;
  Timer? _broadcastTimer;
  Timer? _heartbeatTimer;
  bool _isDiscovering = false;
  final NetworkInfo _networkInfo = NetworkInfo();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  // WebSocket connection
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  bool _isConnected = false;

  // Signaling server URL - Make sure this matches your actual server URL
  static const String signalingServerUrl = 'ws://192.168.1.4:3000';

  // HTTP base for REST endpoints derived from WS URL
  static String get httpBase {
    if (signalingServerUrl.startsWith('wss://')) {
      return signalingServerUrl.replaceFirst('wss://', 'https://');
    }
    if (signalingServerUrl.startsWith('ws://')) {
      return signalingServerUrl.replaceFirst('ws://', 'http://');
    }
    return signalingServerUrl;
  }

  List<DeviceModel> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);
  DeviceModel? get currentDevice => _currentDevice;
  bool get isDiscovering => _isDiscovering;
  bool get isConnected => _isConnected;

  // Constructor
  Future<void> initialize() async {
    debugPrint('DeviceProvider: Initializing...');
    await _initializeCurrentDevice();
    await _connectToSignalingServer();
    // Don't start discovery automatically, let the UI trigger it
  }

  Future<void> _initializeCurrentDevice() async {
    try {
      final deviceId = _uuid.v4();
      final deviceName = await _getDeviceName();
      // On web, NetworkInfoPlus and Platform APIs are not supported.
      // Use a safe fallback IP and generic type so the client can announce itself.
      final ipAddress = kIsWeb
          ? '127.0.0.1'
          : (await _networkInfo.getWifiIP() ?? '127.0.0.1');
      final deviceType = await _getDeviceType();

      _currentDevice = DeviceModel(
        id: deviceId,
        name: deviceName,
        ipAddress: ipAddress,
        type: deviceType,
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      debugPrint(
          'DeviceProvider: Current device initialized - ${_currentDevice!.name} (${_currentDevice!.id})');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing current device: $e');
      // Fallback to a minimal current device so discovery/broadcast still works
      try {
        _currentDevice = DeviceModel(
          id: _uuid.v4(),
          name: kIsWeb ? 'Web Browser' : 'Unknown Device',
          ipAddress: '127.0.0.1',
          type: kIsWeb ? DeviceType.windows : DeviceType.unknown,
          isOnline: true,
          lastSeen: DateTime.now(),
        );
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<String> _getDeviceName() async {
    try {
      if (kIsWeb) {
        return 'Web Browser';
      }
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.name}';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return macInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return linuxInfo.name;
      }
    } catch (e) {
      debugPrint('Error getting device name: $e');
    }
    return 'Unknown Device';
  }

  Future<DeviceType> _getDeviceType() async {
    if (kIsWeb) return DeviceType.windows;
    if (Platform.isAndroid) return DeviceType.android;
    if (Platform.isIOS) return DeviceType.ios;
    if (Platform.isWindows) return DeviceType.windows;
    if (Platform.isMacOS) return DeviceType.macos;
    if (Platform.isLinux) return DeviceType.linux;
    return DeviceType.unknown;
  }

  Future<void> _connectToSignalingServer() async {
    try {
      debugPrint('DeviceProvider: Connecting to signaling server...');

      _channel = WebSocketChannel.connect(
        Uri.parse(signalingServerUrl),
      );

      // Wait for connection to be established
      await _channel!.ready;

      _channelSubscription = _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          notifyListeners();
          _attemptReconnection();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
          notifyListeners();
          _attemptReconnection();
        },
      );

      _isConnected = true;
      notifyListeners();
      debugPrint('DeviceProvider: Connected to signaling server successfully');
    } catch (e) {
      debugPrint('Failed to connect to signaling server: $e');
      _isConnected = false;
      notifyListeners();
      _attemptReconnection();
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      debugPrint('DeviceProvider: Received WebSocket message: $message');
      final data = jsonDecode(message as String);
      final messageType = data['type'] as String?;

      switch (messageType) {
        case 'device_announcement':
          _handleDeviceAnnouncement(data);
          break;
        case 'announce_device': // Handle both message types
          _handleDeviceAnnouncement(data);
          break;
        case 'device_list':
          _handleDeviceList(data);
          break;
        case 'device_offline':
          _handleDeviceOffline(data);
          break;
        case 'ping':
          _handlePing(data);
          break;
        case 'pong':
          _handlePong(data);
          break;
        case 'heartbeat':
          _handleHeartbeat(data);
          break;
        case 'file_available':
          _handleFileAvailable(data);
          break;
        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  void _handleFileAvailable(Map<String, dynamic> data) {
    try {
      final file = data['file'] as Map<String, dynamic>;
      debugPrint('DeviceProvider: File available notification: $file');
      // Notify listeners or callback
      if (onFileAvailable != null) {
        onFileAvailable!(file);
      }
    } catch (e) {
      debugPrint('Error handling file_available: $e');
    }
  }

  void _handleDeviceAnnouncement(Map<String, dynamic> data) {
    debugPrint('DeviceProvider: Handling device announcement (raw): $data');
    try {
      if (!data.containsKey('device')) {
        debugPrint(
            'DeviceProvider: Announcement missing device key! Data: $data');
        return;
      }
      final deviceData = data['device'] as Map<String, dynamic>;
      debugPrint('DeviceProvider: Extracted device data: $deviceData');

      final device = DeviceModel(
        id: deviceData['id'] as String? ?? '',
        name: deviceData['name'] as String? ?? '',
        ipAddress: deviceData['ipAddress'] as String? ?? '',
        type: _parseDeviceType(deviceData['type'] as String? ?? 'unknown'),
        isOnline: deviceData['isOnline'] as bool? ?? true,
        lastSeen: DateTime.now(),
      );

      debugPrint('DeviceProvider: Created device object: ${device.toString()}');
      _addOrUpdateDevice(device);
    } catch (e, st) {
      debugPrint('Error handling device announcement: $e');
      debugPrint('Stack trace: $st');
    }
  }

  void _handleDeviceList(Map<String, dynamic> data) {
    debugPrint('DeviceProvider: Handling device list: $data');
    try {
      final devices = data['devices'] as List<dynamic>;
      debugPrint(
          'DeviceProvider: Processing ${devices.length} devices from list');

      for (final deviceData in devices) {
        final device = DeviceModel(
          id: deviceData['id'] as String,
          name: deviceData['name'] as String,
          ipAddress: deviceData['ipAddress'] as String,
          type: _parseDeviceType(deviceData['type'] as String),
          isOnline: deviceData['isOnline'] as bool? ?? true,
          lastSeen: DateTime.now(),
        );
        _addOrUpdateDevice(device);
      }
    } catch (e) {
      debugPrint('Error handling device list: $e');
    }
  }

  void _handleDeviceOffline(Map<String, dynamic> data) {
    try {
      final deviceId = data['deviceId'] as String;
      debugPrint('DeviceProvider: Device going offline: $deviceId');
      updateDeviceStatus(deviceId, false);
    } catch (e) {
      debugPrint('Error handling device offline: $e');
    }
  }

  void _handlePing(Map<String, dynamic> data) {
    try {
      final fromDeviceId = data['fromDeviceId'] as String;
      debugPrint('DeviceProvider: Received ping from: $fromDeviceId');
      _sendPong(fromDeviceId);
    } catch (e) {
      debugPrint('Error handling ping: $e');
    }
  }

  void _handlePong(Map<String, dynamic> data) {
    try {
      final fromDeviceId = data['fromDeviceId'] as String;
      debugPrint('DeviceProvider: Received pong from: $fromDeviceId');
      updateDeviceStatus(fromDeviceId, true);
    } catch (e) {
      debugPrint('Error handling pong: $e');
    }
  }

  void _handleHeartbeat(Map<String, dynamic> data) {
    try {
      final deviceId = data['deviceId'] as String;
      if (deviceId != _currentDevice?.id) {
        updateDeviceStatus(deviceId, true);
      }
    } catch (e) {
      debugPrint('Error handling heartbeat: $e');
    }
  }

  DeviceType _parseDeviceType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'android':
        return DeviceType.android;
      case 'ios':
        return DeviceType.ios;
      case 'windows':
        return DeviceType.windows;
      case 'macos':
        return DeviceType.macos;
      case 'linux':
        return DeviceType.linux;
      default:
        return DeviceType.unknown;
    }
  }

  String _deviceTypeToString(DeviceType type) {
    switch (type) {
      case DeviceType.android:
        return 'android';
      case DeviceType.ios:
        return 'ios';
      case DeviceType.windows:
        return 'windows';
      case DeviceType.macos:
        return 'macos';
      case DeviceType.linux:
        return 'linux';
      case DeviceType.unknown:
        return 'unknown';
    }
  }

  Future<void> startDiscovery() async {
    debugPrint('DeviceProvider: Starting discovery...');

    if (_isDiscovering) {
      debugPrint('DeviceProvider: Discovery already in progress');
      return;
    }

    _isDiscovering = true;
    notifyListeners();

    // Ensure we're connected to the signaling server
    if (!_isConnected) {
      debugPrint('DeviceProvider: Not connected, attempting to connect...');
      await _connectToSignalingServer();
      // Wait a bit for connection to stabilize
      await Future.delayed(const Duration(seconds: 1));
    }

    if (_isConnected) {
      // Clear existing devices
      _discoveredDevices.clear();

      // Start broadcasting our presence
      _startBroadcast();

      // Start heartbeat to keep connection alive
      _startHeartbeat();

      // Request current device list
      _requestDeviceList();

      // Start cleanup timer
      _startCleanupTimer();

      debugPrint('DeviceProvider: Discovery started successfully');
    } else {
      debugPrint('DeviceProvider: Failed to start discovery - not connected');
      _isDiscovering = false;
      notifyListeners();
    }
  }

  void _startBroadcast() {
    _broadcastTimer?.cancel();
    _broadcastTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _broadcastPresence();
    });

    // Broadcast immediately
    _broadcastPresence();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendHeartbeat();
    });
  }

  void _startCleanupTimer() {
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _cleanupOfflineDevices();
    });
  }

  Future<void> _broadcastPresence() async {
    if (_currentDevice == null || !_isConnected) {
      debugPrint(
          'DeviceProvider: Cannot broadcast - no current device or not connected');
      return;
    }

    try {
      final deviceMap = {
        'id': _currentDevice!.id ?? '',
        'name': _currentDevice!.name ?? '',
        'ipAddress': _currentDevice!.ipAddress ?? '',
        'type': _deviceTypeToString(_currentDevice!.type),
        'isOnline': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      debugPrint('DeviceProvider: About to broadcast device: $deviceMap');
      final message = {
        'type': 'announce_device',
        'device': deviceMap,
      };
      debugPrint(
          'DeviceProvider: Full announce_device message (Map): $message');
      final encoded = jsonEncode(message);
      debugPrint('DeviceProvider: Broadcasting presence (JSON): $encoded');
      _channel?.sink.add(encoded);
    } catch (e) {
      debugPrint('Error broadcasting presence: $e');
    }
  }

  void _requestDeviceList() {
    if (!_isConnected) {
      debugPrint('DeviceProvider: Cannot request device list - not connected');
      return;
    }

    try {
      final message = {
        'type': 'request_device_list',
        'fromDeviceId': _currentDevice?.id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      debugPrint(
          'DeviceProvider: Requesting device list: ${jsonEncode(message)}');
      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('Error requesting device list: $e');
    }
  }

  void _sendHeartbeat() {
    if (!_isConnected || _currentDevice == null) return;

    try {
      final message = {
        'type': 'heartbeat',
        'deviceId': _currentDevice!.id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('Error sending heartbeat: $e');
    }
  }

  void _sendPong(String toDeviceId) {
    if (!_isConnected || _currentDevice == null) return;

    try {
      final message = {
        'type': 'pong',
        'fromDeviceId': _currentDevice!.id,
        'toDeviceId': toDeviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('Error sending pong: $e');
    }
  }

  void _addOrUpdateDevice(DeviceModel device) {
    debugPrint(
        'DeviceProvider: Adding/updating device: ${device.name} with ID: ${device.id}');

    // Don't add our own device
    if (device.id == _currentDevice?.id) {
      debugPrint('DeviceProvider: Skipping own device');
      return;
    }

    final existingIndex =
        _discoveredDevices.indexWhere((d) => d.id == device.id);

    if (existingIndex != -1) {
      debugPrint(
          'DeviceProvider: Updating existing device at index $existingIndex');
      _discoveredDevices[existingIndex] = device.copyWith(
        isOnline: true,
        lastSeen: DateTime.now() ?? DateTime.now(),
      );
    } else {
      debugPrint('DeviceProvider: Adding new device to list');
      _discoveredDevices.add(device);
    }

    debugPrint(
        'DeviceProvider: Total discovered devices now: ${_discoveredDevices.length}');
    debugPrint(
        'DeviceProvider: Device list: ${_discoveredDevices.map((d) => '${d.name}(${d.id})').toList()}');

    notifyListeners();
    debugPrint('DeviceProvider: notifyListeners() called');
  }

  // Keep the old method name for backward compatibility
  void addDiscoveredDevice(DeviceModel device) {
    _addOrUpdateDevice(device);
  }

  void removeDiscoveredDevice(String deviceId) {
    debugPrint('DeviceProvider: Removing device: $deviceId');
    _discoveredDevices.removeWhere((device) => device.id == deviceId);
    notifyListeners();
  }

  void updateDeviceStatus(String deviceId, bool isOnline) {
    final index =
        _discoveredDevices.indexWhere((device) => device.id == deviceId);
    if (index != -1) {
      debugPrint(
          'DeviceProvider: Updating device status: $deviceId -> ${isOnline ? 'online' : 'offline'}');
      _discoveredDevices[index] = _discoveredDevices[index].copyWith(
        isOnline: isOnline,
        lastSeen: isOnline
            ? DateTime.now() ?? DateTime.now()
            : _discoveredDevices[index].lastSeen,
      );
      notifyListeners();
    }
  }

  void _cleanupOfflineDevices() {
    final now = DateTime.now();
    final initialCount = _discoveredDevices.length;

    // Remove devices not seen for 5 minutes
    _discoveredDevices.removeWhere((device) {
      final timeSinceLastSeen =
          now.difference(device.lastSeen ?? DateTime.now());
      return timeSinceLastSeen.inMinutes > 5;
    });

    // Mark devices as offline if not seen recently
    bool hasChanges = false;
    for (int i = 0; i < _discoveredDevices.length; i++) {
      final timeSinceLastSeen =
          now.difference(_discoveredDevices[i].lastSeen ?? DateTime.now());
      if (timeSinceLastSeen.inMinutes > 2 && _discoveredDevices[i].isOnline) {
        _discoveredDevices[i] = _discoveredDevices[i].copyWith(isOnline: false);
        hasChanges = true;
      }
    }

    if (_discoveredDevices.length != initialCount || hasChanges) {
      debugPrint(
          'DeviceProvider: Cleaned up devices - removed ${initialCount - _discoveredDevices.length}, marked some offline');
      notifyListeners();
    }
  }

  Future<void> stopDiscovery() async {
    debugPrint('DeviceProvider: Stopping discovery...');

    _isDiscovering = false;
    _discoveryTimer?.cancel();
    _broadcastTimer?.cancel();
    _heartbeatTimer?.cancel();

    // Send offline notification
    if (_isConnected && _currentDevice != null) {
      try {
        final message = {
          'type': 'device_offline',
          'deviceId': _currentDevice!.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        _channel?.sink.add(jsonEncode(message));
        debugPrint('DeviceProvider: Sent offline notification');
      } catch (e) {
        debugPrint('Error sending offline notification: $e');
      }
    }

    notifyListeners();
    debugPrint('DeviceProvider: Discovery stopped');
  }

  void clearDiscoveredDevices() {
    debugPrint('DeviceProvider: Clearing all discovered devices');
    _discoveredDevices.clear();
    notifyListeners();
  }

  Future<bool> pingDevice(DeviceModel device) async {
    if (!_isConnected || _currentDevice == null) return false;

    try {
      final message = {
        'type': 'ping',
        'fromDeviceId': _currentDevice!.id,
        'toDeviceId': device.id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel?.sink.add(jsonEncode(message));

      // Wait for pong response (timeout after 5 seconds)
      final completer = Completer<bool>();
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(false);
          updateDeviceStatus(device.id, false);
        }
      });

      return await completer.future;
    } catch (e) {
      debugPrint('Error pinging device: $e');
      updateDeviceStatus(device.id, false);
      return false;
    }
  }

  void _attemptReconnection() {
    if (!_isConnected) {
      debugPrint('DeviceProvider: Scheduling reconnection attempt...');
      Timer(const Duration(seconds: 5), () {
        if (!_isConnected) {
          debugPrint(
              'DeviceProvider: Attempting to reconnect to signaling server...');
          _connectToSignalingServer();
        }
      });
    }
  }

  @override
  void dispose() {
    debugPrint('DeviceProvider: Disposing...');
    _discoveryTimer?.cancel();
    _broadcastTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}

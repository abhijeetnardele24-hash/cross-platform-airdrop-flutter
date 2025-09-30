import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';


/// Device information model
class DiscoveredDevice {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final String deviceType; // 'android', 'ios', 'windows', 'macos', 'linux'
  final DateTime discoveredAt;
  final bool isOnline;
  final int signalStrength; // 0-100

  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.deviceType,
    DateTime? discoveredAt,
    this.isOnline = true,
    this.signalStrength = 100,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  DiscoveredDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
    String? deviceType,
    DateTime? discoveredAt,
    bool? isOnline,
    int? signalStrength,
  }) {
    return DiscoveredDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      deviceType: deviceType ?? this.deviceType,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      isOnline: isOnline ?? this.isOnline,
      signalStrength: signalStrength ?? this.signalStrength,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'deviceType': deviceType,
      'discoveredAt': discoveredAt.toIso8601String(),
      'isOnline': isOnline,
      'signalStrength': signalStrength,
    };
  }

  factory DiscoveredDevice.fromJson(Map<String, dynamic> json) {
    return DiscoveredDevice(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      port: json['port'],
      deviceType: json['deviceType'],
      discoveredAt: DateTime.parse(json['discoveredAt']),
      isOnline: json['isOnline'] ?? true,
      signalStrength: json['signalStrength'] ?? 100,
    );
  }
}

/// Device discovery service using mDNS/Bonjour
class DeviceDiscoveryService {
  static final DeviceDiscoveryService _instance = DeviceDiscoveryService._internal();
  factory DeviceDiscoveryService() => _instance;
  DeviceDiscoveryService._internal();

  final NetworkInfo _networkInfo = NetworkInfo();
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  final StreamController<List<DiscoveredDevice>> _devicesController =
      StreamController<List<DiscoveredDevice>>.broadcast();

  final Map<String, DiscoveredDevice> _discoveredDevices = {};
  Timer? _scanTimer;
  Timer? _cleanupTimer;
  StreamSubscription? _connectivitySubscription;

  bool _isScanning = false;
  String? _localDeviceId;
  String? _localDeviceName;
  String? _localIpAddress;

  // Configuration
  static const int SCAN_INTERVAL_SECONDS = 5;
  static const int DEVICE_TIMEOUT_SECONDS = 30;
  static const int DISCOVERY_PORT = 8888;
  static const String SERVICE_TYPE = '_airdrop._tcp';

  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;
  List<DiscoveredDevice> get devices => _discoveredDevices.values.toList();
  bool get isScanning => _isScanning;

  /// Initialize the discovery service
  Future<void> initialize() async {
    try {
      await _initializeLocalDevice();
      _setupConnectivityListener();
      debugPrint('✅ Device discovery service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing device discovery: $e');
    }
  }

  /// Initialize local device information
  Future<void> _initializeLocalDevice() async {
    try {
      // Get device ID and name
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _localDeviceId = androidInfo.id;
        _localDeviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _localDeviceId = iosInfo.identifierForVendor ?? 'unknown';
        _localDeviceName = iosInfo.name;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        _localDeviceId = windowsInfo.computerName;
        _localDeviceName = windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        _localDeviceId = macInfo.systemGUID ?? 'unknown';
        _localDeviceName = macInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        _localDeviceId = linuxInfo.machineId ?? 'unknown';
        _localDeviceName = linuxInfo.name;
      }

      // Get local IP address
      _localIpAddress = await _networkInfo.getWifiIP();

      debugPrint('📱 Local device: $_localDeviceName ($_localDeviceId)');
      debugPrint('🌐 Local IP: $_localIpAddress');
    } catch (e) {
      debugPrint('❌ Error getting local device info: $e');
    }
  }

  /// Setup connectivity listener for network changes
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      debugPrint('🔄 Network connectivity changed: $result');
      _handleNetworkChange([result]);
    });
  }

  /// Handle network connectivity changes
  Future<void> _handleNetworkChange(List<ConnectivityResult> results) async {
    if (results.any((result) => result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet)) {
      // Connected to WiFi/Ethernet - start scanning
      debugPrint('✅ Connected to network - starting device discovery');
      await _initializeLocalDevice();
      startScanning();
    } else {
      // Disconnected - stop scanning and clear devices
      debugPrint('❌ Disconnected from network - stopping device discovery');
      stopScanning();
      _clearDevices();
    }
  }

  /// Start scanning for devices
  void startScanning() {
    if (_isScanning) return;

    _isScanning = true;
    debugPrint('🔍 Starting device discovery...');

    // Start periodic scanning
    _scanTimer = Timer.periodic(
      const Duration(seconds: SCAN_INTERVAL_SECONDS),
      (_) => _performScan(),
    );

    // Start cleanup timer
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _cleanupStaleDevices(),
    );

    // Perform initial scan
    _performScan();
  }

  /// Stop scanning for devices
  void stopScanning() {
    if (!_isScanning) return;

    _isScanning = false;
    _scanTimer?.cancel();
    _cleanupTimer?.cancel();
    debugPrint('⏹️ Stopped device discovery');
  }

  /// Perform device scan
  Future<void> _performScan() async {
    try {
      if (_localIpAddress == null) {
        await _initializeLocalDevice();
      }

      // Simulate mDNS/Bonjour discovery
      // In production, use platform-specific implementations:
      // - Android: NSD (Network Service Discovery)
      // - iOS: Bonjour
      // - Desktop: mDNS libraries

      await _scanLocalNetwork();
    } catch (e) {
      debugPrint('❌ Error during scan: $e');
    }
  }

  /// Scan local network for devices
  Future<void> _scanLocalNetwork() async {
    if (_localIpAddress == null) return;

    final parts = _localIpAddress!.split('.');
    if (parts.length != 4) return;

    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

    // Scan subnet (simplified version)
    // In production, use proper mDNS/Bonjour
    for (int i = 1; i <= 255; i++) {
      final ip = '$subnet.$i';
      if (ip == _localIpAddress) continue; // Skip self

      // Try to connect to discovery port
      _checkDevice(ip);
    }
  }

  /// Check if device is available at IP
  Future<void> _checkDevice(String ip) async {
    try {
      final socket = await Socket.connect(
        ip,
        DISCOVERY_PORT,
        timeout: const Duration(seconds: 1),
      );

      // Device found - request device info
      socket.write('DISCOVER\n');

      final response = await socket.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => Uint8List(0),
      );

      if (response.isNotEmpty) {
        final data = String.fromCharCodes(response);
        _handleDeviceResponse(ip, data);
      }

      await socket.close();
    } catch (e) {
      // Device not available or timeout
    }
  }

  /// Handle device discovery response
  void _handleDeviceResponse(String ip, String data) {
    try {
      // Parse device info from response
      // Format: "ID:NAME:TYPE"
      final parts = data.trim().split(':');
      if (parts.length < 3) return;

      final deviceId = parts[0];
      final deviceName = parts[1];
      final deviceType = parts[2];

      final device = DiscoveredDevice(
        id: deviceId,
        name: deviceName,
        ipAddress: ip,
        port: DISCOVERY_PORT,
        deviceType: deviceType,
        isOnline: true,
        signalStrength: 100,
      );

      _addOrUpdateDevice(device);
    } catch (e) {
      debugPrint('❌ Error parsing device response: $e');
    }
  }

  /// Add or update discovered device
  void _addOrUpdateDevice(DiscoveredDevice device) {
    final existing = _discoveredDevices[device.id];

    if (existing == null) {
      // New device discovered
      _discoveredDevices[device.id] = device;
      debugPrint('✅ New device discovered: ${device.name} (${device.ipAddress})');
    } else {
      // Update existing device
      _discoveredDevices[device.id] = device.copyWith(
        discoveredAt: DateTime.now(),
        isOnline: true,
      );
    }

    _notifyListeners();
  }

  /// Manually add a device
  void addDevice(DiscoveredDevice device) {
    _addOrUpdateDevice(device);
  }

  /// Remove a device
  void removeDevice(String deviceId) {
    if (_discoveredDevices.remove(deviceId) != null) {
      debugPrint('🗑️ Device removed: $deviceId');
      _notifyListeners();
    }
  }

  /// Clear all devices
  void _clearDevices() {
    _discoveredDevices.clear();
    _notifyListeners();
  }

  /// Cleanup stale devices
  void _cleanupStaleDevices() {
    final now = DateTime.now();
    final staleDevices = <String>[];

    _discoveredDevices.forEach((id, device) {
      final age = now.difference(device.discoveredAt).inSeconds;
      if (age > DEVICE_TIMEOUT_SECONDS) {
        staleDevices.add(id);
      }
    });

    for (final id in staleDevices) {
      _discoveredDevices[id] = _discoveredDevices[id]!.copyWith(isOnline: false);
    }

    if (staleDevices.isNotEmpty) {
      debugPrint('🧹 Marked ${staleDevices.length} devices as offline');
      _notifyListeners();
    }
  }

  /// Notify listeners of device changes
  void _notifyListeners() {
    if (!_devicesController.isClosed) {
      _devicesController.add(devices);
    }
  }

  /// Get local device info
  Map<String, String> getLocalDeviceInfo() {
    return {
      'id': _localDeviceId ?? 'unknown',
      'name': _localDeviceName ?? 'Unknown Device',
      'ipAddress': _localIpAddress ?? 'unknown',
      'deviceType': _getDeviceType(),
    };
  }

  /// Get device type string
  String _getDeviceType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Dispose resources
  void dispose() {
    stopScanning();
    _connectivitySubscription?.cancel();
    _devicesController.close();
    debugPrint('🗑️ Device discovery service disposed');
  }
}

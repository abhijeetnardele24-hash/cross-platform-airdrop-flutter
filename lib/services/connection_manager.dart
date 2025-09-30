import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'device_discovery_service.dart';
import '../widgets/notification_banner.dart';

/// Connection method enum
enum ConnectionMethod {
  p2p,        // Peer-to-peer (WebRTC, Nearby Connections)
  cloud,      // Cloud signaling server
  direct,     // Direct socket connection
}

/// Connection status enum
enum AirdropConnectionStatus {
  disconnected,
  connecting,
  connected,
  failed,
}

/// Connection quality enum
enum ConnectionQuality {
  excellent,  // > 80%
  good,       // 60-80%
  fair,       // 40-60%
  poor,       // < 40%
}

/// Connection state model
class AirdropConnectionState {
  final AirdropConnectionStatus status;
  final ConnectionMethod? method;
  final ConnectionQuality quality;
  final String? deviceId;
  final String? deviceName;
  final int latency; // in milliseconds
  final DateTime? connectedAt;
  final String? error;

  AirdropConnectionState({
    required this.status,
    this.method,
    this.quality = ConnectionQuality.excellent,
    this.deviceId,
    this.deviceName,
    this.latency = 0,
    this.connectedAt,
    this.error,
  });

  AirdropConnectionState copyWith({
    AirdropConnectionStatus? status,
    ConnectionMethod? method,
    ConnectionQuality? quality,
    String? deviceId,
    String? deviceName,
    int? latency,
    DateTime? connectedAt,
    String? error,
  }) {
    return AirdropConnectionState(
      status: status ?? this.status,
      method: method ?? this.method,
      quality: quality ?? this.quality,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      latency: latency ?? this.latency,
      connectedAt: connectedAt ?? this.connectedAt,
      error: error ?? this.error,
    );
  }
}

/// Connection manager with automatic fallback
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final Connectivity _connectivity = Connectivity();
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();

  final StreamController<AirdropConnectionState> _stateController =
      StreamController<AirdropConnectionState>.broadcast();

  AirdropConnectionState _currentState = AirdropConnectionState(
    status: AirdropConnectionStatus.disconnected,
  );

  Timer? _qualityMonitor;
  Timer? _pingTimer;
  StreamSubscription? _connectivitySubscription;

  // Configuration
  static const List<ConnectionMethod> CONNECTION_PRIORITY = [
    ConnectionMethod.p2p,
    ConnectionMethod.cloud,
    ConnectionMethod.direct,
  ];

  static const int QUALITY_CHECK_INTERVAL_SECONDS = 5;
  static const int PING_INTERVAL_SECONDS = 2;
  static const int MAX_LATENCY_MS = 1000;
  static const int FALLBACK_RETRY_DELAY_SECONDS = 3;

  Stream<AirdropConnectionState> get stateStream => _stateController.stream;
  AirdropConnectionState get currentState => _currentState;
  bool get isConnected => _currentState.status == AirdropConnectionStatus.connected;

  /// Initialize connection manager
  Future<void> initialize() async {
    try {
      await _discoveryService.initialize();
      _setupConnectivityListener();
      debugPrint('✅ Connection manager initialized');
    } catch (e) {
      debugPrint('❌ Error initializing connection manager: $e');
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange([result]);
    });
  }

  /// Handle connectivity changes
  Future<void> _handleConnectivityChange(List<ConnectivityResult> results) async {
    debugPrint('🔄 Connectivity changed: $results');

    if (results.contains(ConnectivityResult.none)) {
      // Lost all connectivity
      await _handleConnectionLoss();
    } else if (isConnected) {
      // Check if we need to switch connection method
      await _checkConnectionQuality();
    }
  }

  /// Connect to a device with automatic fallback
  Future<bool> connectToDevice({
    required String deviceId,
    required String deviceName,
    BuildContext? context,
  }) async {
    debugPrint('🔗 Attempting to connect to: $deviceName ($deviceId)');

    _updateState(_currentState.copyWith(
      status: AirdropConnectionStatus.connecting,
      deviceId: deviceId,
      deviceName: deviceName,
    ));

    // Try connection methods in priority order
    for (final method in CONNECTION_PRIORITY) {
      debugPrint('🔄 Trying connection method: ${method.name}');

      final success = await _tryConnectionMethod(
        method: method,
        deviceId: deviceId,
        deviceName: deviceName,
      );

      if (success) {
        _updateState(_currentState.copyWith(
          status: AirdropConnectionStatus.connected,
          method: method,
          connectedAt: DateTime.now(),
        ));

        _startQualityMonitoring();
        _startPingMonitoring();

        if (context != null) {
          _showConnectionNotification(
            context: context,
            message: 'Connected to $deviceName via ${method.name.toUpperCase()}',
            type: NotificationBannerType.success,
          );
        }

        debugPrint('✅ Connected via ${method.name}');
        return true;
      }

      debugPrint('❌ Failed to connect via ${method.name}');

      // Wait before trying next method
      await Future.delayed(const Duration(seconds: FALLBACK_RETRY_DELAY_SECONDS));
    }

    // All methods failed
    _updateState(_currentState.copyWith(
      status: AirdropConnectionStatus.failed,
      error: 'Unable to establish connection',
    ));

    if (context != null) {
      _showConnectionNotification(
        context: context,
        message: 'Failed to connect to $deviceName',
        type: NotificationBannerType.error,
      );
    }

    debugPrint('❌ All connection methods failed');
    return false;
  }

  /// Try specific connection method
  Future<bool> _tryConnectionMethod({
    required ConnectionMethod method,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      switch (method) {
        case ConnectionMethod.p2p:
          return await _connectViaP2P(deviceId, deviceName);

        case ConnectionMethod.cloud:
          return await _connectViaCloud(deviceId, deviceName);

        case ConnectionMethod.direct:
          return await _connectViaDirect(deviceId, deviceName);
      }
    } catch (e) {
      debugPrint('❌ Error in ${method.name} connection: $e');
      return false;
    }
  }

  /// Connect via P2P (WebRTC/Nearby Connections)
  Future<bool> _connectViaP2P(String deviceId, String deviceName) async {
    // Implement WebRTC or Nearby Connections logic
    // This is a placeholder - integrate with your WebRTC/Nearby services
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate success/failure
    return true; // Replace with actual connection logic
  }

  /// Connect via cloud signaling server
  Future<bool> _connectViaCloud(String deviceId, String deviceName) async {
    // Implement cloud signaling connection
    // This is a placeholder - integrate with your signaling service
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate success/failure
    return true; // Replace with actual connection logic
  }

  /// Connect via direct socket connection
  Future<bool> _connectViaDirect(String deviceId, String deviceName) async {
    // Implement direct socket connection
    // This is a placeholder - integrate with your socket service
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate success/failure
    return false; // Usually fallback option
  }

  /// Handle connection loss
  Future<void> _handleConnectionLoss() async {
    if (!isConnected) return;

    debugPrint('⚠️ Connection lost - attempting to reconnect');

    final previousMethod = _currentState.method;
    final deviceId = _currentState.deviceId;
    final deviceName = _currentState.deviceName;

    _updateState(_currentState.copyWith(
      status: AirdropConnectionStatus.connecting,
    ));

    // Try to reconnect with fallback
    if (deviceId != null && deviceName != null) {
      await connectToDevice(
        deviceId: deviceId,
        deviceName: deviceName,
      );
    } else {
      _updateState(_currentState.copyWith(
        status: AirdropConnectionStatus.disconnected,
      ));
    }
  }

  /// Start quality monitoring
  void _startQualityMonitoring() {
    _qualityMonitor?.cancel();
    _qualityMonitor = Timer.periodic(
      const Duration(seconds: QUALITY_CHECK_INTERVAL_SECONDS),
      (_) => _checkConnectionQuality(),
    );
  }

  /// Start ping monitoring
  void _startPingMonitoring() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: PING_INTERVAL_SECONDS),
      (_) => _measureLatency(),
    );
  }

  /// Check connection quality
  Future<void> _checkConnectionQuality() async {
    if (!isConnected) return;

    try {
      final latency = await _measureLatency();
      final quality = _calculateQuality(latency);

      _updateState(_currentState.copyWith(
        latency: latency,
        quality: quality,
      ));

      // If quality is poor, try to switch to better method
      if (quality == ConnectionQuality.poor) {
        debugPrint('⚠️ Poor connection quality - attempting fallback');
        await _attemptFallback();
      }
    } catch (e) {
      debugPrint('❌ Error checking connection quality: $e');
    }
  }

  /// Measure connection latency
  Future<int> _measureLatency() async {
    final startTime = DateTime.now();

    try {
      // Send ping and wait for pong
      // This is a placeholder - implement actual ping logic
      await Future.delayed(const Duration(milliseconds: 50));

      final endTime = DateTime.now();
      return endTime.difference(startTime).inMilliseconds;
    } catch (e) {
      debugPrint('❌ Error measuring latency: $e');
      return MAX_LATENCY_MS;
    }
  }

  /// Calculate connection quality from latency
  ConnectionQuality _calculateQuality(int latency) {
    if (latency < 100) return ConnectionQuality.excellent;
    if (latency < 250) return ConnectionQuality.good;
    if (latency < 500) return ConnectionQuality.fair;
    return ConnectionQuality.poor;
  }

  /// Attempt fallback to better connection method
  Future<void> _attemptFallback() async {
    final currentMethod = _currentState.method;
    if (currentMethod == null) return;

    final currentIndex = CONNECTION_PRIORITY.indexOf(currentMethod);
    if (currentIndex >= CONNECTION_PRIORITY.length - 1) {
      // Already on last fallback option
      debugPrint('⚠️ Already on last fallback option');
      return;
    }

    // Try next method in priority list
    final nextMethod = CONNECTION_PRIORITY[currentIndex + 1];
    debugPrint('🔄 Falling back to ${nextMethod.name}');

    final deviceId = _currentState.deviceId;
    final deviceName = _currentState.deviceName;

    if (deviceId != null && deviceName != null) {
      final success = await _tryConnectionMethod(
        method: nextMethod,
        deviceId: deviceId,
        deviceName: deviceName,
      );

      if (success) {
        _updateState(_currentState.copyWith(
          method: nextMethod,
          quality: ConnectionQuality.good,
        ));
        debugPrint('✅ Successfully fell back to ${nextMethod.name}');
      }
    }
  }

  /// Disconnect from current device
  Future<void> disconnect({BuildContext? context}) async {
    if (!isConnected) return;

    final deviceName = _currentState.deviceName;

    _qualityMonitor?.cancel();
    _pingTimer?.cancel();

    _updateState(AirdropConnectionState(
      status: AirdropConnectionStatus.disconnected,
    ));

    if (context != null && deviceName != null) {
      _showConnectionNotification(
        context: context,
        message: 'Disconnected from $deviceName',
        type: NotificationBannerType.info,
      );
    }

    debugPrint('🔌 Disconnected');
  }

  /// Update connection state
  void _updateState(AirdropConnectionState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_currentState);
    }
  }

  /// Show connection notification
  void _showConnectionNotification({
    required BuildContext context,
    required String message,
    required NotificationBannerType type,
  }) {
    NotificationBanner.show(
      context: context,
      title: 'Connection',
      message: message,
      type: type,
      duration: const Duration(seconds: 3),
    );
  }

  /// Get connection quality percentage
  int getQualityPercentage() {
    switch (_currentState.quality) {
      case ConnectionQuality.excellent:
        return 100;
      case ConnectionQuality.good:
        return 75;
      case ConnectionQuality.fair:
        return 50;
      case ConnectionQuality.poor:
        return 25;
    }
  }

  /// Get connection quality color
  Color getQualityColor() {
    switch (_currentState.quality) {
      case ConnectionQuality.excellent:
        return Colors.green;
      case ConnectionQuality.good:
        return Colors.lightGreen;
      case ConnectionQuality.fair:
        return Colors.orange;
      case ConnectionQuality.poor:
        return Colors.red;
    }
  }

  /// Dispose resources
  void dispose() {
    _qualityMonitor?.cancel();
    _pingTimer?.cancel();
    _connectivitySubscription?.cancel();
    _stateController.close();
    debugPrint('🗑️ Connection manager disposed');
  }
}

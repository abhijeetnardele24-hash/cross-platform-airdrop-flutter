import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/room_socket_service.dart';

/// Test utility for Nearby Connections (Android) and Multipeer Connectivity (iOS)
class NearbyTest {
  static final RoomSocketService _socketService = RoomSocketService();
  static bool _isAdvertising = false;
  static bool _isDiscovering = false;
  static List<String> _discoveredDevices = [];
  static String? _connectedDevice;
  
  /// Test advertising (hosting)
  static Future<void> testAdvertising() async {
    try {
      debugPrint('🧪 Starting advertising test...');
      
      _socketService.setOnDeviceFound((deviceName) {
        debugPrint('📱 Device found: $deviceName');
        _discoveredDevices.add(deviceName);
      });
      
      _socketService.setOnDeviceConnected((deviceId) {
        debugPrint('✅ Device connected: $deviceId');
        _connectedDevice = deviceId;
      });
      
      _socketService.setOnDeviceDisconnected(() {
        debugPrint('🔌 Device disconnected');
        _connectedDevice = null;
      });
      
      await _socketService.startServer(
        8888, // Port (not used on mobile)
        (data) {
          debugPrint('📦 Received data: ${data.length} bytes');
        },
      );
      
      _isAdvertising = true;
      debugPrint('✅ Advertising started successfully');
      debugPrint('Platform: ${Platform.isAndroid ? "Android (Nearby Connections)" : Platform.isIOS ? "iOS (Multipeer Connectivity)" : "Desktop"}');
    } catch (e) {
      debugPrint('❌ Error starting advertising: $e');
    }
  }
  
  /// Test discovery (connecting)
  static Future<void> testDiscovery() async {
    try {
      debugPrint('🧪 Starting discovery test...');
      
      _socketService.setOnDeviceFound((deviceName) {
        debugPrint('📱 Device found: $deviceName');
        _discoveredDevices.add(deviceName);
      });
      
      _socketService.setOnDeviceConnected((deviceId) {
        debugPrint('✅ Device connected: $deviceId');
        _connectedDevice = deviceId;
      });
      
      _socketService.setOnDeviceDisconnected(() {
        debugPrint('🔌 Device disconnected');
        _connectedDevice = null;
      });
      
      await _socketService.connectToHost(
        'localhost', // Host (not used on mobile)
        8888, // Port (not used on mobile)
        (data) {
          debugPrint('📦 Received data: ${data.length} bytes');
        },
      );
      
      _isDiscovering = true;
      debugPrint('✅ Discovery started successfully');
      debugPrint('Platform: ${Platform.isAndroid ? "Android (Nearby Connections)" : Platform.isIOS ? "iOS (Multipeer Connectivity)" : "Desktop"}');
    } catch (e) {
      debugPrint('❌ Error starting discovery: $e');
    }
  }
  
  /// Test sending data
  static Future<void> testSendData() async {
    try {
      if (_connectedDevice == null) {
        debugPrint('❌ No connected device');
        return;
      }
      
      debugPrint('🧪 Testing data send...');
      
      final testData = Uint8List.fromList('Hello from Flutter AirDrop!'.codeUnits);
      
      await _socketService.sendFile(
        testData,
        'test-session',
        onProgress: (progress) {
          debugPrint('📊 Send progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );
      
      debugPrint('✅ Data sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending data: $e');
    }
  }
  
  /// Stop all connections
  static Future<void> stopAll() async {
    try {
      await _socketService.close();
      _isAdvertising = false;
      _isDiscovering = false;
      _discoveredDevices.clear();
      _connectedDevice = null;
      debugPrint('🔌 All connections stopped');
    } catch (e) {
      debugPrint('❌ Error stopping connections: $e');
    }
  }
  
  /// Show test dialog with UI
  static Future<void> showTestDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => _NearbyTestDialog(),
    );
  }
}

/// Dialog widget for Nearby Connections testing
class _NearbyTestDialog extends StatefulWidget {
  @override
  State<_NearbyTestDialog> createState() => _NearbyTestDialogState();
}

class _NearbyTestDialogState extends State<_NearbyTestDialog> {
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  String _status = 'Not connected';
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.wifi_tethering, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Text('Nearby Connections Test'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Desktop"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Technology: ${Platform.isAndroid ? "Nearby Connections" : Platform.isIOS ? "Multipeer Connectivity" : "Sockets"}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text('Status: $_status'),
            const SizedBox(height: 24),
            
            // Advertising button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAdvertising ? null : () async {
                  setState(() {
                    _isAdvertising = true;
                    _status = 'Advertising...';
                  });
                  await NearbyTest.testAdvertising();
                  setState(() {
                    _status = 'Advertising (waiting for connections)';
                  });
                },
                icon: const Icon(Icons.broadcast_on_personal),
                label: const Text('Start Advertising'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAdvertising ? Colors.grey : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Discovery button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDiscovering ? null : () async {
                  setState(() {
                    _isDiscovering = true;
                    _status = 'Discovering...';
                  });
                  await NearbyTest.testDiscovery();
                  setState(() {
                    _status = 'Discovering (searching for devices)';
                  });
                },
                icon: const Icon(Icons.search),
                label: const Text('Start Discovery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDiscovering ? Colors.grey : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Send test data button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await NearbyTest.testSendData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test data sent! Check console.')),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Send Test Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Stop button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await NearbyTest.stopAll();
                  setState(() {
                    _isAdvertising = false;
                    _isDiscovering = false;
                    _status = 'Stopped';
                  });
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Check the console for detailed logs',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    // Don't stop connections when dialog closes
    super.dispose();
  }
}

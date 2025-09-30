import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/device_discovery_service.dart';
import '../services/connection_manager.dart' as conn_mgr;
import 'dart:io';

/// Device list widget with connection status
class DeviceListWidget extends StatefulWidget {
  final Function(DiscoveredDevice)? onDeviceSelected;
  final bool showConnectionStatus;

  const DeviceListWidget({
    super.key,
    this.onDeviceSelected,
    this.showConnectionStatus = true,
  });

  @override
  State<DeviceListWidget> createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  final conn_mgr.ConnectionManager _connectionManager = conn_mgr.ConnectionManager();

  @override
  void initState() {
    super.initState();
    _discoveryService.startScanning();
  }

  @override
  void dispose() {
    _discoveryService.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: StreamBuilder<List<DiscoveredDevice>>(
            stream: _discoveryService.devicesStream,
            initialData: const [],
            builder: (context, snapshot) {
              final devices = snapshot.data ?? [];

              if (devices.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: devices.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return _buildDeviceCard(devices[index]);
                },
              );
            },
          ),
        ),
        if (widget.showConnectionStatus) _buildConnectionStatus(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _discoveryService.isScanning
                ? Icons.radar
                : Icons.radar_outlined,
            color: _discoveryService.isScanning
                ? Colors.blue
                : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby Devices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  _discoveryService.isScanning
                      ? 'Scanning for devices...'
                      : 'Tap to start scanning',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _discoveryService.isScanning
                  ? Icons.stop_circle
                  : Icons.play_circle,
            ),
            onPressed: () {
              setState(() {
                if (_discoveryService.isScanning) {
                  _discoveryService.stopScanning();
                } else {
                  _discoveryService.startScanning();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No devices found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _discoveryService.isScanning
                ? 'Make sure devices are on the same network'
                : 'Start scanning to discover devices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_discoveryService.isScanning)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _discoveryService.startScanning();
                });
              },
              icon: const Icon(Icons.search),
              label: const Text('Start Scanning'),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DiscoveredDevice device) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _handleDeviceSelection(device),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildDeviceIcon(device),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.ipAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildDeviceStatus(device),
                  ],
                ),
              ),
              _buildSignalStrength(device),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(DiscoveredDevice device) {
    IconData icon;
    Color color;

    switch (device.deviceType.toLowerCase()) {
      case 'android':
        icon = Icons.android;
        color = Colors.green;
        break;
      case 'ios':
        icon = Icons.phone_iphone;
        color = Colors.blue;
        break;
      case 'windows':
        icon = Icons.computer;
        color = Colors.blue[700]!;
        break;
      case 'macos':
        icon = Icons.laptop_mac;
        color = Colors.grey[700]!;
        break;
      case 'linux':
        icon = Icons.computer;
        color = Colors.orange;
        break;
      default:
        icon = Icons.devices;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildDeviceStatus(DiscoveredDevice device) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: device.isOnline ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          device.isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            color: device.isOnline ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSignalStrength(DiscoveredDevice device) {
    final strength = device.signalStrength;
    Color color;
    IconData icon;

    if (strength > 75) {
      color = Colors.green;
      icon = Icons.signal_cellular_4_bar;
    } else if (strength > 50) {
      color = Colors.lightGreen;
      icon = Icons.signal_cellular_alt;
    } else if (strength > 25) {
      color = Colors.orange;
      icon = Icons.signal_cellular_alt_2_bar;
    } else {
      color = Colors.red;
      icon = Icons.signal_cellular_alt_1_bar;
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          '$strength%',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return StreamBuilder<conn_mgr.AirdropConnectionState>(
      stream: _connectionManager.stateStream,
      initialData: _connectionManager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        if (state.status == conn_mgr.AirdropConnectionStatus.disconnected) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(state.status).withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildStatusIcon(state),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getStatusText(state),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state.deviceName != null)
                      Text(
                        state.deviceName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (state.status == conn_mgr.AirdropConnectionStatus.connected) ...[
                _buildQualityIndicator(state),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _connectionManager.disconnect(context: context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(conn_mgr.AirdropConnectionState state) {
    IconData icon;
    Color color;

    switch (state.status) {
      case conn_mgr.AirdropConnectionStatus.connecting:
        icon = Icons.sync;
        color = Colors.orange;
        break;
      case conn_mgr.AirdropConnectionStatus.connected:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case conn_mgr.AirdropConnectionStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.cloud_off;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildQualityIndicator(conn_mgr.AirdropConnectionState state) {
    final quality = _connectionManager.getQualityPercentage();
    final color = _connectionManager.getQualityColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.speed, color: color, size: 20),
        Text(
          '$quality%',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(conn_mgr.AirdropConnectionStatus status) {
    switch (status) {
      case conn_mgr.AirdropConnectionStatus.connecting:
        return Colors.orange;
      case conn_mgr.AirdropConnectionStatus.connected:
        return Colors.green;
      case conn_mgr.AirdropConnectionStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(conn_mgr.AirdropConnectionState state) {
    switch (state.status) {
      case conn_mgr.AirdropConnectionStatus.connecting:
        return 'Connecting...';
      case conn_mgr.AirdropConnectionStatus.connected:
        return 'Connected via ${state.method?.name.toUpperCase() ?? "Unknown"}';
      case conn_mgr.AirdropConnectionStatus.failed:
        return 'Connection Failed';
      default:
        return 'Disconnected';
    }
  }

  Future<void> _handleDeviceSelection(DiscoveredDevice device) async {
    widget.onDeviceSelected?.call(device);

    // Show connection dialog
    final shouldConnect = await _showConnectionDialog(device);

    if (shouldConnect == true && mounted) {
      await _connectionManager.connectToDevice(
        deviceId: device.id,
        deviceName: device.name,
        context: context,
      );
    }
  }

  Future<bool?> _showConnectionDialog(DiscoveredDevice device) async {
    if (Platform.isIOS || Platform.isMacOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Connect to Device'),
          content: Text('Connect to ${device.name}?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, true),
              isDefaultAction: true,
              child: const Text('Connect'),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connect to Device'),
          content: Text('Connect to ${device.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Connect'),
            ),
          ],
        ),
      );
    }
  }
}

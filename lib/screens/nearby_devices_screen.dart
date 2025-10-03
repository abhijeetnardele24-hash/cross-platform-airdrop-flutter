import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/device_provider.dart';
import '../theme/ios_theme.dart';
import '../widgets/device_list_item.dart';

class NearbyDevicesScreen extends StatefulWidget {
  const NearbyDevicesScreen({super.key});

  @override
  State<NearbyDevicesScreen> createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _startScanning();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    _scanController.repeat();
    
    // Auto-stop scanning after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _stopScanning();
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSTheme.cardColor(isDark).withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        middle: Text(
          'Nearby Devices',
          style: IOSTheme.headline.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isScanning ? _stopScanning : _startScanning,
          child: AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _scanAnimation.value * 2 * 3.14159,
                child: Icon(
                  _isScanning ? CupertinoIcons.stop_circle : CupertinoIcons.refresh,
                  color: _isScanning ? IOSTheme.systemRed : IOSTheme.systemBlue,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Scanning Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: IOSTheme.cardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (_isScanning ? IOSTheme.systemBlue : IOSTheme.systemGray)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isScanning)
                              Container(
                                width: 50 * (0.5 + _scanAnimation.value * 0.5),
                                height: 50 * (0.5 + _scanAnimation.value * 0.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: IOSTheme.systemBlue.withOpacity(
                                      1.0 - _scanAnimation.value,
                                    ),
                                    width: 2,
                                  ),
                                ),
                              ),
                            Icon(
                              CupertinoIcons.wifi_exclamationmark,
                              color: _isScanning ? IOSTheme.systemBlue : IOSTheme.systemGray,
                              size: 24,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isScanning ? 'Scanning for devices...' : 'Tap to scan',
                          style: IOSTheme.headline.copyWith(
                            color: IOSTheme.primaryTextColor(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isScanning
                              ? 'Looking for nearby AirDrop devices'
                              : 'Find devices ready to receive files',
                          style: IOSTheme.body.copyWith(
                            color: IOSTheme.secondaryTextColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Device List
            Expanded(
              child: deviceProvider.discoveredDevices.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: deviceProvider.discoveredDevices.length,
                      itemBuilder: (context, index) {
                        final device = deviceProvider.discoveredDevices[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DeviceListItem(
                            device: device,
                            onTap: () => _connectToDevice(device.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: IOSTheme.systemGray.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.device_laptop,
              color: IOSTheme.systemGray,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isScanning ? 'Searching...' : 'No devices found',
            style: IOSTheme.title2.copyWith(
              color: IOSTheme.primaryTextColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _isScanning
                  ? 'Make sure other devices have AirDrop enabled'
                  : 'Tap the scan button to look for nearby devices',
              style: IOSTheme.body.copyWith(
                color: IOSTheme.secondaryTextColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!_isScanning) ...[
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: _startScanning,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.search, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Start Scanning',
                    style: IOSTheme.headline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _connectToDevice(String deviceId) {
    IOSTheme.mediumImpact();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Connect to Device'),
        content: const Text('Would you like to connect to this device for file sharing?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Connect'),
            onPressed: () {
              Navigator.pop(context);
              // Handle device connection
              _handleDeviceConnection(deviceId);
            },
          ),
        ],
      ),
    );
  }

  void _handleDeviceConnection(String deviceId) {
    // Simulate connection process
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Connecting...'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            CupertinoActivityIndicator(),
            SizedBox(height: 16),
            Text('Establishing secure connection'),
          ],
        ),
      ),
    );

    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      
      // Show success
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Connected!'),
          content: const Text('You can now share files with this device.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }
}

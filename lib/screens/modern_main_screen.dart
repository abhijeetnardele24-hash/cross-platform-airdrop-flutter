import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/device_provider.dart';
import '../providers/file_transfer_provider.dart';
import '../models/device_model.dart';
import '../widgets/device_card.dart';
import '../widgets/file_picker_widget.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ModernMainScreen extends StatefulWidget {
  const ModernMainScreen({super.key});

  @override
  State<ModernMainScreen> createState() => _ModernMainScreenState();
}

class _ModernMainScreenState extends State<ModernMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _scanAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isScanning = false;
  List<DeviceModel> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _startDeviceDiscovery();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startDeviceDiscovery() async {
    setState(() {
      _isScanning = true;
    });
    
    _scanAnimationController.repeat();
    
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    await deviceProvider.startDiscovery();
    
    // Simulate device discovery
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isScanning = false;
      _discoveredDevices = deviceProvider.nearbyDevices;
    });
    
    _scanAnimationController.stop();
  }

  void _refreshDevices() {
    IOSTheme.mediumImpact();
    _startDeviceDiscovery();
  }

  Future<void> _pickAndSendFile() async {
    IOSTheme.lightImpact();
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      final fileTransferProvider = Provider.of<FileTransferProvider>(context, listen: false);
      
      for (var file in result.files) {
        if (file.path != null) {
          await fileTransferProvider.sendFile(File(file.path!));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.brightness == Brightness.dark;
        
        return CupertinoPageScaffold(
          backgroundColor: IOSTheme.backgroundColor(isDark),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(isDark),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildHeroSection(isDark),
                      _buildQuickActions(isDark),
                      _buildDeviceDiscovery(isDark),
                      _buildRecentActivity(isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark) {
    return CupertinoSliverNavigationBar(
      backgroundColor: IOSTheme.backgroundColor(isDark).withOpacity(0.9),
      border: null,
      largeTitle: Text(
        'AirShare Pro',
        style: IOSTheme.largeTitle.copyWith(
          color: IOSTheme.primaryTextColor(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _refreshDevices,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: IOSTheme.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                CupertinoIcons.refresh,
                color: IOSTheme.systemBlue,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: IOSTheme.systemGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                CupertinoIcons.settings,
                color: IOSTheme.systemGray,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GlassCard(
        isDark: isDark,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: IOSTheme.getGradient(IOSTheme.blueGradient),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: IOSTheme.systemBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.share,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Files Instantly',
              style: IOSTheme.title2.copyWith(
                color: IOSTheme.primaryTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fast, secure, and seamless file sharing\nacross all your devices',
              textAlign: TextAlign.center,
              style: IOSTheme.body.copyWith(
                color: IOSTheme.secondaryTextColor(isDark),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              isDark: isDark,
              icon: CupertinoIcons.add_circled_solid,
              title: 'Send Files',
              subtitle: 'Pick & Share',
              gradient: IOSTheme.blueGradient,
              onTap: _pickAndSendFile,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              isDark: isDark,
              icon: CupertinoIcons.qrcode,
              title: 'QR Code',
              subtitle: 'Quick Connect',
              gradient: IOSTheme.purpleGradient,
              onTap: () {
                IOSTheme.lightImpact();
                // TODO: Show QR code
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return IOSCard(
      isDark: isDark,
      gradient: gradient,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: IOSTheme.headline.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: IOSTheme.footnote.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceDiscovery(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            children: [
              Text(
                'Nearby Devices',
                style: IOSTheme.title3.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isScanning)
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _scanAnimation.value * 2 * 3.14159,
                      child: Icon(
                        CupertinoIcons.refresh,
                        color: IOSTheme.systemBlue,
                        size: 20,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        if (_isScanning)
          _buildScanningIndicator(isDark)
        else if (_discoveredDevices.isEmpty)
          _buildNoDevicesFound(isDark)
        else
          _buildDeviceList(isDark),
      ],
    );
  }

  Widget _buildScanningIndicator(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: IOSCard(
        isDark: isDark,
        child: Column(
          children: [
            const CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: 16),
            Text(
              'Scanning for devices...',
              style: IOSTheme.body.copyWith(
                color: IOSTheme.primaryTextColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure other devices have AirShare open',
              textAlign: TextAlign.center,
              style: IOSTheme.footnote.copyWith(
                color: IOSTheme.secondaryTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDevicesFound(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: IOSCard(
        isDark: isDark,
        child: Column(
          children: [
            Icon(
              CupertinoIcons.device_phone_portrait,
              color: IOSTheme.secondaryTextColor(isDark),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No devices found',
              style: IOSTheme.headline.copyWith(
                color: IOSTheme.primaryTextColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure other devices are nearby\nand have AirShare open',
              textAlign: TextAlign.center,
              style: IOSTheme.footnote.copyWith(
                color: IOSTheme.secondaryTextColor(isDark),
              ),
            ),
            const SizedBox(height: 16),
            IOSButton(
              text: 'Scan Again',
              icon: CupertinoIcons.refresh,
              onPressed: _refreshDevices,
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = _discoveredDevices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ModernDeviceCard(
            device: device,
            isDark: isDark,
            onTap: () {
              IOSTheme.lightImpact();
              _showDeviceOptions(device);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Text(
            'Recent Activity',
            style: IOSTheme.title3.copyWith(
              color: IOSTheme.primaryTextColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: IOSCard(
            isDark: isDark,
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  color: IOSTheme.secondaryTextColor(isDark),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent activity',
                  style: IOSTheme.headline.copyWith(
                    color: IOSTheme.primaryTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your file transfers will appear here',
                  style: IOSTheme.footnote.copyWith(
                    color: IOSTheme.secondaryTextColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeviceOptions(DeviceModel device) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          device.name,
          style: IOSTheme.headline,
        ),
        message: Text(
          'Choose an action for ${device.name}',
          style: IOSTheme.footnote,
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickAndSendFile();
            },
            child: const Text('Send Files'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Request files
            },
            child: const Text('Request Files'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: View device info
            },
            child: const Text('Device Info'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class ModernDeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool isDark;
  final VoidCallback onTap;

  const ModernDeviceCard({
    super.key,
    required this.device,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IOSCard(
      isDark: isDark,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: IOSTheme.getGradient(_getDeviceGradient()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getDeviceIcon(),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: IOSTheme.headline.copyWith(
                    color: IOSTheme.primaryTextColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${device.deviceType} • ${device.isConnected ? "Connected" : "Available"}',
                  style: IOSTheme.footnote.copyWith(
                    color: IOSTheme.secondaryTextColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: device.isConnected ? IOSTheme.systemGreen : IOSTheme.systemOrange,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (device.deviceType.toLowerCase()) {
      case 'phone':
      case 'mobile':
        return CupertinoIcons.phone;
      case 'tablet':
        return CupertinoIcons.device_phone_portrait;
      case 'laptop':
      case 'computer':
        return CupertinoIcons.desktopcomputer;
      default:
        return CupertinoIcons.device_phone_portrait;
    }
  }

  List<Color> _getDeviceGradient() {
    switch (device.deviceType.toLowerCase()) {
      case 'phone':
      case 'mobile':
        return IOSTheme.blueGradient;
      case 'tablet':
        return IOSTheme.purpleGradient;
      case 'laptop':
      case 'computer':
        return IOSTheme.greenGradient;
      default:
        return IOSTheme.tealGradient;
    }
  }
}

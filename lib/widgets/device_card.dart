import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/ios_theme.dart';
import '../models/device_model.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isDark,
    this.onTap,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return IOSCard(
      isDark: isDark,
      onTap: onTap,
      child: Row(
        children: [
          _buildDeviceIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDeviceInfo(),
          ),
          _buildConnectionStatus(),
        ],
      ),
    );
  }

  Widget _buildDeviceIcon() {
    IconData iconData;
    List<Color> gradientColors;

    switch (device.deviceType.toLowerCase()) {
      case 'phone':
      case 'mobile':
        iconData = CupertinoIcons.phone;
        gradientColors = IOSTheme.blueGradient;
        break;
      case 'tablet':
        iconData = CupertinoIcons.device_phone_portrait;
        gradientColors = IOSTheme.purpleGradient;
        break;
      case 'laptop':
      case 'computer':
        iconData = CupertinoIcons.desktopcomputer;
        gradientColors = IOSTheme.greenGradient;
        break;
      default:
        iconData = CupertinoIcons.device_phone_portrait;
        gradientColors = IOSTheme.tealGradient;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: IOSTheme.getGradient(gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
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
          '${device.deviceType} • ${_getStatusText()}',
          style: IOSTheme.footnote.copyWith(
            color: IOSTheme.secondaryTextColor(isDark),
          ),
        ),
        if (device.lastSeen != null) ...[
          const SizedBox(height: 2),
          Text(
            'Last seen: ${_formatLastSeen()}',
            style: IOSTheme.caption2.copyWith(
              color: IOSTheme.secondaryTextColor(isDark).withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionStatus() {
    Color statusColor;
    IconData statusIcon;

    if (device.isConnected) {
      statusColor = IOSTheme.systemGreen;
      statusIcon = CupertinoIcons.checkmark_circle_fill;
    } else if (device.isAvailable) {
      statusColor = IOSTheme.systemOrange;
      statusIcon = CupertinoIcons.circle_fill;
    } else {
      statusColor = IOSTheme.systemGray;
      statusIcon = CupertinoIcons.circle;
    }

    return Column(
      children: [
        Icon(
          statusIcon,
          color: statusColor,
          size: 16,
        ),
        if (onConnect != null && !device.isConnected) ...[
          const SizedBox(height: 8),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minSize: 0,
            onPressed: () {
              IOSTheme.lightImpact();
              onConnect?.call();
            },
            child: Text(
              'Connect',
              style: IOSTheme.caption1.copyWith(
                color: IOSTheme.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getStatusText() {
    if (device.isConnected) {
      return 'Connected';
    } else if (device.isAvailable) {
      return 'Available';
    } else {
      return 'Offline';
    }
  }

  String _formatLastSeen() {
    if (device.lastSeen == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(device.lastSeen!);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

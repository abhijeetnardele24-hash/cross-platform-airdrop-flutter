import 'package:flutter/cupertino.dart';
import '../models/device_model.dart';

class DeviceListItem extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isConnected;

  const DeviceListItem({
    super.key,
    required this.device,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isSelected
            ? theme.primaryColor.withAlpha(26)
            : theme.scaffoldBackgroundColor,
        border: isSelected
            ? Border.all(
                color: theme.primaryColor.withAlpha(77),
                width: 2,
              )
            : null,
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: theme.primaryColor.withAlpha(77),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildDeviceIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.textTheme.textStyle.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SELECTED',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _getDeviceTypeIcon(),
                            size: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            device.type.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            CupertinoIcons.wifi,
                            size: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              device.ipAddress,
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStatusRow(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildTrailingWidget(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: device.isOnline
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF059669), // emeraldGreen
                  Color(0xFF047857), // darker emerald
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF475569), // slateGray
                  const Color(0xFF334155), // darker slate
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: device.isOnline
                ? const Color(0xFF059669).withValues(alpha: 0.4)
                : const Color(0xFF475569).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: CupertinoColors.white.withAlpha(204),
            blurRadius: 8,
            offset: const Offset(-2, -2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getDeviceTypeIcon(),
              size: 32,
              color: CupertinoColors.white,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: device.isOnline
                    ? const Color(0xFF059669)
                    : const Color(0xFF475569),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: CupertinoColors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withAlpha(51),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceTypeIcon() {
    switch (device.type) {
      case DeviceType.android:
        return CupertinoIcons.device_phone_portrait;
      case DeviceType.ios:
        return CupertinoIcons.device_phone_portrait;
      case DeviceType.windows:
        return CupertinoIcons.desktopcomputer;
      case DeviceType.macos:
        return CupertinoIcons.desktopcomputer;
      default:
        return CupertinoIcons.question;
    }
  }

  Widget _buildStatusRow() {
    if (isConnected) {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: CupertinoColors.systemGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Connected',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: device.isOnline
                ? CupertinoColors.systemGreen.withOpacity(0.1)
                : CupertinoColors.systemGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: device.isOnline
                  ? CupertinoColors.systemGreen.withAlpha(77)
                  : CupertinoColors.systemGrey.withAlpha(77),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: device.isOnline
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemGrey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                device.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 11,
                  color: device.isOnline
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.time,
                size: 12,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getLastSeenText(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingWidget(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    if (isSelected) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withAlpha(204),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.check_mark_circled_solid,
          color: CupertinoColors.white,
          size: 24,
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.systemGrey.withAlpha(77),
          width: 1,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showDeviceInfo(context),
        child: const Icon(
          CupertinoIcons.info_circle,
          color: CupertinoColors.systemGrey,
          size: 20,
        ),
      ),
    );
  }

  String _getLastSeenText() {
    // This logic remains the same
    return ''; // Placeholder, your existing code is fine
  }

  void _showDeviceInfo(BuildContext context) {
    // This logic remains the same
  }

  Widget _buildInfoRow(String label, String value) {
    // This logic remains the same
    return Container(); // Placeholder, your existing code is fine
  }

  String _formatDateTime(DateTime dateTime) {
    // This logic remains the same
    return ''; // Placeholder, your existing code is fine
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:haptic_feedback/haptic_feedback.dart';

/// iOS-style notification banner
class NotificationBanner {
  static OverlayEntry? _currentEntry;
  static bool _isShowing = false;

  /// Show notification banner
  static void show({
    required BuildContext context,
    required String title,
    String? message,
    IconData? icon,
    Color? iconColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    NotificationBannerType type = NotificationBannerType.info,
  }) {
    if (_isShowing) {
      hide();
    }

    Haptics.vibrate(_getHapticType(type));

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (context) => _NotificationBannerWidget(
        title: title,
        message: message,
        icon: icon ?? _getIconForType(type),
        iconColor: iconColor ?? _getColorForType(type),
        duration: duration,
        onTap: onTap,
        onDismiss: hide,
      ),
    );

    overlay.insert(_currentEntry!);
    _isShowing = true;

    // Auto dismiss
    Future.delayed(duration, () {
      hide();
    });
  }

  /// Hide notification banner
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;
  }

  static IconData _getIconForType(NotificationBannerType type) {
    switch (type) {
      case NotificationBannerType.success:
        return CupertinoIcons.check_mark_circled_solid;
      case NotificationBannerType.error:
        return CupertinoIcons.xmark_circle_fill;
      case NotificationBannerType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case NotificationBannerType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }

  static Color _getColorForType(NotificationBannerType type) {
    switch (type) {
      case NotificationBannerType.success:
        return Colors.green;
      case NotificationBannerType.error:
        return Colors.red;
      case NotificationBannerType.warning:
        return Colors.orange;
      case NotificationBannerType.info:
        return Colors.blue;
    }
  }

  static HapticsType _getHapticType(NotificationBannerType type) {
    switch (type) {
      case NotificationBannerType.success:
        return HapticsType.success;
      case NotificationBannerType.error:
        return HapticsType.error;
      case NotificationBannerType.warning:
        return HapticsType.warning;
      case NotificationBannerType.info:
        return HapticsType.selection;
    }
  }
}

enum NotificationBannerType {
  success,
  error,
  warning,
  info,
}

class _NotificationBannerWidget extends StatefulWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Color iconColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _NotificationBannerWidget({
    required this.title,
    this.message,
    required this.icon,
    required this.iconColor,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationBannerWidget> createState() =>
      _NotificationBannerWidgetState();
}

class _NotificationBannerWidgetState extends State<_NotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () {
                Haptics.vibrate(HapticsType.selection);
                widget.onTap?.call();
                _dismiss();
              },
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -5) {
                  _dismiss();
                }
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[900]!.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.iconColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.iconColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.message != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.message!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.xmark,
                              size: 18,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onPressed: _dismiss,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact notification banner
class CompactNotificationBanner {
  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _CompactBannerWidget(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
  }
}

class _CompactBannerWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback onDismiss;

  const _CompactBannerWidget({
    required this.message,
    this.icon,
    this.backgroundColor,
    required this.onDismiss,
  });

  @override
  State<_CompactBannerWidget> createState() => _CompactBannerWidgetState();
}

class _CompactBannerWidgetState extends State<_CompactBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.black87,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

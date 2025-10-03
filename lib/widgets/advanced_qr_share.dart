import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/theme_provider.dart';

class AdvancedQRShareWidget extends StatefulWidget {
  final String data;
  final String? label;
  const AdvancedQRShareWidget({super.key, required this.data, this.label});

  @override
  State<AdvancedQRShareWidget> createState() => _AdvancedQRShareWidgetState();
}

class _AdvancedQRShareWidgetState extends State<AdvancedQRShareWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildHeader(isDark),
            const SizedBox(height: 40),
            _buildQRSection(isDark),
            const SizedBox(height: 32),
            _buildConnectionInfo(isDark),
            const SizedBox(height: 24),
            _buildActionButtons(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: IOSTheme.systemBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.qrcode,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.label ?? 'Share Connection',
          style: IOSTheme.title1.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Scan this QR code to connect and share files',
          style: IOSTheme.body.copyWith(
            color: IOSTheme.secondaryTextColor(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQRSection(bool isDark) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: IOSTheme.systemBlue.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: IOSTheme.systemBlue.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: QrImageView(
                data: widget.data,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                gapless: true,
                padding: const EdgeInsets.all(16),
                errorStateBuilder: (cxt, err) {
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: IOSTheme.separatorColor(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: IOSTheme.systemRed,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'QR Code Error',
                          style: IOSTheme.headline.copyWith(
                            color: IOSTheme.systemRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to generate QR code',
                          style: IOSTheme.body.copyWith(
                            color: IOSTheme.secondaryTextColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionInfo(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IOSTheme.systemTeal.withOpacity(0.1),
            IOSTheme.systemBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: IOSTheme.systemTeal.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: IOSTheme.systemTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.link,
                  color: IOSTheme.systemTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Code',
                      style: IOSTheme.headline.copyWith(
                        color: IOSTheme.primaryTextColor(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share this code manually if needed',
                      style: IOSTheme.caption1.copyWith(
                        color: IOSTheme.secondaryTextColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: IOSTheme.cardColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: IOSTheme.separatorColor(isDark),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data,
                    style: IOSTheme.headline.copyWith(
                      color: IOSTheme.primaryTextColor(isDark),
                      fontWeight: FontWeight.w600,
                      fontFamily: IOSTheme.monoFontFamily,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: _copyToClipboard,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isCopied ? IOSTheme.systemGreen : IOSTheme.systemBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isCopied ? CupertinoIcons.checkmark : CupertinoIcons.doc_on_clipboard,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _shareQRCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [IOSTheme.systemBlue, IOSTheme.systemBlue.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: IOSTheme.systemBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.share, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Share QR',
                        style: IOSTheme.headline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _regenerateCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: IOSTheme.cardColor(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: IOSTheme.separatorColor(isDark),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.refresh,
                        color: IOSTheme.systemBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refresh',
                        style: IOSTheme.headline.copyWith(
                          color: IOSTheme.systemBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: IOSTheme.systemYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: IOSTheme.systemYellow.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: IOSTheme.systemYellow,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Keep this screen open while others scan the QR code to connect',
                  style: IOSTheme.caption1.copyWith(
                    color: IOSTheme.primaryTextColor(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard() {
    IOSTheme.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.data));
    
    setState(() {
      _isCopied = true;
    });

    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });

    // Show success feedback
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: IOSTheme.systemGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Copied!'),
          ],
        ),
        content: const Text('Connection code copied to clipboard'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    // Auto dismiss after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void _shareQRCode() {
    IOSTheme.mediumImpact();
    // Implement QR code sharing functionality
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Share QR Code'),
        content: const Text('QR code sharing functionality will be implemented here.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _regenerateCode() {
    IOSTheme.mediumImpact();
    // Restart animations for visual feedback
    _animationController.reset();
    _animationController.forward();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Refresh Code'),
        content: const Text('A new connection code will be generated.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Refresh'),
            onPressed: () {
              Navigator.pop(context);
              // Implement code regeneration logic here
            },
          ),
        ],
      ),
    );
  }
}

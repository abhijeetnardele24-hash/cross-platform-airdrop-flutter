import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/theme_provider.dart';

class QRShareWidget extends StatefulWidget {
  final String data;
  final String? label;
  const QRShareWidget({super.key, required this.data, this.label});

  @override
  State<QRShareWidget> createState() => _QRShareWidgetState();
}

class _QRShareWidgetState extends State<QRShareWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null) ...[
                  Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: IOSTheme.primaryTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: IOSTheme.spacing16),
                ],
                _buildQRContainer(isDark),
                const SizedBox(height: IOSTheme.spacing16),
                _buildCodeDisplay(isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQRContainer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
        border: Border.all(
          color: IOSTheme.systemBlue.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: IOSTheme.systemBlue.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: QrImageView(
        data: widget.data,
        version: QrVersions.auto,
        size: 200,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        gapless: true,
        errorStateBuilder: (cxt, err) {
          return Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: IOSTheme.separatorColor(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: IOSTheme.systemRed,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'QR Error',
                  style: TextStyle(
                    color: IOSTheme.systemRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCodeDisplay(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: IOSTheme.spacing20, vertical: IOSTheme.spacing16),
      decoration: BoxDecoration(
        gradient: IOSTheme.getGradient(IOSTheme.tealGradient),
        borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: IOSTheme.systemTeal.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.data,
              style: IOSTheme.headline.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: IOSTheme.monoFontFamily,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              IOSTheme.lightImpact();
              Clipboard.setData(ClipboardData(text: widget.data));
              _showCopiedFeedback();
            },
            child: Container(
              padding: const EdgeInsets.all(IOSTheme.spacing8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(IOSTheme.smallRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Icon(
                CupertinoIcons.doc_on_clipboard,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCopiedFeedback() {
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
        content: const Text('Room code copied to clipboard'),
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
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import '../theme/ios_theme.dart';

class EnhancedQRScreen extends StatefulWidget {
  const EnhancedQRScreen({super.key});

  @override
  State<EnhancedQRScreen> createState() => _EnhancedQRScreenState();
}

class _EnhancedQRScreenState extends State<EnhancedQRScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  String _qrData = '';
  bool _isGenerating = false;
  String _deviceName = 'My Device';
  String _connectionCode = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateConnectionCode();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateConnectionCode() {
    final random = Random();
    _connectionCode = (100000 + random.nextInt(900000)).toString();
    _qrData = 'airdrop://connect?device=$_deviceName&code=$_connectionCode&id=${random.nextInt(999999)}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.9),
        border: null,
        middle: Text(
          'QR Share',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showSettings,
          child: Icon(
            CupertinoIcons.settings,
            color: IOSTheme.systemBlue,
            size: 24,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // QR Code Container
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 0.1,
                      child: _buildQRContainer(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Device Info
              _buildDeviceInfo(),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              _buildActionButtons(),
              
              const SizedBox(height: 32),
              
              // Instructions
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRContainer() {
    return Container(
      width: 280,
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _qrData.isNotEmpty
          ? QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              errorStateBuilder: (cxt, err) {
                return Container(
                  child: Center(
                    child: Text(
                      'Something went wrong!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    IOSTheme.systemPurple,
                    IOSTheme.systemPurple.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.qrcode,
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.device_phone_portrait,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deviceName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connection Code: $_connectionCode',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: IOSTheme.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: IOSTheme.systemGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: IOSTheme.systemGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ready for connections',
                  style: TextStyle(
                    color: IOSTheme.systemGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Generate New QR Button
        Container(
          width: double.infinity,
          child: CupertinoButton.filled(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: _isGenerating ? null : _generateNewQR,
            child: _isGenerating
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Generate New QR Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Share QR Button
        Container(
          width: double.infinity,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            onPressed: _shareQR,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.share,
                  color: IOSTheme.systemBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Share QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: IOSTheme.systemBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: IOSTheme.systemBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'How to Connect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInstructionStep(
            '1',
            'Show QR Code',
            'Display this QR code to the person you want to connect with',
            CupertinoIcons.qrcode_viewfinder,
          ),
          
          const SizedBox(height: 12),
          
          _buildInstructionStep(
            '2',
            'Scan & Connect',
            'They scan your QR code with their AirDrop app to connect instantly',
            CupertinoIcons.camera_viewfinder,
          ),
          
          const SizedBox(height: 12),
          
          _buildInstructionStep(
            '3',
            'Start Sharing',
            'Once connected, you can send and receive files seamlessly',
            CupertinoIcons.arrow_2_circlepath,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: IOSTheme.systemBlue.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: IOSTheme.systemBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: IOSTheme.systemBlue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
        Icon(
          icon,
          color: IOSTheme.systemBlue.withOpacity(0.6),
          size: 20,
        ),
      ],
    );
  }

  void _generateNewQR() async {
    setState(() {
      _isGenerating = true;
    });

    HapticFeedback.mediumImpact();
    
    // Simulate generation delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _generateConnectionCode();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isGenerating = false;
    });

    _showSuccess('New QR code generated!');
  }

  void _shareQR() {
    HapticFeedback.lightImpact();
    // Implement QR sharing logic here
    _showInfo('QR code sharing feature will be implemented');
  }

  void _showSettings() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('QR Settings'),
        message: const Text('Customize your QR code settings'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _editDeviceName();
            },
            child: const Text('Change Device Name'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _generateNewQR();
            },
            child: const Text('Generate New Code'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _editDeviceName() {
    final controller = TextEditingController(text: _deviceName);
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Device Name'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: controller,
              placeholder: 'Enter device name',
              maxLength: 20,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              setState(() {
                _deviceName = controller.text.isNotEmpty ? controller.text : 'My Device';
              });
              _generateConnectionCode();
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfo(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Info'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

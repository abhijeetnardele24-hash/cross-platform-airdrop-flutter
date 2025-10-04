import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ios_theme.dart';

class EnhancedReceiveScreen extends StatefulWidget {
  const EnhancedReceiveScreen({super.key});

  @override
  State<EnhancedReceiveScreen> createState() => _EnhancedReceiveScreenState();
}

class _EnhancedReceiveScreenState extends State<EnhancedReceiveScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  
  bool _isListening = true;
  bool _isReceiving = false;
  double _receiveProgress = 0.0;
  String _currentFileName = '';
  String _senderName = '';
  
  final List<ReceivedFile> _receivedFiles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startListening();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scanController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    ));

    if (_isListening) {
      _pulseController.repeat(reverse: true);
      _scanController.repeat();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });
    _pulseController.repeat(reverse: true);
    _scanController.repeat();
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();
    _scanController.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
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
          'Receive Files',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isListening ? _stopListening : _startListening,
          child: Text(
            _isListening ? 'Stop' : 'Start',
            style: TextStyle(
              color: _isListening ? IOSTheme.systemRed : IOSTheme.systemGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              if (_isReceiving) ...[
                _buildReceivingState(),
              ] else if (_isListening) ...[
                _buildListeningState(),
              ] else ...[
                _buildStoppedState(),
              ],
              
              const SizedBox(height: 40),
              
              if (_receivedFiles.isNotEmpty) ...[
                _buildReceivedFiles(),
                const SizedBox(height: 40),
              ],
              
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListeningState() {
    return Column(
      children: [
        // Animated Radar
        Container(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 200 * _pulseAnimation.value,
                    height: 200 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: IOSTheme.systemGreen.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
              
              // Middle ring
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: IOSTheme.systemGreen.withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
              
              // Center icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [IOSTheme.systemGreen, IOSTheme.systemTeal],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: IOSTheme.systemGreen.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.tray_arrow_down_fill,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              
              // Scanning line
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _scanAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: ScanLinePainter(
                          color: IOSTheme.systemGreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Listening for Files',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Your device is ready to receive files from nearby devices',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 24),
        
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: IOSTheme.systemGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: IOSTheme.systemGreen.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: IOSTheme.systemGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Active & Discoverable',
                style: TextStyle(
                  color: IOSTheme.systemGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceivingState() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: IOSTheme.systemBlue.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.arrow_down_circle_fill,
            color: Colors.white,
            size: 60,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Receiving File',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _currentFileName,
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'from $_senderName',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Progress bar
        Container(
          width: double.infinity,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _receiveProgress,
                backgroundColor: CupertinoColors.systemGrey4.resolveFrom(context),
                valueColor: AlwaysStoppedAnimation<Color>(IOSTheme.systemBlue),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Text(
                '${(_receiveProgress * 100).round()}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoppedState() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey3.resolveFrom(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.pause_circle_fill,
            color: Colors.white,
            size: 60,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Not Listening',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Tap "Start" to begin listening for incoming files',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        CupertinoButton.filled(
          onPressed: _startListening,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: const Text(
            'Start Listening',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Received Files',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...(_receivedFiles.map((file) => _buildReceivedFileItem(file)).toList()),
      ],
    );
  }

  Widget _buildReceivedFileItem(ReceivedFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: IOSTheme.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: IOSTheme.systemGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'from ${file.sender} • ${file.size}',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _openFile(file),
            child: Icon(
              CupertinoIcons.square_arrow_up,
              color: IOSTheme.systemBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Column(
          children: [
            // First row
            Row(
              children: [
                Expanded(
                  child: _buildRectangularActionCard(
                    'Scan QR Code',
                    CupertinoIcons.qrcode_viewfinder,
                    [IOSTheme.systemPurple, IOSTheme.systemPurple.withOpacity(0.8)],
                    _scanQRCode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRectangularActionCard(
                    'View History',
                    CupertinoIcons.clock_fill,
                    [IOSTheme.systemOrange, IOSTheme.systemOrange.withOpacity(0.8)],
                    _viewHistory,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Second row
            Row(
              children: [
                Expanded(
                  child: _buildRectangularActionCard(
                    'Settings',
                    CupertinoIcons.settings_solid,
                    [CupertinoColors.systemGrey, CupertinoColors.systemGrey.withOpacity(0.8)],
                    _openSettings,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRectangularActionCard(
                    'Clear All',
                    CupertinoIcons.trash_fill,
                    [IOSTheme.systemRed, IOSTheme.systemRed.withOpacity(0.8)],
                    _clearAll,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRectangularActionCard(
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey2.resolveFrom(context),
              size: 16,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  void _scanQRCode() {
    HapticFeedback.lightImpact();
    // Implement QR scanning logic
    _showInfo('QR code scanning feature will be implemented');
  }

  void _viewHistory() {
    HapticFeedback.lightImpact();
    // Navigate to history screen
    _showInfo('Transfer history feature will be implemented');
  }

  void _openSettings() {
    HapticFeedback.lightImpact();
    // Open receive settings
    _showInfo('Receive settings feature will be implemented');
  }

  void _clearAll() {
    if (_receivedFiles.isEmpty) return;
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Files'),
        content: const Text('Are you sure you want to clear all received files?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              setState(() {
                _receivedFiles.clear();
              });
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _openFile(ReceivedFile file) {
    HapticFeedback.lightImpact();
    // Implement file opening logic
    _showInfo('Opening ${file.name}');
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

class ReceivedFile {
  final String name;
  final String sender;
  final String size;
  final DateTime receivedAt;

  ReceivedFile({
    required this.name,
    required this.sender,
    required this.size,
    required this.receivedAt,
  });
}

class ScanLinePainter extends CustomPainter {
  final Color color;

  ScanLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw scanning line
    canvas.drawLine(
      center,
      Offset(center.dx + radius, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

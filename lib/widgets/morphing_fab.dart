import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/ios_theme.dart';

enum FABState { collapsed, expanded, sending, receiving }

class MorphingFAB extends StatefulWidget {
  final VoidCallback? onSendPressed;
  final VoidCallback? onReceivePressed;
  final VoidCallback? onQRPressed;
  final VoidCallback? onSettingsPressed;
  final bool isTransferActive;
  final double transferProgress;

  const MorphingFAB({
    super.key,
    this.onSendPressed,
    this.onReceivePressed,
    this.onQRPressed,
    this.onSettingsPressed,
    this.isTransferActive = false,
    this.transferProgress = 0.0,
  });

  @override
  State<MorphingFAB> createState() => _MorphingFABState();
}

class _MorphingFABState extends State<MorphingFAB>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _expandController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  
  FABState _currentState = FABState.collapsed;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Main controller for general animations
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Expand controller for menu expansion
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Pulse controller for active states
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress controller for transfer animations
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Scale animation for press feedback
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for state changes
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    // Expand animation for menu items
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation for active states
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Color animation for different states
    _colorAnimation = ColorTween(
      begin: IOSTheme.systemBlue,
      end: IOSTheme.systemGreen,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation if transfer is active
    if (widget.isTransferActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MorphingFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isTransferActive != oldWidget.isTransferActive) {
      if (widget.isTransferActive) {
        _currentState = FABState.sending;
        _pulseController.repeat(reverse: true);
        _progressController.forward();
      } else {
        _currentState = FABState.collapsed;
        _pulseController.stop();
        _progressController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _expandController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _handlePress() {
    _mainController.forward().then((_) {
      _mainController.reverse();
    });
  }

  void _handleActionPress(VoidCallback? callback) {
    HapticFeedback.lightImpact();
    _toggleExpanded();
    callback?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _expandController,
        _pulseController,
        _progressController,
      ]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Background blur effect
            if (_isExpanded) _buildBackgroundBlur(),
            
            // Action buttons
            if (_isExpanded) ..._buildActionButtons(),
            
            // Main FAB
            _buildMainFAB(),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundBlur() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: AnimatedOpacity(
          opacity: _expandAnimation.value * 0.3,
          duration: const Duration(milliseconds: 200),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _expandAnimation.value * 10,
              sigmaY: _expandAnimation.value * 10,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    final actions = [
      _ActionButton(
        icon: CupertinoIcons.paperplane_fill,
        label: 'Send',
        color: IOSTheme.systemBlue,
        onPressed: () => _handleActionPress(widget.onSendPressed),
        delay: 0,
        animation: _expandAnimation,
        position: 0,
      ),
      _ActionButton(
        icon: CupertinoIcons.tray_arrow_down_fill,
        label: 'Receive',
        color: IOSTheme.systemGreen,
        onPressed: () => _handleActionPress(widget.onReceivePressed),
        delay: 50,
        animation: _expandAnimation,
        position: 1,
      ),
      _ActionButton(
        icon: CupertinoIcons.qrcode,
        label: 'QR Share',
        color: IOSTheme.systemPurple,
        onPressed: () => _handleActionPress(widget.onQRPressed),
        delay: 100,
        animation: _expandAnimation,
        position: 2,
      ),
      _ActionButton(
        icon: CupertinoIcons.settings_solid,
        label: 'Settings',
        color: IOSTheme.systemOrange,
        onPressed: () => _handleActionPress(widget.onSettingsPressed),
        delay: 150,
        animation: _expandAnimation,
        position: 3,
      ),
    ];

    return actions;
  }

  Widget _buildMainFAB() {
    final currentColor = widget.isTransferActive 
      ? _colorAnimation.value ?? IOSTheme.systemBlue
      : IOSTheme.systemBlue;

    return Positioned(
      bottom: 16,
      right: 16,
      child: Transform.scale(
        scale: _scaleAnimation.value * 
               (widget.isTransferActive ? _pulseAnimation.value : 1.0),
        child: GestureDetector(
          onTapDown: (_) => _handlePress(),
          onTap: _toggleExpanded,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentColor,
                  currentColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: widget.isTransferActive ? 4 : 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: _buildFABContent(currentColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFABContent(Color color) {
    if (widget.isTransferActive) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Progress indicator
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: widget.transferProgress,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.3),
            ),
          ),
          // Transfer icon
          Icon(
            CupertinoIcons.arrow_up_arrow_down,
            color: Colors.white,
            size: 20,
          ),
        ],
      );
    }

    return Transform.rotate(
      angle: _rotationAnimation.value * math.pi / 4,
      child: Icon(
        _isExpanded ? CupertinoIcons.xmark : CupertinoIcons.plus,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final int delay;
  final Animation<double> animation;
  final int position;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.delay,
    required this.animation,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final offset = 80.0 * (position + 1);
    
    return Positioned(
      bottom: 16 + offset * animation.value,
      right: 16,
      child: Transform.scale(
        scale: animation.value,
        child: Opacity(
          opacity: animation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Button
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Advanced progress FAB for file transfers
class ProgressFAB extends StatefulWidget {
  final double progress;
  final String status;
  final VoidCallback? onCancel;
  final bool isActive;

  const ProgressFAB({
    super.key,
    required this.progress,
    required this.status,
    this.onCancel,
    this.isActive = false,
  });

  @override
  State<ProgressFAB> createState() => _ProgressFABState();
}

class _ProgressFABState extends State<ProgressFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  // late Animation<Color?> _colorAnimation; // Unused for now

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // _colorAnimation setup removed as it's unused

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProgressFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentColor = Color.lerp(
          IOSTheme.systemBlue,
          IOSTheme.systemGreen,
          widget.progress,
        ) ?? IOSTheme.systemBlue;

        return Positioned(
          bottom: 16,
          right: 16,
          child: Transform.scale(
            scale: widget.isActive ? _pulseAnimation.value : 1.0,
            child: GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      currentColor,
                      currentColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress ring
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              value: widget.progress,
                              strokeWidth: 4,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              backgroundColor: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          
                          // Center content
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(widget.progress * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.status,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

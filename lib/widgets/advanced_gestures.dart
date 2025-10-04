import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Advanced gesture detector with multiple gesture support
class AdvancedGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final Function(double)? onPinch;
  final Function(double)? onRotate;
  final VoidCallback? onThreeFingerTap;
  final VoidCallback? onFourFingerTap;
  final Function(Offset)? onPan;
  final bool enableHapticFeedback;
  final Duration gestureTimeout;

  const AdvancedGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onPinch,
    this.onRotate,
    this.onThreeFingerTap,
    this.onFourFingerTap,
    this.onPan,
    this.enableHapticFeedback = true,
    this.gestureTimeout = const Duration(milliseconds: 300),
  });

  @override
  State<AdvancedGestureDetector> createState() => _AdvancedGestureDetectorState();
}

class _AdvancedGestureDetectorState extends State<AdvancedGestureDetector>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  int _tapCount = 0;
  int _fingerCount = 0;
  Offset? _initialPanPosition;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapCount++;
    
    if (_tapCount == 1) {
      // Single tap
      _scaleController.forward().then((_) => _scaleController.reverse());
      if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
      widget.onTap?.call();
      
      // Wait for potential double tap
      Future.delayed(widget.gestureTimeout, () {
        if (_tapCount == 1) {
          _tapCount = 0;
        }
      });
    } else if (_tapCount == 2) {
      // Double tap
      _rotationController.forward().then((_) => _rotationController.reverse());
      if (widget.enableHapticFeedback) HapticFeedback.mediumImpact();
      widget.onDoubleTap?.call();
      _tapCount = 0;
    }
  }

  void _handleLongPress() {
    if (widget.enableHapticFeedback) HapticFeedback.heavyImpact();
    widget.onLongPress?.call();
  }

  void _handlePanStart(DragStartDetails details) {
    _initialPanPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_initialPanPosition != null) {
      final delta = details.localPosition - _initialPanPosition!;
      widget.onPan?.call(delta);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_initialPanPosition != null) {
      final delta = details.velocity.pixelsPerSecond;
      const threshold = 500.0;
      
      if (delta.dx.abs() > delta.dy.abs()) {
        // Horizontal swipe
        if (delta.dx > threshold) {
          if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
          widget.onSwipeRight?.call();
        } else if (delta.dx < -threshold) {
          if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
          widget.onSwipeLeft?.call();
        }
      } else {
        // Vertical swipe
        if (delta.dy > threshold) {
          if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
          widget.onSwipeDown?.call();
        } else if (delta.dy < -threshold) {
          if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
          widget.onSwipeUp?.call();
        }
      }
    }
    _initialPanPosition = null;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _initialScale = 1.0;
    _initialRotation = 0.0;
    _fingerCount = details.pointerCount;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_fingerCount >= 2) {
      // Pinch gesture
      final scaleDelta = details.scale - _initialScale;
      if (scaleDelta.abs() > 0.1) {
        widget.onPinch?.call(details.scale);
        _initialScale = details.scale;
      }
      
      // Rotation gesture
      final rotationDelta = details.rotation - _initialRotation;
      if (rotationDelta.abs() > 0.1) {
        widget.onRotate?.call(details.rotation);
        _initialRotation = details.rotation;
      }
    }
  }

  // Multi-finger tap handling removed to simplify gesture detection

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _rotationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              onLongPress: _handleLongPress,
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// Simplified multi-finger gesture detection
// Note: Complex multi-finger gestures removed to avoid gesture recognizer conflicts

// Swipe gesture detector with customizable sensitivity
class SwipeGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(SwipeDirection)? onSwipe;
  final double sensitivity;
  final double minimumDistance;
  final bool enableHapticFeedback;

  const SwipeGestureDetector({
    super.key,
    required this.child,
    this.onSwipe,
    this.sensitivity = 1.0,
    this.minimumDistance = 50.0,
    this.enableHapticFeedback = true,
  });

  @override
  State<SwipeGestureDetector> createState() => _SwipeGestureDetectorState();
}

class _SwipeGestureDetectorState extends State<SwipeGestureDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  Offset? _startPosition;
  SwipeDirection? _currentDirection;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
    _currentDirection = null;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_startPosition == null) return;
    
    final delta = details.localPosition - _startPosition!;
    final distance = delta.distance;
    
    if (distance > widget.minimumDistance) {
      final direction = _getSwipeDirection(delta);
      if (direction != _currentDirection) {
        _currentDirection = direction;
        _controller.forward().then((_) => _controller.reverse());
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_startPosition == null || _currentDirection == null) return;
    
    if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
    widget.onSwipe?.call(_currentDirection!);
    
    _startPosition = null;
    _currentDirection = null;
  }

  SwipeDirection _getSwipeDirection(Offset delta) {
    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return delta.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.02),
          child: GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: widget.child,
          ),
        );
      },
    );
  }
}

enum SwipeDirection { up, down, left, right }

// Pinch to zoom gesture detector
class PinchZoomDetector extends StatefulWidget {
  final Widget child;
  final Function(double)? onZoomChanged;
  final double minScale;
  final double maxScale;
  final bool enableHapticFeedback;

  const PinchZoomDetector({
    super.key,
    required this.child,
    this.onZoomChanged,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.enableHapticFeedback = true,
  });

  @override
  State<PinchZoomDetector> createState() => _PinchZoomDetectorState();
}

class _PinchZoomDetectorState extends State<PinchZoomDetector> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  void _handleScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(widget.minScale, widget.maxScale);
    });
    
    widget.onZoomChanged?.call(_scale);
    
    // Haptic feedback at scale boundaries
    if (widget.enableHapticFeedback) {
      if (_scale == widget.minScale || _scale == widget.maxScale) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

// Rotation gesture detector
class RotationGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(double)? onRotationChanged;
  final bool enableHapticFeedback;
  final double sensitivity;

  const RotationGestureDetector({
    super.key,
    required this.child,
    this.onRotationChanged,
    this.enableHapticFeedback = true,
    this.sensitivity = 1.0,
  });

  @override
  State<RotationGestureDetector> createState() => _RotationGestureDetectorState();
}

class _RotationGestureDetectorState extends State<RotationGestureDetector> {
  double _rotation = 0.0;
  double _previousRotation = 0.0;

  void _handleScaleStart(ScaleStartDetails details) {
    _previousRotation = _rotation;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _rotation = _previousRotation + (details.rotation * widget.sensitivity);
    });
    
    widget.onRotationChanged?.call(_rotation);
    
    // Haptic feedback every 45 degrees
    if (widget.enableHapticFeedback) {
      final degrees = (_rotation * 180 / math.pi) % 360;
      if (degrees % 45 < 5) {
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: Transform.rotate(
        angle: _rotation,
        child: widget.child,
      ),
    );
  }
}

// Long press with progress indicator
class LongPressProgressDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLongPressCompleted;
  final Duration duration;
  final bool showProgress;
  final Color progressColor;

  const LongPressProgressDetector({
    super.key,
    required this.child,
    this.onLongPressCompleted,
    this.duration = const Duration(milliseconds: 1000),
    this.showProgress = true,
    this.progressColor = Colors.blue,
  });

  @override
  State<LongPressProgressDetector> createState() => _LongPressProgressDetectorState();
}

class _LongPressProgressDetectorState extends State<LongPressProgressDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPressed) {
        HapticFeedback.heavyImpact();
        widget.onLongPressCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (widget.showProgress && _isPressed)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
                    backgroundColor: widget.progressColor.withOpacity(0.3),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

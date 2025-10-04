import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/ios_theme.dart';

// Premium loading indicator with multiple styles
class PremiumLoadingIndicator extends StatefulWidget {
  final LoadingStyle style;
  final double size;
  final Color? color;
  final Duration duration;
  final String? label;

  const PremiumLoadingIndicator({
    super.key,
    this.style = LoadingStyle.pulse,
    this.size = 40.0,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.label,
  });

  @override
  State<PremiumLoadingIndicator> createState() => _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: _getCurveForStyle(widget.style),
    );
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Curve _getCurveForStyle(LoadingStyle style) {
    switch (style) {
      case LoadingStyle.pulse:
        return Curves.easeInOut;
      case LoadingStyle.bounce:
        return Curves.bounceInOut;
      case LoadingStyle.wave:
        return Curves.linear;
      case LoadingStyle.rotate:
        return Curves.linear;
      case LoadingStyle.scale:
        return Curves.elasticInOut;
      case LoadingStyle.fade:
        return Curves.easeInOut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IOSTheme.systemBlue;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return _buildLoadingWidget(color);
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.label!,
            style: IOSTheme.caption1.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget(Color color) {
    switch (widget.style) {
      case LoadingStyle.pulse:
        return _buildPulseLoader(color);
      case LoadingStyle.bounce:
        return _buildBounceLoader(color);
      case LoadingStyle.wave:
        return _buildWaveLoader(color);
      case LoadingStyle.rotate:
        return _buildRotateLoader(color);
      case LoadingStyle.scale:
        return _buildScaleLoader(color);
      case LoadingStyle.fade:
        return _buildFadeLoader(color);
    }
  }

  Widget _buildPulseLoader(Color color) {
    return Transform.scale(
      scale: 0.5 + (_animation.value * 0.5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.8 - (_animation.value * 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10 + (_animation.value * 10),
              spreadRadius: _animation.value * 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBounceLoader(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        final bounceValue = math.sin((_animation.value + delay) * 2 * math.pi);
        
        return Transform.translate(
          offset: Offset(0, bounceValue * 10),
          child: Container(
            width: widget.size / 5,
            height: widget.size / 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWaveLoader(Color color) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: WaveLoadingPainter(
        progress: _animation.value,
        color: color,
      ),
    );
  }

  Widget _buildRotateLoader(Color color) {
    return Transform.rotate(
      angle: _animation.value * 2 * math.pi,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              color.withOpacity(0.1),
              color,
              color.withOpacity(0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildScaleLoader(Color color) {
    return Transform.scale(
      scale: _animation.value,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFadeLoader(Color color) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

enum LoadingStyle { pulse, bounce, wave, rotate, scale, fade }

class WaveLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  WaveLoadingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final animationProgress = (progress + (i * 0.3)) % 1.0;
      final currentRadius = radius * animationProgress;
      final opacity = 1.0 - animationProgress;

      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Skeleton loading screens
class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const SkeletonLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
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
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? 
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ?? 
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                math.max(0.0, _animation.value - 0.3),
                _animation.value,
                math.min(1.0, _animation.value + 0.3),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Skeleton components
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 200,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}

// Premium loading overlay
class PremiumLoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String? message;
  final LoadingStyle style;
  final Color? backgroundColor;
  final bool dismissible;

  const PremiumLoadingOverlay({
    super.key,
    required this.isVisible,
    this.message,
    this.style = LoadingStyle.pulse,
    this.backgroundColor,
    this.dismissible = false,
  });

  @override
  State<PremiumLoadingOverlay> createState() => _PremiumLoadingOverlayState();
}

class _PremiumLoadingOverlayState extends State<PremiumLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PremiumLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    if (!widget.isVisible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.dismissible ? () {} : null,
              child: Container(
                color: widget.backgroundColor ?? Colors.black.withOpacity(0.7),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PremiumLoadingIndicator(
                              style: widget.style,
                              size: 60,
                              color: Colors.white,
                            ),
                            if (widget.message != null) ...[
                              const SizedBox(height: 20),
                              Text(
                                widget.message!,
                                style: IOSTheme.body.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
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

// File transfer loading state
class FileTransferLoadingState extends StatefulWidget {
  final String fileName;
  final double progress;
  final String status;
  final bool isActive;

  const FileTransferLoadingState({
    super.key,
    required this.fileName,
    required this.progress,
    required this.status,
    required this.isActive,
  });

  @override
  State<FileTransferLoadingState> createState() => _FileTransferLoadingStateState();
}

class _FileTransferLoadingStateState extends State<FileTransferLoadingState>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }

    _progressController.animateTo(widget.progress);
  }

  @override
  void didUpdateWidget(FileTransferLoadingState oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }

    if (widget.progress != oldWidget.progress) {
      _progressController.animateTo(widget.progress);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: IOSTheme.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isActive ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: IOSTheme.systemBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_fill,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fileName,
                      style: IOSTheme.headline.copyWith(
                        color: IOSTheme.primaryTextColor(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.status,
                      style: IOSTheme.caption1.copyWith(
                        color: IOSTheme.secondaryTextColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(IOSTheme.systemBlue),
                    minHeight: 6,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(_progressController.value * 100).round()}%',
                        style: IOSTheme.caption1.copyWith(
                          color: IOSTheme.primaryTextColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.isActive)
                        PremiumLoadingIndicator(
                          style: LoadingStyle.pulse,
                          size: 16,
                          color: IOSTheme.systemBlue,
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

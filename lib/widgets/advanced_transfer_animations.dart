import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/ios_theme.dart';

class WaveProgressIndicator extends StatefulWidget {
  final double progress;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final String? label;
  final bool isActive;
  final Duration animationDuration;

  const WaveProgressIndicator({
    super.key,
    required this.progress,
    this.size = 120,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.lightBlue,
    this.label,
    this.isActive = true,
    this.animationDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<WaveProgressIndicator> createState() => _WaveProgressIndicatorState();
}

class _WaveProgressIndicatorState extends State<WaveProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _waveController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _waveController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WaveProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _waveController.repeat();
        _pulseController.repeat(reverse: true);
      } else {
        _waveController.stop();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                
                // Wave progress
                ClipOval(
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: WavePainter(
                      progress: widget.progress,
                      wavePhase: _waveAnimation.value,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                    ),
                  ),
                ),
                
                // Progress text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(widget.progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: widget.size * 0.08,
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color primaryColor;
  final Color secondaryColor;

  WavePainter({
    required this.progress,
    required this.wavePhase,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Calculate water level
    final waterLevel = size.height * (1 - progress);
    
    // Create wave path
    final wavePath = Path();
    final waveHeight = 8.0;
    final waveFrequency = 2.0;
    
    wavePath.moveTo(0, waterLevel);
    
    for (double x = 0; x <= size.width; x += 2) {
      final y = waterLevel + 
                 waveHeight * math.sin((x / size.width) * waveFrequency * 2 * math.pi + wavePhase) +
                 waveHeight * 0.5 * math.sin((x / size.width) * waveFrequency * 4 * math.pi + wavePhase * 1.5);
      wavePath.lineTo(x, y);
    }
    
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    
    // Create gradient paint
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          secondaryColor.withOpacity(0.8),
          primaryColor,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(wavePath, paint);
    
    // Add shimmer effect
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(wavePhase * 0.5),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(wavePath, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PulsingTransferIndicator extends StatefulWidget {
  final bool isActive;
  final String status;
  final IconData icon;
  final Color color;
  final double size;

  const PulsingTransferIndicator({
    super.key,
    required this.isActive,
    required this.status,
    required this.icon,
    required this.color,
    this.size = 80,
  });

  @override
  State<PulsingTransferIndicator> createState() => _PulsingTransferIndicatorState();
}

class _PulsingTransferIndicatorState extends State<PulsingTransferIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(PulsingTransferIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
      } else {
        _pulseController.stop();
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.size + 20,
                    height: widget.size + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                
                // Rotating ring
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: widget.size + 10,
                    height: widget.size + 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          widget.color.withOpacity(0.0),
                          widget.color.withOpacity(0.8),
                          widget.color.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Main circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withOpacity(0.8),
                        widget.color,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: widget.size * 0.4,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              widget.status,
              style: TextStyle(
                color: widget.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class FileTransferAnimation extends StatefulWidget {
  final String fileName;
  final double progress;
  final int fileSize;
  final String transferSpeed;
  final bool isActive;
  final VoidCallback? onCancel;

  const FileTransferAnimation({
    super.key,
    required this.fileName,
    required this.progress,
    required this.fileSize,
    required this.transferSpeed,
    this.isActive = true,
    this.onCancel,
  });

  @override
  State<FileTransferAnimation> createState() => _FileTransferAnimationState();
}

class _FileTransferAnimationState extends State<FileTransferAnimation>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _glowController;
  late List<TransferParticle> _particles;

  @override
  void initState() {
    super.initState();
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particles = List.generate(10, (index) => TransferParticle());

    if (widget.isActive) {
      _particleController.repeat();
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FileTransferAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _particleController.repeat();
        _glowController.repeat(reverse: true);
      } else {
        _particleController.stop();
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: IOSTheme.cardShadow(isDark),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
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
                      _formatFileSize(widget.fileSize),
                      style: IOSTheme.caption1.copyWith(
                        color: IOSTheme.secondaryTextColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (widget.onCancel != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onCancel!();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: IOSTheme.systemRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      color: IOSTheme.systemRed,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress section
          AnimatedBuilder(
            animation: Listenable.merge([_particleController, _glowController]),
            builder: (context, child) {
              return Column(
                children: [
                  // Animated progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        // Progress fill
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: widget.progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: IOSTheme.systemBlue.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Particle overlay
                        CustomPaint(
                          size: Size.infinite,
                          painter: TransferParticlePainter(
                            particles: _particles,
                            progress: widget.progress,
                            animationValue: _particleController.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(widget.progress * 100).round()}% complete',
                        style: IOSTheme.caption1.copyWith(
                          color: IOSTheme.primaryTextColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.transferSpeed,
                        style: IOSTheme.caption1.copyWith(
                          color: IOSTheme.secondaryTextColor(isDark),
                        ),
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

class TransferParticle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;
  late double life;

  TransferParticle() {
    reset();
  }

  void reset() {
    x = 0.0;
    y = math.Random().nextDouble();
    size = 1 + math.Random().nextDouble() * 3;
    speed = 0.5 + math.Random().nextDouble() * 1.5;
    color = [IOSTheme.systemBlue, IOSTheme.systemPurple, IOSTheme.systemTeal]
        [math.Random().nextInt(3)];
    life = 1.0;
  }

  void update(double deltaTime) {
    x += speed * deltaTime;
    life -= deltaTime * 0.5;
    
    if (x > 1.0 || life <= 0) {
      reset();
    }
  }
}

class TransferParticlePainter extends CustomPainter {
  final List<TransferParticle> particles;
  final double progress;
  final double animationValue;

  TransferParticlePainter({
    required this.particles,
    required this.progress,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(0.016); // 60 FPS
      
      if (particle.x <= progress) {
        final paint = Paint()
          ..color = particle.color.withOpacity(particle.life * 0.8)
          ..style = PaintingStyle.fill;

        final position = Offset(
          particle.x * size.width,
          particle.y * size.height,
        );

        canvas.drawCircle(position, particle.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

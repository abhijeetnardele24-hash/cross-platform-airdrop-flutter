import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class Particle {
  late Offset position;
  late Offset velocity;
  late double size;
  late Color color;
  late double life;
  late double maxLife;
  late double rotation;
  late double rotationSpeed;
  late double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.life,
    required this.rotation,
    required this.rotationSpeed,
  }) {
    maxLife = life;
    opacity = 1.0;
  }

  void update(double deltaTime) {
    position += velocity * deltaTime;
    rotation += rotationSpeed * deltaTime;
    life -= deltaTime;
    opacity = (life / maxLife).clamp(0.0, 1.0);
  }

  bool get isDead => life <= 0;
}

class AnimatedParticleSystem extends StatefulWidget {
  final double intensity;
  final int particleCount;
  final List<Color> colors;
  final double minSize;
  final double maxSize;
  final double minSpeed;
  final double maxSpeed;

  const AnimatedParticleSystem({
    super.key,
    required this.intensity,
    required this.particleCount,
    required this.colors,
    this.minSize = 2.0,
    this.maxSize = 8.0,
    this.minSpeed = 20.0,
    this.maxSpeed = 100.0,
  });

  @override
  State<AnimatedParticleSystem> createState() => _AnimatedParticleSystemState();
}

class _AnimatedParticleSystemState extends State<AnimatedParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  late Size _screenSize;
  double _lastTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeParticles();
    });
  }

  void _initializeParticles() {
    final context = this.context;
    if (!mounted) return;
    
    _screenSize = MediaQuery.of(context).size;
    _particles.clear();
    
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_createParticle());
    }
  }

  Particle _createParticle() {
    final x = _random.nextDouble() * _screenSize.width;
    final y = _random.nextDouble() * _screenSize.height;
    
    final angle = _random.nextDouble() * 2 * math.pi;
    final speed = widget.minSpeed + _random.nextDouble() * (widget.maxSpeed - widget.minSpeed);
    
    final velocity = Offset(
      math.cos(angle) * speed,
      math.sin(angle) * speed,
    );
    
    final size = widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize);
    final color = widget.colors[_random.nextInt(widget.colors.length)];
    final life = 2.0 + _random.nextDouble() * 3.0;
    final rotation = _random.nextDouble() * 2 * math.pi;
    final rotationSpeed = (_random.nextDouble() - 0.5) * 4;
    
    return Particle(
      position: Offset(x, y),
      velocity: velocity,
      size: size,
      color: color,
      life: life,
      rotation: rotation,
      rotationSpeed: rotationSpeed,
    );
  }

  void _updateParticles(double currentTime) {
    final deltaTime = currentTime - _lastTime;
    _lastTime = currentTime;
    
    if (deltaTime <= 0) return;
    
    // Update existing particles
    _particles.removeWhere((particle) {
      particle.update(deltaTime / 1000); // Convert to seconds
      
      // Wrap around screen edges
      if (particle.position.dx < -particle.size) {
        particle.position = Offset(_screenSize.width + particle.size, particle.position.dy);
      } else if (particle.position.dx > _screenSize.width + particle.size) {
        particle.position = Offset(-particle.size, particle.position.dy);
      }
      
      if (particle.position.dy < -particle.size) {
        particle.position = Offset(particle.position.dx, _screenSize.height + particle.size);
      } else if (particle.position.dy > _screenSize.height + particle.size) {
        particle.position = Offset(particle.position.dx, -particle.size);
      }
      
      return particle.isDead;
    });
    
    // Add new particles to maintain count
    while (_particles.length < (widget.particleCount * widget.intensity).round()) {
      _particles.add(_createParticle());
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
        final currentTime = DateTime.now().millisecondsSinceEpoch.toDouble();
        _updateParticles(currentTime);
        
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            intensity: widget.intensity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double intensity;

  ParticlePainter({
    required this.particles,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * intensity)
        ..style = PaintingStyle.fill;

      // Create glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * intensity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      // Draw glow
      canvas.drawCircle(Offset.zero, particle.size * 2, glowPaint);
      
      // Draw particle
      canvas.drawCircle(Offset.zero, particle.size, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Advanced floating particles for backgrounds
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final List<Color> colors;
  final double minSize;
  final double maxSize;
  final double speed;
  final bool enableGlow;

  const FloatingParticles({
    super.key,
    this.particleCount = 30,
    this.colors = const [Colors.blue, Colors.purple, Colors.pink],
    this.minSize = 1.0,
    this.maxSize = 4.0,
    this.speed = 0.5,
    this.enableGlow = true,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeParticles();
    });
  }

  void _initializeParticles() {
    if (!mounted) return;
    
    final size = MediaQuery.of(context).size;
    _particles.clear();
    
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(FloatingParticle(
        initialPosition: Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ),
        size: widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize),
        color: widget.colors[_random.nextInt(widget.colors.length)],
        speed: widget.speed * (0.5 + _random.nextDouble()),
        direction: _random.nextDouble() * 2 * math.pi,
        screenSize: size,
      ));
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
        return CustomPaint(
          painter: FloatingParticlePainter(
            particles: _particles,
            progress: _controller.value,
            enableGlow: widget.enableGlow,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class FloatingParticle {
  final Offset initialPosition;
  final double size;
  final Color color;
  final double speed;
  final double direction;
  final Size screenSize;
  late double phase;

  FloatingParticle({
    required this.initialPosition,
    required this.size,
    required this.color,
    required this.speed,
    required this.direction,
    required this.screenSize,
  }) {
    phase = math.Random().nextDouble() * 2 * math.pi;
  }

  Offset getPosition(double progress) {
    final time = progress * 2 * math.pi + phase;
    final x = initialPosition.dx + math.cos(direction + time * speed) * 50;
    final y = initialPosition.dy + math.sin(time * speed * 0.7) * 30 + progress * screenSize.height * 0.1;
    
    return Offset(
      x % screenSize.width,
      y % screenSize.height,
    );
  }

  double getOpacity(double progress) {
    final cycle = (progress * 4 + phase) % (2 * math.pi);
    return (math.sin(cycle) * 0.3 + 0.7).clamp(0.0, 1.0);
  }
}

class FloatingParticlePainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final double progress;
  final bool enableGlow;

  FloatingParticlePainter({
    required this.particles,
    required this.progress,
    required this.enableGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPosition(progress);
      final opacity = particle.getOpacity(progress);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      if (enableGlow) {
        final glowPaint = Paint()
          ..color = particle.color.withOpacity(opacity * 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(position, particle.size * 2, glowPaint);
      }

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Radar-style particle system for device discovery
class RadarParticleSystem extends StatefulWidget {
  final double radius;
  final Color color;
  final int particleCount;
  final double sweepSpeed;

  const RadarParticleSystem({
    super.key,
    required this.radius,
    required this.color,
    this.particleCount = 20,
    this.sweepSpeed = 1.0,
  });

  @override
  State<RadarParticleSystem> createState() => _RadarParticleSystemState();
}

class _RadarParticleSystemState extends State<RadarParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (3000 / widget.sweepSpeed).round()),
      vsync: this,
    )..repeat();
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
        return CustomPaint(
          painter: RadarPainter(
            progress: _controller.value,
            radius: widget.radius,
            color: widget.color,
            particleCount: widget.particleCount,
          ),
          size: Size(widget.radius * 2, widget.radius * 2),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;
  final double radius;
  final Color color;
  final int particleCount;

  RadarPainter({
    required this.progress,
    required this.radius,
    required this.color,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sweepAngle = progress * 2 * math.pi;
    
    // Draw radar sweep
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.6),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweepAngle - math.pi / 6,
      math.pi / 3,
      true,
      sweepPaint,
    );
    
    // Draw particles
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = radius * (0.3 + (i % 3) * 0.2);
      final particlePos = center + Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance,
      );
      
      final angleDiff = ((sweepAngle - angle) % (2 * math.pi));
      final opacity = angleDiff < math.pi / 3 ? (1 - angleDiff / (math.pi / 3)) : 0.0;
      
      if (opacity > 0) {
        final particlePaint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(particlePos, 3, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

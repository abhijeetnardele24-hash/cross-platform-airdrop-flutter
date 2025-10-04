import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/device_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/premium_logo.dart';
import '../widgets/particle_system.dart';
import 'beautiful_main_screen.dart';

class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({super.key});

  @override
  State<PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<PremiumSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<Offset> _logoPosition;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textPosition;
  late Animation<double> _backgroundOpacity;
  late Animation<Color?> _backgroundColor;
  late Animation<double> _particleIntensity;
  late Animation<double> _blurIntensity;
  late Animation<double> _glowIntensity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCinematicSequence();
  }

  void _initializeAnimations() {
    // Master controller for overall timing
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Particle system controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo animations - cinematic entrance
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.9),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -math.pi * 0.5, end: math.pi * 0.1),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: math.pi * 0.1, end: 0.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    _logoPosition = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, -2), end: const Offset(0, 0.1)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    // Text animations - elegant reveal
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _textPosition = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Background animations - dynamic color morphing
    _backgroundColor = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFF000000),
          end: const Color(0xFF0A0A0A),
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFF0A0A0A),
          end: const Color(0xFF1C1C1E),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFF1C1C1E),
          end: const Color(0xFF2C2C2E),
        ),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    // Particle system animations
    _particleIntensity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 0.3),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    // Blur and glow effects
    _blurIntensity = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _glowIntensity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.6),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _masterController,
      curve: Curves.easeInOut,
    ));
  }

  void _startCinematicSequence() async {
    // Haptic feedback for premium feel
    HapticFeedback.heavyImpact();
    
    // Start background animation immediately
    _backgroundController.forward();
    
    // Start particle system
    await Future.delayed(const Duration(milliseconds: 200));
    _particleController.forward();
    
    // Start logo animation with dramatic entrance
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();
    HapticFeedback.mediumImpact();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();
    
    // Start master controller for final effects
    await Future.delayed(const Duration(milliseconds: 800));
    _masterController.forward();
    
    // Navigate to main screen
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      await _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize providers
      await Provider.of<DeviceProvider>(context, listen: false).initialize();
      await Provider.of<DeviceProvider>(context, listen: false).startDiscovery();
      
      if (mounted) {
        // Final haptic feedback
        HapticFeedback.heavyImpact();
        
        // Navigate with cinematic transition
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const BeautifulMainScreen(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const BeautifulMainScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _masterController,
          _logoController,
          _particleController,
          _textController,
          _backgroundController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  _backgroundColor.value ?? Colors.black,
                  Colors.black,
                  const Color(0xFF000000),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Particle background
                Positioned.fill(
                  child: AnimatedParticleSystem(
                    intensity: _particleIntensity.value,
                    particleCount: 50,
                    colors: const [
                      IOSTheme.systemBlue,
                      IOSTheme.systemPurple,
                      IOSTheme.systemTeal,
                      IOSTheme.systemPink,
                    ],
                  ),
                ),
                
                // Blur overlay
                if (_blurIntensity.value > 0)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _blurIntensity.value,
                        sigmaY: _blurIntensity.value,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      
                      // Logo Section with advanced animations
                      SlideTransition(
                        position: _logoPosition,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Transform.rotate(
                            angle: _logoRotation.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: IOSTheme.systemBlue.withOpacity(
                                        _glowIntensity.value * 0.5,
                                      ),
                                      blurRadius: 40 * _glowIntensity.value,
                                      spreadRadius: 10 * _glowIntensity.value,
                                    ),
                                    BoxShadow(
                                      color: IOSTheme.systemPurple.withOpacity(
                                        _glowIntensity.value * 0.3,
                                      ),
                                      blurRadius: 60 * _glowIntensity.value,
                                      spreadRadius: 15 * _glowIntensity.value,
                                    ),
                                  ],
                                ),
                                child: const PremiumLogo(
                                  size: 160,
                                  animate: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Text Section with cinematic reveal
                      SlideTransition(
                        position: _textPosition,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: _buildCinematicTextSection(),
                        ),
                      ),
                      
                      const Spacer(flex: 2),
                      
                      // Loading indicator
                      FadeTransition(
                        opacity: _textOpacity,
                        child: _buildLoadingSection(),
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCinematicTextSection() {
    return Column(
      children: [
        // App name with cinematic styling
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              IOSTheme.systemBlue.withOpacity(0.8),
              IOSTheme.systemPurple.withOpacity(0.6),
              Colors.white.withOpacity(0.9),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(bounds),
          child: Text(
            'AirDrop Pro',
            style: IOSTheme.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w200,
              letterSpacing: 3.0,
              shadows: [
                Shadow(
                  color: IOSTheme.systemBlue.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Subtitle with premium styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            'Next-Generation File Sharing',
            style: IOSTheme.body.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Animated loading dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _masterController,
              builder: (context, child) {
                final delay = index * 0.2;
                final progress = (_masterController.value - delay).clamp(0.0, 1.0);
                final scale = math.sin(progress * math.pi * 2) * 0.5 + 1.0;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            IOSTheme.systemBlue,
                            IOSTheme.systemPurple,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: IOSTheme.systemBlue.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        
        const SizedBox(height: 30),
        
        // Loading text
        Text(
          'Initializing Premium Experience...',
          style: IOSTheme.caption1.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

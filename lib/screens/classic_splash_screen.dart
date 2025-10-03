import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/device_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/premium_logo.dart';
import 'main_tab_screen.dart';

class ClassicSplashScreen extends StatefulWidget {
  const ClassicSplashScreen({super.key});

  @override
  State<ClassicSplashScreen> createState() => _ClassicSplashScreenState();
}

class _ClassicSplashScreenState extends State<ClassicSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textPosition;
  late Animation<double> _progressValue;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations - classic and smooth
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Text animations - elegant entrance
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textPosition = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Progress animation
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Background color transition
    _backgroundColor = ColorTween(
      begin: const Color(0xFF000000),
      end: const Color(0xFF1C1C1E),
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimationSequence() async {
    // Haptic feedback for premium feel
    HapticFeedback.lightImpact();
    
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Start text animation after logo begins
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();
    
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
        // Haptic feedback for navigation
        HapticFeedback.mediumImpact();
        
        // Navigate with classic iOS transition
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const MainTabScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Still navigate even if initialization fails
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const MainTabScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _textController,
          _progressController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColor.value ?? Colors.black,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Logo Section
                  Transform.scale(
                    scale: _logoScale.value,
                    child: Transform.rotate(
                      angle: _logoRotation.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: const PremiumLogo(
                          size: 140,
                          animate: true,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Text Section
                  SlideTransition(
                    position: _textPosition,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: _buildClassicTextSection(),
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Progress Section
                  FadeTransition(
                    opacity: _textOpacity,
                    child: _buildProgressSection(),
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildClassicTextSection() {
    return Column(
      children: [
        // App name with elegant typography
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
              IOSTheme.systemBlue.withOpacity(0.6),
            ],
          ).createShader(bounds),
          child: Text(
            'AirDrop',
            style: IOSTheme.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.0,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Subtitle with classic styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'File Sharing Reimagined',
            style: IOSTheme.body.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress bar
        Container(
          width: 200,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressValue.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    IOSTheme.systemBlue,
                    IOSTheme.systemPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Loading text
        Text(
          'Initializing...',
          style: IOSTheme.caption1.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

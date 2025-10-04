import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/ios_theme.dart';
import '../widgets/particle_system.dart';
import '../widgets/advanced_glassmorphism.dart';

class PremiumOnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const PremiumOnboardingScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  State<PremiumOnboardingScreen> createState() => _PremiumOnboardingScreenState();
}

class _PremiumOnboardingScreenState extends State<PremiumOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _particleController;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  late Animation<Color?> _colorAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Lightning Fast\nFile Sharing',
      subtitle: 'Share files instantly across all your devices with our advanced peer-to-peer technology',
      icon: CupertinoIcons.bolt_fill,
      gradient: [IOSTheme.systemBlue, IOSTheme.systemPurple],
      particles: [IOSTheme.systemBlue, IOSTheme.systemPurple, IOSTheme.systemTeal],
    ),
    OnboardingData(
      title: 'Military Grade\nSecurity',
      subtitle: 'Your files are protected with end-to-end encryption and advanced security protocols',
      icon: CupertinoIcons.shield_fill,
      gradient: [IOSTheme.systemGreen, IOSTheme.systemTeal],
      particles: [IOSTheme.systemGreen, IOSTheme.systemTeal, IOSTheme.systemMint],
    ),
    OnboardingData(
      title: 'Cross Platform\nCompatibility',
      subtitle: 'Works seamlessly across iOS, Android, Windows, macOS, and Linux devices',
      icon: CupertinoIcons.device_laptop,
      gradient: [IOSTheme.systemOrange, IOSTheme.systemYellow],
      particles: [IOSTheme.systemOrange, IOSTheme.systemYellow, IOSTheme.systemRed],
    ),
    OnboardingData(
      title: 'Ready to\nGet Started?',
      subtitle: 'Join millions of users who trust AirDrop Pro for their file sharing needs',
      icon: CupertinoIcons.rocket_fill,
      gradient: [IOSTheme.systemPink, IOSTheme.systemPurple],
      particles: [IOSTheme.systemPink, IOSTheme.systemPurple, IOSTheme.systemIndigo],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController = PageController();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: _pages[0].gradient[0],
      end: _pages[0].gradient[1],
    ).animate(_backgroundController);

    // Start initial animations
    _backgroundController.forward();
    _cardController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _cardController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _handleGetStarted();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleGetStarted() {
    HapticFeedback.heavyImpact();
    widget.onGetStarted();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Update color animation
    _colorAnimation = ColorTween(
      begin: _pages[page].gradient[0],
      end: _pages[page].gradient[1],
    ).animate(_backgroundController);

    // Restart card animation
    _cardController.reset();
    _cardController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _cardController,
          _particleController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  _pages[_currentPage].gradient[0].withOpacity(0.3),
                  _pages[_currentPage].gradient[1].withOpacity(0.1),
                  Colors.black,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Particle background
                Positioned.fill(
                  child: FloatingParticles(
                    particleCount: 40,
                    colors: _pages[_currentPage].particles,
                    minSize: 2,
                    maxSize: 6,
                    speed: 0.3,
                  ),
                ),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Skip button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 60),
                            Text(
                              'AirDrop Pro',
                              style: IOSTheme.headline.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: _handleGetStarted,
                              child: Text(
                                'Skip',
                                style: IOSTheme.body.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Page content
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: _totalPages,
                          itemBuilder: (context, index) {
                            return _buildPage(_pages[index]);
                          },
                        ),
                      ),
                      
                      // Bottom controls
                      _buildBottomControls(),
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

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(),
          
          // 3D Icon with animations
          Transform.scale(
            scale: _cardAnimation.value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_cardAnimation.value * 0.1)
                ..rotateY(_cardAnimation.value * 0.05),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.gradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.gradient[0].withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: data.gradient[1].withOpacity(0.3),
                      blurRadius: 50,
                      spreadRadius: 15,
                      offset: const Offset(0, 20),
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
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        data.icon,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Title with 3D text effect
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _cardController,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            )),
            child: FadeTransition(
              opacity: _cardAnimation,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    data.gradient[0].withOpacity(0.8),
                    data.gradient[1].withOpacity(0.6),
                  ],
                ).createShader(bounds),
                child: Text(
                  data.title,
                  style: IOSTheme.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Subtitle with glass effect
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _cardController,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
            )),
            child: FadeTransition(
              opacity: _cardAnimation,
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 120,
                blur: 20,
                opacity: 0.1,
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: Text(
                    data.subtitle,
                    style: IOSTheme.body.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? _pages[_currentPage].gradient[0]
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _currentPage == index
                      ? [
                          BoxShadow(
                            color: _pages[_currentPage].gradient[0].withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
          
          const SizedBox(height: 40),
          
          // Navigation buttons
          Row(
            children: [
              // Previous button
              if (_currentPage > 0)
                Expanded(
                  child: GlassmorphicButton(
                    onPressed: _previousPage,
                    height: 56,
                    blur: 15,
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.chevron_left,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Back',
                          style: IOSTheme.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              
              const SizedBox(width: 16),
              
              // Next/Get Started button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _pages[_currentPage].gradient,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentPage].gradient[0].withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                                  style: IOSTheme.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage == _totalPages - 1
                                      ? CupertinoIcons.rocket_fill
                                      : CupertinoIcons.chevron_right,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final List<Color> particles;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.particles,
  });
}

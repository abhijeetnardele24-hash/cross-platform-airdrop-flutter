import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/theme_provider.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              IOSTheme.systemBlue.withOpacity(0.1),
              IOSTheme.backgroundColor(isDark),
              IOSTheme.backgroundColor(isDark),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 40),
                        _buildTitle(isDark),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFeatures(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildGetStartedButton(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IOSTheme.systemBlue,
            IOSTheme.systemTeal,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: IOSTheme.systemBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        CupertinoIcons.wifi,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Column(
      children: [
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 24,
            color: IOSTheme.secondaryTextColor(isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AirDrop',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: IOSTheme.primaryTextColor(isDark),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Share files wirelessly across all your devices with ease and security',
          style: TextStyle(
            fontSize: 16,
            color: IOSTheme.secondaryTextColor(isDark),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures(bool isDark) {
    return Column(
      children: [
        _buildFeatureItem(
          isDark,
          CupertinoIcons.bolt_fill,
          'Lightning Fast',
          'Transfer files at incredible speeds',
          IOSTheme.systemOrange,
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          isDark,
          CupertinoIcons.lock_shield_fill,
          'Secure & Private',
          'End-to-end encryption keeps your files safe',
          IOSTheme.systemGreen,
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          isDark,
          CupertinoIcons.device_phone_portrait,
          'Cross Platform',
          'Works seamlessly across iOS, Android & Desktop',
          IOSTheme.systemPurple,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(bool isDark, IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: IOSTheme.primaryTextColor(isDark),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: IOSTheme.secondaryTextColor(isDark),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IOSButton(
          text: 'Get Started',
          onPressed: () {
            IOSTheme.mediumImpact();
            widget.onGetStarted();
          },
          backgroundColor: IOSTheme.systemBlue,
        ),
        const SizedBox(height: 16),
        Text(
          'No account required • Free to use',
          style: TextStyle(
            fontSize: 12,
            color: IOSTheme.secondaryTextColor(isDark),
          ),
        ),
      ],
    );
  }
}

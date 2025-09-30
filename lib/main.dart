import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/ios_style_theme.dart';
import 'widgets/vignette_grain_background.dart';
import 'widgets/animated_gradient_background.dart';
import 'widgets/custom_icon.dart';
import 'providers/device_provider.dart';
import 'providers/file_transfer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/room_provider.dart';
import 'providers/transfer_provider.dart';
import 'screens/home_screen.dart' as home_screen;
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'utils/performance_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure performance optimizations
  PerformanceConfig.configurePerformance();
  PerformanceConfig.optimizeImageCache();

  // Initialize notification service once
  await NotificationService().init(null);

  runApp(const MyApp());
}

class _RootScreen extends StatefulWidget {
  const _RootScreen({super.key});

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    setState(() {
      _showOnboarding = false;
    });
    // Show a welcome notification
    await NotificationService().showNotification(
      title: 'Welcome!',
      body: 'You are ready to share files with AirDrop Pro.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_showOnboarding!) {
      return OnboardingScreen(onGetStarted: _completeOnboarding);
    }
    return const SplashScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider(), lazy: true),
        ChangeNotifierProvider(
            create: (_) => FileTransferProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => RoomProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => TransferProvider(), lazy: true),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            title: 'AirDrop Pro',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
            ],
            theme: ThemeData(
              useMaterial3: true,
              brightness: themeProvider.brightness,
              primarySwatch: Colors.blue,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: themeProvider.brightness,
              ),
            ),
            home: const _RootScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Initialize DeviceProvider and then navigate to home screen after splash
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        // Ensure DeviceProvider is initialized before HomeScreen
        await Provider.of<DeviceProvider>(context, listen: false).initialize();
        await Provider.of<DeviceProvider>(context, listen: false)
            .startDiscovery();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const home_screen.HomeScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedGradientBackground(
        colors: [
          IOSStyleTheme.systemBlue,
          const Color(0xFF5856D6),
          const Color(0xFF007AFF),
        ],
        child: VignetteGrainBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_animation.value * 0.4),
                      child: Transform.rotate(
                        angle: _animation.value * 0.5,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Color(0xFFF0F0F0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 15,
                                offset: const Offset(-5, -5),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: CustomIcon(
                            icon: Icons.wifi_tethering_rounded,
                            size: 70,
                            color: IOSStyleTheme.systemBlue.withOpacity(0.8),
                            animate: true,
                            duration: const Duration(milliseconds: 1200),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.elasticOut,
                  )),
                  child: FadeTransition(
                    opacity: _animation,
                    child: Column(
                      children: [
                        Text(
                          'AirDrop Pro',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Share files wirelessly across devices',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                FadeTransition(
                  opacity: _animation,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
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
}

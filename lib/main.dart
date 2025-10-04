import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/ios_theme.dart';
import 'providers/device_provider.dart';
import 'providers/file_transfer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/room_provider.dart';
import 'providers/transfer_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/premium_onboarding_screen.dart';
import 'screens/simple_splash_screen.dart';
import 'screens/modern_main_screen.dart';
import 'services/notification_service.dart';
import 'utils/performance_config.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions on app start for Android physical devices
  if (!kIsWeb && (Platform.isAndroid)) {
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
      Permission.storage,
    ].request();
  }

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
      return const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    if (_showOnboarding!) {
      return PremiumOnboardingScreen(onGetStarted: _completeOnboarding);
    }
    return const SimpleSplashScreen();
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
          final isDark = themeProvider.brightness == Brightness.dark;
          
          return CupertinoApp(
            title: 'AirDrop',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
            ],
            theme: CupertinoThemeData(
              brightness: themeProvider.brightness,
              primaryColor: IOSTheme.systemBlue,
              scaffoldBackgroundColor: IOSTheme.backgroundColor(isDark),
              barBackgroundColor: IOSTheme.cardColor(isDark),
              textTheme: CupertinoTextThemeData(
                primaryColor: IOSTheme.primaryTextColor(isDark),
                textStyle: IOSTheme.body.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                ),
                actionTextStyle: IOSTheme.body.copyWith(
                  color: IOSTheme.systemBlue,
                ),
                tabLabelTextStyle: IOSTheme.caption1.copyWith(
                  color: IOSTheme.secondaryTextColor(isDark),
                ),
                navTitleTextStyle: IOSTheme.headline.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
                navLargeTitleTextStyle: IOSTheme.largeTitle.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                ),
                navActionTextStyle: IOSTheme.body.copyWith(
                  color: IOSTheme.systemBlue,
                ),
                pickerTextStyle: IOSTheme.body.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                ),
                dateTimePickerTextStyle: IOSTheme.body.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                ),
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


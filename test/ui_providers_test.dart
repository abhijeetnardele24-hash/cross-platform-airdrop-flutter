import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cross_platform_airdrop/main.dart';
import 'package:cross_platform_airdrop/providers/theme_provider.dart';
import 'package:cross_platform_airdrop/providers/locale_provider.dart';
import 'package:cross_platform_airdrop/providers/device_provider.dart';
import 'package:cross_platform_airdrop/providers/room_provider.dart';
import 'package:cross_platform_airdrop/providers/transfer_provider.dart';
import 'package:cross_platform_airdrop/providers/file_transfer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI Providers Tests', () {
    late ThemeProvider themeProvider;
    late LocaleProvider localeProvider;
    late DeviceProvider deviceProvider;
    late RoomProvider roomProvider;
    late TransferProvider transferProvider;
    late FileTransferProvider fileTransferProvider;

    setUp(() {
      themeProvider = ThemeProvider();
      localeProvider = LocaleProvider();
      deviceProvider = DeviceProvider();
      roomProvider = RoomProvider();
      transferProvider = TransferProvider();
      fileTransferProvider = FileTransferProvider();
    });

    testWidgets('App initializes without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(); // Just pump once to avoid timeout from splash screen timer

      // Verify splash screen is shown initially
      expect(find.text('AirDrop'), findsOneWidget);
    });

    testWidgets('Theme provider works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Consumer<ThemeProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Text(
                    provider.brightness == Brightness.dark ? 'Dark' : 'Light',
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Light'), findsOneWidget);

      // Toggle theme
      themeProvider.toggleTheme();
      await tester.pump();

      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('Device provider initializes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<DeviceProvider>.value(
          value: deviceProvider,
          child: MaterialApp(
            home: Consumer<DeviceProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Text(
                    provider.currentDevice?.name ?? 'No Device',
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('No Device'), findsOneWidget);
    });

    testWidgets('Room provider works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<RoomProvider>.value(
          value: roomProvider,
          child: MaterialApp(
            home: Consumer<RoomProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Text(provider.roomCode ?? 'No Room'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('No Room'), findsOneWidget);
    });

    testWidgets('Transfer provider works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<TransferProvider>.value(
          value: transferProvider,
          child: MaterialApp(
            home: Consumer<TransferProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Text('Tasks: ${provider.tasks.length}'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Tasks: 0'), findsOneWidget);
    });

    testWidgets('File transfer provider initializes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<FileTransferProvider>.value(
          value: fileTransferProvider,
          child: MaterialApp(
            home: Consumer<FileTransferProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Text('Active: ${provider.activeTransfers.length}'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Active: 0'), findsOneWidget);
    });
  });
}

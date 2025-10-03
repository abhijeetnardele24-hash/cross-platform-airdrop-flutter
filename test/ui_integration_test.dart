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

  group('UI Integration Tests', () {
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
      expect(find.text('File Sharing Reimagined'), findsOneWidget);
    });

    testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
            ChangeNotifierProvider<DeviceProvider>.value(value: deviceProvider),
            ChangeNotifierProvider<RoomProvider>.value(value: roomProvider),
            ChangeNotifierProvider<TransferProvider>.value(value: transferProvider),
            ChangeNotifierProvider<FileTransferProvider>.value(value: fileTransferProvider),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pump();

      // Check for splash screen elements
      expect(find.text('AirDrop'), findsOneWidget);
      expect(find.text('File Sharing Reimagined'), findsOneWidget);
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

    testWidgets('Locale provider works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            home: Consumer<LocaleProvider>(
              builder: (context, provider, child) {
                return Scaffold(
                  body: Text(provider.locale.languageCode),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('en'), findsOneWidget);
    });

    testWidgets('Room provider initializes', (WidgetTester tester) async {
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

    testWidgets('All providers work together', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
            ChangeNotifierProvider<DeviceProvider>.value(value: deviceProvider),
            ChangeNotifierProvider<RoomProvider>.value(value: roomProvider),
            ChangeNotifierProvider<TransferProvider>.value(value: transferProvider),
            ChangeNotifierProvider<FileTransferProvider>.value(value: fileTransferProvider),
          ],
          child: MaterialApp(
            home: Consumer6<ThemeProvider, LocaleProvider, DeviceProvider, 
                RoomProvider, TransferProvider, FileTransferProvider>(
              builder: (context, theme, locale, device, room, transfer, fileTransfer, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Theme: ${theme.brightness == Brightness.dark ? 'Dark' : 'Light'}'),
                      Text('Locale: ${locale.locale.languageCode}'),
                      Text('Device: ${device.currentDevice?.name ?? 'None'}'),
                      Text('Room: ${room.roomCode ?? 'None'}'),
                      Text('Tasks: ${transfer.tasks.length}'),
                      Text('Active: ${fileTransfer.activeTransfers.length}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Theme: Light'), findsOneWidget);
      expect(find.text('Locale: en'), findsOneWidget);
      expect(find.text('Device: None'), findsOneWidget);
      expect(find.text('Room: None'), findsOneWidget);
      expect(find.text('Tasks: 0'), findsOneWidget);
      expect(find.text('Active: 0'), findsOneWidget);
    });
  });
}

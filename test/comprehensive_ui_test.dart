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
import 'package:cross_platform_airdrop/screens/home_screen.dart';
import 'package:cross_platform_airdrop/widgets/trusted_devices_page.dart';
import 'package:cross_platform_airdrop/widgets/file_picker_widget.dart';
import 'package:cross_platform_airdrop/widgets/qr_share_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive UI Tests', () {
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

    testWidgets('App initializes without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester
          .pump(); // Just pump once to avoid timeout from splash screen timer

      // Verify splash screen is shown initially
      expect(find.text('AirDrop Pro'), findsOneWidget);
      expect(
          find.text('Share files wirelessly across devices'), findsOneWidget);
    });

    testWidgets('Splash screen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Check for splash screen elements
      expect(find.text('AirDrop Pro'), findsOneWidget);
      expect(
          find.text('Share files wirelessly across devices'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Home screen loads with all tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check app bar elements
      expect(find.text('AirDrop Flutter'), findsOneWidget);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);

      // Check tab bar - use more specific finders
      expect(find.byType(TabBar), findsOneWidget);
      expect(
          find.descendant(of: find.byType(TabBar), matching: find.text('Send')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(TabBar), matching: find.text('Receive')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(TabBar), matching: find.text('History')),
          findsOneWidget);

      // Check bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Theme toggle works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find theme toggle button (should be dark_mode initially)
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Tap theme toggle
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle();

      // Should now show light_mode icon
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('Tab navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Send tab
      expect(find.text('Create Room'), findsOneWidget);

      // Switch to Receive tab
      await tester.tap(find.descendant(
          of: find.byType(TabBar), matching: find.text('Receive')));
      await tester.pumpAndSettle();
      expect(find.text('Receive Files'), findsOneWidget);

      // Switch to History tab
      await tester.tap(find.descendant(
          of: find.byType(TabBar), matching: find.text('History')));
      await tester.pumpAndSettle();
      expect(find.text('Transfer Statistics'), findsOneWidget);
      expect(find.text('No transfer history'), findsOneWidget);
    });

    testWidgets('Bottom navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Send tab
      expect(find.text('Create Room'), findsOneWidget);

      // Tap bottom navigation Receive
      await tester.tap(find.byIcon(Icons.arrow_downward).last);
      await tester.pumpAndSettle();
      expect(find.text('Receive Files'), findsOneWidget);

      // Tap bottom navigation History
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      expect(find.text('Transfer Statistics'), findsOneWidget);
    });

    testWidgets('Room creation and joining UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for Create Room button
      expect(find.text('Create Room'), findsOneWidget);
      expect(find.text('Enter Code'), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);
    });

    testWidgets('App bar actions work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test trusted devices navigation
      await tester.tap(find.byIcon(Icons.verified_user));
      await tester.pumpAndSettle();
      expect(find.byType(TrustedDevicesPage), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test transfer screen navigation
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      // Should navigate to transfer screen
    });

    testWidgets('Menu options work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Check menu items
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('File picker widget renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FilePickerWidget(
                onFilesSelected: (files) {
                  // Dummy callback for testing
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for file picker elements
      expect(find.text('Select Files'), findsOneWidget);
      expect(find.byIcon(Icons.image), findsWidgets);
      expect(find.byIcon(Icons.video_file), findsWidgets);
      expect(find.byIcon(Icons.audio_file), findsWidgets);
      expect(find.byIcon(Icons.description), findsWidgets);
    });

    testWidgets('QR share widget renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRShareWidget(
              data: 'TEST123',
              label: 'Test QR',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for QR elements
      expect(find.text('Test QR'), findsOneWidget);
    });

    testWidgets('Transfer statistics display correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Go to History tab
      await tester.tap(find.descendant(
          of: find.byType(TabBar), matching: find.text('History')));
      await tester.pumpAndSettle();

      // Check statistics elements
      expect(find.text('Transfer Statistics'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Success Rate'), findsOneWidget);
      expect(find.text('Data Transferred'), findsOneWidget);
    });

    testWidgets('Server status card displays', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for server status elements
      expect(find.textContaining('Connected to Server'), findsOneWidget);
      expect(find.textContaining('Not Connected to Server'), findsOneWidget);
    });

    testWidgets('Device discovery UI works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: deviceProvider),
            ChangeNotifierProvider.value(value: roomProvider),
            ChangeNotifierProvider.value(value: transferProvider),
            ChangeNotifierProvider.value(value: fileTransferProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for device discovery elements
      expect(find.text('Available Devices'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('No devices found'), findsOneWidget);
    });
  });
}

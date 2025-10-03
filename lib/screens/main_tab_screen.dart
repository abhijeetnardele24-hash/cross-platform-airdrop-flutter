import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/ios_theme.dart';
import 'transfer_screen.dart';
import 'settings_screen.dart';
import '../widgets/advanced_file_picker.dart';
import '../widgets/advanced_qr_share.dart';
import 'nearby_devices_screen.dart';
import 'transfer_history_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  final CupertinoTabController _tabController = CupertinoTabController();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoTabScaffold(
      controller: _tabController,
      backgroundColor: IOSTheme.backgroundColor(isDark),
      tabBar: CupertinoTabBar(
        backgroundColor: IOSTheme.cardColor(isDark).withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        activeColor: IOSTheme.systemBlue,
        inactiveColor: IOSTheme.secondaryTextColor(isDark),
        iconSize: 28,
        height: 90,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.home),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.house_fill),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.paperplane),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.paperplane_fill),
            ),
            label: 'Send',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.tray_arrow_down),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.tray_arrow_down_fill),
            ),
            label: 'Receive',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.qrcode_viewfinder),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.qrcode),
            ),
            label: 'QR Share',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.settings),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(CupertinoIcons.settings_solid),
            ),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomeTabView(tabController: _tabController);
          case 1:
            return const SendFilesTabView();
          case 2:
            return const ReceiveFilesTabView();
          case 3:
            return const QRShareTabView();
          case 4:
            return const SettingsScreen();
          default:
            return HomeTabView(tabController: _tabController);
        }
      },
    );
  }
}

// Home Tab - Dashboard and Overview
class HomeTabView extends StatelessWidget {
  final CupertinoTabController tabController;
  
  const HomeTabView({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSTheme.cardColor(isDark).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        middle: Text(
          'AirDrop',
          style: IOSTheme.headline.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: IOSTheme.cardColor(isDark),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: IOSTheme.systemBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.wifi,
                        color: IOSTheme.systemBlue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Share Files Instantly',
                      style: IOSTheme.title2.copyWith(
                        color: IOSTheme.primaryTextColor(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fast, secure file sharing between devices',
                      style: IOSTheme.body.copyWith(
                        color: IOSTheme.secondaryTextColor(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: IOSTheme.title3.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'Send Files',
                      CupertinoIcons.paperplane_fill,
                      IOSTheme.systemBlue,
                      () {
                        // Navigate to send tab
                        tabController.index = 1;
                      },
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'Receive',
                      CupertinoIcons.tray_arrow_down_fill,
                      IOSTheme.systemGreen,
                      () {
                        // Navigate to receive tab
                        tabController.index = 2;
                      },
                      isDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'QR Share',
                      CupertinoIcons.qrcode,
                      IOSTheme.systemPurple,
                      () {
                        // Navigate to QR tab
                        tabController.index = 3;
                      },
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'Settings',
                      CupertinoIcons.settings_solid,
                      IOSTheme.systemOrange,
                      () {
                        // Navigate to settings tab
                        tabController.index = 4;
                      },
                      isDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Additional Features
              Text(
                'More Features',
                style: IOSTheme.title3.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      'Nearby Devices',
                      CupertinoIcons.device_laptop,
                      IOSTheme.systemTeal,
                      () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const NearbyDevicesScreen(),
                          ),
                        );
                      },
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      'Transfer History',
                      CupertinoIcons.clock_fill,
                      IOSTheme.systemIndigo,
                      () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const TransferHistoryScreen(),
                          ),
                        );
                      },
                      isDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activity
              Text(
                'Recent Activity',
                style: IOSTheme.title3.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: IOSTheme.cardColor(isDark),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      color: IOSTheme.secondaryTextColor(isDark),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: IOSTheme.headline.copyWith(
                        color: IOSTheme.secondaryTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your file transfers will appear here',
                      style: IOSTheme.caption1.copyWith(
                        color: IOSTheme.secondaryTextColor(isDark).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        IOSTheme.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IOSTheme.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: IOSTheme.caption1.copyWith(
                color: IOSTheme.primaryTextColor(isDark),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        IOSTheme.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IOSTheme.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: IOSTheme.caption1.copyWith(
                color: IOSTheme.primaryTextColor(isDark),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Send Files Tab
class SendFilesTabView extends StatelessWidget {
  const SendFilesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSTheme.cardColor(isDark).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        middle: Text(
          'Send Files',
          style: IOSTheme.headline.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: AdvancedFilePickerWidget(
          onFilesSelected: (files) {
            // Handle selected files for sending
            debugPrint('Selected files for sending: $files');
          },
        ),
      ),
    );
  }
}

// Receive Files Tab
class ReceiveFilesTabView extends StatelessWidget {
  const ReceiveFilesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSTheme.cardColor(isDark).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        middle: Text(
          'Receive Files',
          style: IOSTheme.headline.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: const SafeArea(
        child: TransferScreen(),
      ),
    );
  }
}

// QR Share Tab
class QRShareTabView extends StatelessWidget {
  const QRShareTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSTheme.cardColor(isDark).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        middle: Text(
          'QR Share',
          style: IOSTheme.headline.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: const SafeArea(
        child: AdvancedQRShareWidget(
          data: 'airdrop://share/device',
          label: 'Share Connection',
        ),
      ),
    );
  }
}

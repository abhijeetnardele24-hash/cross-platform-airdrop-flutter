import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ios_theme.dart';
import '../theme/ios_typography.dart';
import 'transfer_screen.dart';
import 'settings_screen.dart';
import 'enhanced_send_screen.dart';
import 'enhanced_receive_screen.dart';
import 'enhanced_qr_screen.dart';

class BeautifulMainScreen extends StatefulWidget {
  const BeautifulMainScreen({super.key});

  @override
  State<BeautifulMainScreen> createState() => _BeautifulMainScreenState();
}

class _BeautifulMainScreenState extends State<BeautifulMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          HapticFeedback.lightImpact();
        },
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        activeColor: IOSTheme.systemBlue,
        inactiveColor: CupertinoColors.systemGrey,
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.paperplane),
            activeIcon: Icon(CupertinoIcons.paperplane_fill),
            label: 'Send',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.tray_arrow_down),
            activeIcon: Icon(CupertinoIcons.tray_arrow_down_fill),
            label: 'Receive',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.qrcode_viewfinder),
            activeIcon: Icon(CupertinoIcons.qrcode),
            label: 'QR Share',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const BeautifulHomeView();
          case 1:
            return const EnhancedSendScreen();
          case 2:
            return const EnhancedReceiveScreen();
          case 3:
            return const EnhancedQRScreen();
          case 4:
            return const SettingsScreen();
          default:
            return const BeautifulHomeView();
        }
      },
    );
  }
}

// Beautiful Home View with proper layout
class BeautifulHomeView extends StatelessWidget {
  const BeautifulHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.9),
        border: null,
        middle: Text(
          'AirDrop',
          style: IOSTypography.withColor(
            IOSTypography.navigationTitle,
            CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(IOSSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Main AirDrop Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // AirDrop Icon with gradient
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            IOSTheme.systemBlue,
                            IOSTheme.systemBlue.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: IOSTheme.systemBlue.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.wifi,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Ready to Share',
                      style: IOSTypography.withColor(
                        IOSTypography.title1Emphasized,
                        CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Your device is discoverable to nearby devices',
                      style: IOSTypography.withColor(
                        IOSTypography.callout,
                        CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: IOSTheme.systemGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: IOSTheme.systemGreen.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: IOSTheme.systemGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Online & Discoverable',
                            style: TextStyle(
                              color: IOSTheme.systemGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Quick Actions Header
              Text(
                'Quick Actions',
                style: IOSTypography.withColor(
                  IOSTypography.title2Emphasized,
                  CupertinoColors.label.resolveFrom(context),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Beautiful Action Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildBeautifulActionCard(
                    context,
                    'Send Files',
                    CupertinoIcons.paperplane_fill,
                    [IOSTheme.systemBlue, IOSTheme.systemBlue.withOpacity(0.7)],
                    () => _navigateToTab(context, 1),
                  ),
                  _buildBeautifulActionCard(
                    context,
                    'Receive Files',
                    CupertinoIcons.tray_arrow_down_fill,
                    [IOSTheme.systemGreen, IOSTheme.systemGreen.withOpacity(0.7)],
                    () => _navigateToTab(context, 2),
                  ),
                  _buildBeautifulActionCard(
                    context,
                    'QR Share',
                    CupertinoIcons.qrcode,
                    [IOSTheme.systemPurple, IOSTheme.systemPurple.withOpacity(0.7)],
                    () => _navigateToTab(context, 3),
                  ),
                  _buildBeautifulActionCard(
                    context,
                    'Settings',
                    CupertinoIcons.settings_solid,
                    [IOSTheme.systemOrange, IOSTheme.systemOrange.withOpacity(0.7)],
                    () => _navigateToTab(context, 4),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Recent Activity Section
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5.resolveFrom(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.clock,
                        size: 40,
                        color: CupertinoColors.systemGrey2.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Recent Transfers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transfer history will appear here once you start sharing files',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeautifulActionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // This will be handled by the parent tab controller
  }
}

// Beautiful Send View
class BeautifulSendView extends StatelessWidget {
  const BeautifulSendView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.9),
        border: null,
        middle: Text(
          'Send Files',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      IOSTheme.systemBlue,
                      IOSTheme.systemBlue.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: IOSTheme.systemBlue.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.paperplane_fill,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Send Files',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select files from your device to share with nearby users',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Add file picker logic here
                },
                child: const Text(
                  'Choose Files',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Beautiful Receive View
class BeautifulReceiveView extends StatelessWidget {
  const BeautifulReceiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.9),
        border: null,
        middle: Text(
          'Receive Files',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ),
      child: const SafeArea(
        child: TransferScreen(),
      ),
    );
  }
}

// Beautiful QR View
class BeautifulQRView extends StatelessWidget {
  const BeautifulQRView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.9),
        border: null,
        middle: Text(
          'QR Share',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        IOSTheme.systemPurple,
                        IOSTheme.systemPurple.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.qrcode,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'QR Code Share',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share your connection info via QR code for instant pairing',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Add QR generation logic here
                },
                child: const Text(
                  'Generate QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

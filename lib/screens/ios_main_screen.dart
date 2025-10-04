import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'transfer_screen.dart';
import 'settings_screen.dart';

class IOSMainScreen extends StatefulWidget {
  const IOSMainScreen({super.key});

  @override
  State<IOSMainScreen> createState() => _IOSMainScreenState();
}

class _IOSMainScreenState extends State<IOSMainScreen> {
  final CupertinoTabController _tabController = CupertinoTabController();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoTabScaffold(
      controller: _tabController,
      backgroundColor: CupertinoColors.systemGroupedBackground,
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        activeColor: CupertinoColors.systemBlue,
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
            return IOSHomeView();
          case 1:
            return IOSSendView();
          case 2:
            return IOSReceiveView();
          case 3:
            return IOSQRView();
          case 4:
            return const SettingsScreen();
          default:
            return IOSHomeView();
        }
      },
    );
  }
}

// Clean iOS Home View
class IOSHomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text(
          'AirDrop',
          style: TextStyle(
            fontSize: 17,
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
              const SizedBox(height: 20),
              
              // Main AirDrop Card - Clean iOS Style
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // AirDrop Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.wifi,
                        color: CupertinoColors.white,
                        size: 40,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'AirDrop',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Share files instantly with nearby devices',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CupertinoColors.systemGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: CupertinoColors.systemGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Discoverable',
                            style: TextStyle(
                              color: CupertinoColors.systemGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions Section
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Grid - Clean iOS Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    context,
                    'Send Files',
                    CupertinoIcons.paperplane_fill,
                    CupertinoColors.systemBlue,
                    () => _navigateToTab(context, 1),
                  ),
                  _buildActionCard(
                    context,
                    'Receive Files',
                    CupertinoIcons.tray_arrow_down_fill,
                    CupertinoColors.systemGreen,
                    () => _navigateToTab(context, 2),
                  ),
                  _buildActionCard(
                    context,
                    'QR Share',
                    CupertinoIcons.qrcode,
                    CupertinoColors.systemPurple,
                    () => _navigateToTab(context, 3),
                  ),
                  _buildActionCard(
                    context,
                    'Settings',
                    CupertinoIcons.settings_solid,
                    CupertinoColors.systemGrey,
                    () => _navigateToTab(context, 4),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 48,
                      color: CupertinoColors.systemGrey2.resolveFrom(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Recent Transfers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your transfer history will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
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

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // Navigation will be handled by the parent CupertinoTabScaffold
    // This is a placeholder for future navigation logic
  }
}

// Clean iOS Send View
class IOSSendView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text('Send Files'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.paperplane_fill,
                size: 80,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Send Files',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select files to share with nearby devices',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CupertinoButton.filled(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Add file picker logic here
                },
                child: const Text('Choose Files'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clean iOS Receive View
class IOSReceiveView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text('Receive Files'),
      ),
      child: const SafeArea(
        child: TransferScreen(),
      ),
    );
  }
}

// Clean iOS QR View
class IOSQRView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text('QR Share'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.qrcode,
                  size: 120,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'QR Code Share',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share your connection info via QR code',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

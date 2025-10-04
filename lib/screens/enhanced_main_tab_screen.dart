import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/ios_theme.dart';
import '../widgets/morphing_fab.dart';
import '../widgets/particle_system.dart';
import '../widgets/advanced_glassmorphism.dart';
import '../widgets/advanced_transitions.dart';
import 'transfer_screen.dart';
import 'settings_screen.dart';
import 'nearby_devices_screen.dart';

class EnhancedMainTabScreen extends StatefulWidget {
  const EnhancedMainTabScreen({super.key});

  @override
  State<EnhancedMainTabScreen> createState() => _EnhancedMainTabScreenState();
}

class _EnhancedMainTabScreenState extends State<EnhancedMainTabScreen>
    with TickerProviderStateMixin {
  final CupertinoTabController _tabController = CupertinoTabController();
  late AnimationController _backgroundController;
  // late Animation<double> _backgroundAnimation; // Unused
  
  bool _isTransferActive = false;
  double _transferProgress = 0.0;
  String _transferStatus = 'Sending...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _startTransfer() {
    setState(() {
      _isTransferActive = true;
      _transferProgress = 0.0;
    });
    
    // Simulate transfer progress
    _simulateTransfer();
  }

  void _simulateTransfer() async {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted && _isTransferActive) {
        setState(() {
          _transferProgress = i / 100.0;
          if (i == 100) {
            _isTransferActive = false;
            _transferStatus = 'Completed';
          }
        });
      }
    }
  }

  void _cancelTransfer() {
    setState(() {
      _isTransferActive = false;
      _transferProgress = 0.0;
    });
  }

  void _navigateToSend() {
    _tabController.index = 1;
  }

  void _navigateToReceive() {
    _tabController.index = 2;
  }

  void _navigateToQR() {
    _tabController.index = 3;
  }

  void _navigateToSettings() {
    _tabController.index = 4;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return CupertinoTabScaffold(
          controller: _tabController,
          backgroundColor: IOSTheme.backgroundColor(isDark),
          tabBar: _buildEnhancedTabBar(isDark),
          tabBuilder: (context, index) {
            return Stack(
              children: [
                // Background particles
                Positioned.fill(
                  child: FloatingParticles(
                    particleCount: 20,
                    colors: const [
                      IOSTheme.systemBlue,
                      IOSTheme.systemPurple,
                      IOSTheme.systemTeal,
                    ],
                    minSize: 1,
                    maxSize: 3,
                    speed: 0.2,
                    enableGlow: false,
                  ),
                ),
                
                // Tab content
                _buildTabContent(index, isDark),
                
                // Enhanced FAB
                if (index == 0) // Only show on home tab
                  _isTransferActive
                      ? ProgressFAB(
                          progress: _transferProgress,
                          status: _transferStatus,
                          onCancel: _cancelTransfer,
                          isActive: _isTransferActive,
                        )
                      : MorphingFAB(
                          onSendPressed: _navigateToSend,
                          onReceivePressed: _navigateToReceive,
                          onQRPressed: _navigateToQR,
                          onSettingsPressed: _navigateToSettings,
                          isTransferActive: _isTransferActive,
                          transferProgress: _transferProgress,
                        ),
              ],
            );
          },
        );
      },
    );
  }

  CupertinoTabBar _buildEnhancedTabBar(bool isDark) {
    return CupertinoTabBar(
      backgroundColor: Colors.transparent,
      border: const Border(),
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
    );
  }

  Widget _buildTabContent(int index, bool isDark) {
    switch (index) {
      case 0:
        return EnhancedHomeTabView(
          tabController: _tabController,
          onStartTransfer: _startTransfer,
        );
      case 1:
        return const EnhancedSendFilesTabView();
      case 2:
        return const EnhancedReceiveFilesTabView();
      case 3:
        return const EnhancedQRShareTabView();
      case 4:
        return const SettingsScreen();
      default:
        return EnhancedHomeTabView(
          tabController: _tabController,
          onStartTransfer: _startTransfer,
        );
    }
  }
}

// Enhanced Home Tab with glassmorphism and advanced animations
class EnhancedHomeTabView extends StatefulWidget {
  final CupertinoTabController tabController;
  final VoidCallback onStartTransfer;

  const EnhancedHomeTabView({
    super.key,
    required this.tabController,
    required this.onStartTransfer,
  });

  @override
  State<EnhancedHomeTabView> createState() => _EnhancedHomeTabViewState();
}

class _EnhancedHomeTabViewState extends State<EnhancedHomeTabView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        middle: Text(
          'AirDrop Pro',
          style: IOSTheme.headline.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Hero welcome card with glassmorphism
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 200,
                        blur: 20,
                        opacity: 0.15,
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Background gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    IOSTheme.systemBlue.withOpacity(0.1),
                                    IOSTheme.systemPurple.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: IOSTheme.systemBlue.withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.wifi,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ready to Share',
                                              style: IOSTheme.title2.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Your device is discoverable',
                                              style: IOSTheme.body.copyWith(
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const Spacer(),
                                  
                                  // Quick action button
                                  GlassmorphicButton(
                                    onPressed: widget.onStartTransfer,
                                    width: double.infinity,
                                    height: 48,
                                    blur: 15,
                                    opacity: 0.2,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          CupertinoIcons.bolt_fill,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Start Quick Transfer',
                                          style: IOSTheme.body.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Quick Actions Grid
                      Text(
                        'Quick Actions',
                        style: IOSTheme.title3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildQuickActionCard(
                            'Send Files',
                            CupertinoIcons.paperplane_fill,
                            [IOSTheme.systemBlue, IOSTheme.systemPurple],
                            () => widget.tabController.index = 1,
                          ),
                          _buildQuickActionCard(
                            'Receive',
                            CupertinoIcons.tray_arrow_down_fill,
                            [IOSTheme.systemGreen, IOSTheme.systemTeal],
                            () => widget.tabController.index = 2,
                          ),
                          _buildQuickActionCard(
                            'QR Share',
                            CupertinoIcons.qrcode,
                            [IOSTheme.systemPurple, IOSTheme.systemPink],
                            () => widget.tabController.index = 3,
                          ),
                          _buildQuickActionCard(
                            'Nearby Devices',
                            CupertinoIcons.device_laptop,
                            [IOSTheme.systemOrange, IOSTheme.systemYellow],
                            () => Navigator.push(
                              context,
                              TransitionHelper.slideRoute(
                                child: const NearbyDevicesScreen(),
                                direction: SlideDirection.rightToLeft,
                                enableBlur: true,
                                enableScale: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Recent Activity Section
                      Text(
                        'Recent Activity',
                        style: IOSTheme.title3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 120,
                        blur: 20,
                        opacity: 0.1,
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                color: Colors.white.withOpacity(0.6),
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No recent transfers',
                                style: IOSTheme.body.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return AnimatedGlassCard(
      width: double.infinity,
      height: double.infinity,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: IOSTheme.caption1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Send Files Tab
class EnhancedSendFilesTabView extends StatelessWidget {
  const EnhancedSendFilesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        middle: Text(
          'Send Files',
          style: IOSTheme.headline.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            'Send Files Screen',
            style: IOSTheme.headline.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Receive Files Tab
class EnhancedReceiveFilesTabView extends StatelessWidget {
  const EnhancedReceiveFilesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        middle: Text(
          'Receive Files',
          style: IOSTheme.headline.copyWith(
            color: Colors.white,
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

// Enhanced QR Share Tab
class EnhancedQRShareTabView extends StatelessWidget {
  const EnhancedQRShareTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        middle: Text(
          'QR Share',
          style: IOSTheme.headline.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            'QR Share Screen',
            style: IOSTheme.headline.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

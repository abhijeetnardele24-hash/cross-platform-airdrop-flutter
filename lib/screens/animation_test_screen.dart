import 'package:flutter/material.dart';
import '../widgets/enhanced_glass_card.dart';
import '../widgets/animated_buttons.dart';
import '../widgets/staggered_list.dart';
import '../utils/page_transitions.dart';

/// Screen to test all animations in both light and dark themes
class AnimationTestScreen extends StatefulWidget {
  const AnimationTestScreen({super.key});

  @override
  State<AnimationTestScreen> createState() => _AnimationTestScreenState();
}

class _AnimationTestScreenState extends State<AnimationTestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Showcase'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.blur_on), text: 'Glass'),
            Tab(icon: Icon(Icons.touch_app), text: 'Buttons'),
            Tab(icon: Icon(Icons.list), text: 'Lists'),
            Tab(icon: Icon(Icons.navigation), text: 'Transitions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlassTab(isDark),
          _buildButtonsTab(isDark),
          _buildListsTab(isDark),
          _buildTransitionsTab(isDark),
        ],
      ),
    );
  }

  Widget _buildGlassTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Glass Morphism Effects',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Enhanced Glass Card
          const Text('Enhanced Glass Card', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          EnhancedGlassCard(
            blur: 15.0,
            opacity: 0.2,
            child: Column(
              children: [
                Icon(
                  Icons.blur_circular,
                  size: 48,
                  color: isDark ? Colors.white : Colors.blue,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Glass Morphism',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beautiful frosted glass effect with blur',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Animated Glass Container with Shimmer
          const Text('Animated Glass with Shimmer', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          AnimatedGlassContainer(
            blur: 12.0,
            opacity: 0.25,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 32,
                    color: isDark ? Colors.amber : Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shimmer Effect',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Subtle animated shimmer'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Interactive Glass Card
          const Text('Interactive Glass Card', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          EnhancedGlassCard(
            blur: 10.0,
            opacity: 0.15,
            enableHoverEffect: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Glass card tapped!')),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app),
                  SizedBox(width: 12),
                  Text(
                    'Tap me!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Button Micro-interactions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Animated Button
          const Text('Animated Button', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          AnimatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Animated button pressed!')),
              );
            },
            color: Colors.blue,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Press Me',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Bouncy Button
          const Text('Bouncy Button', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          BouncyButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bouncy button pressed!')),
              );
            },
            color: Colors.green,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_basketball, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Bounce!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Pulse Button
          const Text('Pulse Button', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          PulseButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pulse button pressed!')),
              );
            },
            color: Colors.purple,
            enablePulse: true,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Pulsing',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Shimmer Button
          const Text('Shimmer Button', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ShimmerButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shimmer button pressed!')),
              );
            },
            baseColor: Colors.orange,
            highlightColor: Colors.amber,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Shimmer',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Rotating Icon Buttons
          const Text('Rotating Icon Buttons', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RotatingIconButton(
                icon: Icons.refresh,
                onPressed: () {},
                color: Colors.blue,
                size: 32,
              ),
              RotatingIconButton(
                icon: Icons.settings,
                onPressed: () {},
                color: Colors.grey,
                size: 32,
              ),
              RotatingIconButton(
                icon: Icons.sync,
                onPressed: () {},
                color: Colors.green,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListsTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Staggered List Animations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StaggeredListView(
            itemCount: 20,
            delay: const Duration(milliseconds: 50),
            itemDuration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EnhancedGlassCard(
                  blur: 10.0,
                  opacity: 0.15,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getColorForIndex(index),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Staggered animation with delay',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransitionsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Page Transitions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          _buildTransitionButton(
            'Cupertino Slide',
            Icons.arrow_forward,
            Colors.blue,
            () => _navigateWithTransition(PageTransitions.cupertinoRoute),
          ),
          const SizedBox(height: 12),
          
          _buildTransitionButton(
            'Fade Transition',
            Icons.blur_on,
            Colors.purple,
            () => _navigateWithTransition(PageTransitions.fadeRoute),
          ),
          const SizedBox(height: 12),
          
          _buildTransitionButton(
            'Scale Transition',
            Icons.zoom_in,
            Colors.green,
            () => _navigateWithTransition(PageTransitions.scaleRoute),
          ),
          const SizedBox(height: 12),
          
          _buildTransitionButton(
            'Slide from Bottom',
            Icons.arrow_upward,
            Colors.orange,
            () => _navigateWithTransition(PageTransitions.slideFromBottomRoute),
          ),
          const SizedBox(height: 12),
          
          _buildTransitionButton(
            'Slide from Right',
            Icons.arrow_back,
            Colors.red,
            () => _navigateWithTransition(PageTransitions.slideFromRightRoute),
          ),
          const SizedBox(height: 12),
          
          _buildTransitionButton(
            'Shared Axis (Horizontal)',
            Icons.swap_horiz,
            Colors.teal,
            () => _navigateWithTransition(
              (page) => PageTransitions.sharedAxisRoute(
                page,
                type: SharedAxisTransitionType.horizontal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return AnimatedButton(
      onPressed: onPressed,
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _navigateWithTransition(Route Function(Widget) routeBuilder) {
    Navigator.of(context).push(
      routeBuilder(_DemoDestinationScreen()),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}

/// Demo destination screen for transitions
class _DemoDestinationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EnhancedGlassCard(
            blur: 15.0,
            opacity: 0.2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: isDark ? Colors.green : Colors.green[700],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transition Complete!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'You successfully navigated with a custom transition',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.blue,
                  child: const Text(
                    'Go Back',
                    style: TextStyle(color: Colors.white),
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

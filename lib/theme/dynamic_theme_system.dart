import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'ios_theme.dart';

class DynamicThemeSystem extends ChangeNotifier {
  static final DynamicThemeSystem _instance = DynamicThemeSystem._internal();
  factory DynamicThemeSystem() => _instance;
  DynamicThemeSystem._internal();

  // Current theme state
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = IOSTheme.systemBlue;
  double _animationSpeed = 1.0;
  bool _enableParticles = true;
  bool _enableGlassmorphism = true;
  bool _enableAdvancedAnimations = true;
  
  // Theme presets
  final Map<String, ThemePreset> _presets = {
    'ocean': ThemePreset(
      name: 'Ocean',
      primaryColor: const Color(0xFF0077BE),
      secondaryColor: const Color(0xFF00A8CC),
      accentColor: const Color(0xFF64D2FF),
      gradient: [const Color(0xFF0077BE), const Color(0xFF64D2FF)],
      particles: [const Color(0xFF0077BE), const Color(0xFF64D2FF), const Color(0xFF00A8CC)],
    ),
    'sunset': ThemePreset(
      name: 'Sunset',
      primaryColor: const Color(0xFFFF6B35),
      secondaryColor: const Color(0xFFFF9F1C),
      accentColor: const Color(0xFFFFD60A),
      gradient: [const Color(0xFFFF6B35), const Color(0xFFFFD60A)],
      particles: [const Color(0xFFFF6B35), const Color(0xFFFF9F1C), const Color(0xFFFFD60A)],
    ),
    'forest': ThemePreset(
      name: 'Forest',
      primaryColor: const Color(0xFF2D5016),
      secondaryColor: const Color(0xFF56A3A6),
      accentColor: const Color(0xFF30D158),
      gradient: [const Color(0xFF2D5016), const Color(0xFF30D158)],
      particles: [const Color(0xFF2D5016), const Color(0xFF56A3A6), const Color(0xFF30D158)],
    ),
    'cosmic': ThemePreset(
      name: 'Cosmic',
      primaryColor: const Color(0xFF5E5CE6),
      secondaryColor: const Color(0xFFBF5AF2),
      accentColor: const Color(0xFFFF375F),
      gradient: [const Color(0xFF5E5CE6), const Color(0xFFFF375F)],
      particles: [const Color(0xFF5E5CE6), const Color(0xFFBF5AF2), const Color(0xFFFF375F)],
    ),
    'minimal': ThemePreset(
      name: 'Minimal',
      primaryColor: const Color(0xFF1C1C1E),
      secondaryColor: const Color(0xFF2C2C2E),
      accentColor: const Color(0xFF007AFF),
      gradient: [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E)],
      particles: [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E), const Color(0xFF007AFF)],
    ),
  };

  String _currentPreset = 'ocean';

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  double get animationSpeed => _animationSpeed;
  bool get enableParticles => _enableParticles;
  bool get enableGlassmorphism => _enableGlassmorphism;
  bool get enableAdvancedAnimations => _enableAdvancedAnimations;
  String get currentPreset => _currentPreset;
  Map<String, ThemePreset> get presets => _presets;
  ThemePreset get activePreset => _presets[_currentPreset]!;

  // Theme switching with animation
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _animateThemeChange();
      notifyListeners();
    }
  }

  Future<void> setAccentColor(Color color) async {
    if (_accentColor != color) {
      _accentColor = color;
      await _animateColorChange();
      notifyListeners();
    }
  }

  Future<void> setPreset(String presetName) async {
    if (_presets.containsKey(presetName) && _currentPreset != presetName) {
      _currentPreset = presetName;
      _accentColor = _presets[presetName]!.accentColor;
      await _animatePresetChange();
      notifyListeners();
    }
  }

  void setAnimationSpeed(double speed) {
    _animationSpeed = speed.clamp(0.1, 3.0);
    notifyListeners();
  }

  void setEnableParticles(bool enabled) {
    _enableParticles = enabled;
    notifyListeners();
  }

  void setEnableGlassmorphism(bool enabled) {
    _enableGlassmorphism = enabled;
    notifyListeners();
  }

  void setEnableAdvancedAnimations(bool enabled) {
    _enableAdvancedAnimations = enabled;
    notifyListeners();
  }

  // Animation methods
  Future<void> _animateThemeChange() async {
    HapticFeedback.mediumImpact();
    // Add theme transition animation logic here
    await Future.delayed(Duration(milliseconds: (300 / _animationSpeed).round()));
  }

  Future<void> _animateColorChange() async {
    HapticFeedback.lightImpact();
    // Add color transition animation logic here
    await Future.delayed(Duration(milliseconds: (200 / _animationSpeed).round()));
  }

  Future<void> _animatePresetChange() async {
    HapticFeedback.heavyImpact();
    // Add preset transition animation logic here
    await Future.delayed(Duration(milliseconds: (500 / _animationSpeed).round()));
  }

  // Get theme data based on current settings
  ThemeData getLightTheme() {
    final preset = activePreset;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(preset.primaryColor),
      primaryColor: preset.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: preset.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: IOSTheme.headline.copyWith(
          color: preset.primaryColor,
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    final preset = activePreset;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(preset.primaryColor),
      primaryColor: preset.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: preset.primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: IOSTheme.headline.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  CupertinoThemeData getCupertinoTheme(bool isDark) {
    final preset = activePreset;
    return CupertinoThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: preset.primaryColor,
      scaffoldBackgroundColor: isDark ? IOSTheme.darkBackground : IOSTheme.lightBackground,
      barBackgroundColor: isDark ? IOSTheme.cardColor(true) : IOSTheme.cardColor(false),
      textTheme: CupertinoTextThemeData(
        primaryColor: isDark ? Colors.white : preset.primaryColor,
        textStyle: IOSTheme.body.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }

  // Animated color interpolation
  Color interpolateColor(Color from, Color to, double progress) {
    return Color.lerp(from, to, progress) ?? from;
  }

  // Get gradient for current preset
  LinearGradient getCurrentGradient({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    final preset = activePreset;
    return LinearGradient(
      begin: begin,
      end: end,
      colors: preset.gradient,
    );
  }

  // Get particle colors for current preset
  List<Color> getParticleColors() {
    return activePreset.particles;
  }

  // Create custom theme preset
  void createCustomPreset(String name, ThemePreset preset) {
    _presets[name] = preset;
    notifyListeners();
  }

  // Remove custom preset
  void removeCustomPreset(String name) {
    if (_presets.containsKey(name) && name != _currentPreset) {
      _presets.remove(name);
      notifyListeners();
    }
  }

  // Export/Import theme settings
  Map<String, dynamic> exportSettings() {
    return {
      'themeMode': _themeMode.index,
      'accentColor': _accentColor.value,
      'animationSpeed': _animationSpeed,
      'enableParticles': _enableParticles,
      'enableGlassmorphism': _enableGlassmorphism,
      'enableAdvancedAnimations': _enableAdvancedAnimations,
      'currentPreset': _currentPreset,
    };
  }

  void importSettings(Map<String, dynamic> settings) {
    _themeMode = ThemeMode.values[settings['themeMode'] ?? 0];
    _accentColor = Color(settings['accentColor'] ?? IOSTheme.systemBlue.value);
    _animationSpeed = settings['animationSpeed'] ?? 1.0;
    _enableParticles = settings['enableParticles'] ?? true;
    _enableGlassmorphism = settings['enableGlassmorphism'] ?? true;
    _enableAdvancedAnimations = settings['enableAdvancedAnimations'] ?? true;
    _currentPreset = settings['currentPreset'] ?? 'ocean';
    notifyListeners();
  }
}

class ThemePreset {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final List<Color> gradient;
  final List<Color> particles;

  const ThemePreset({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.gradient,
    required this.particles,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'accentColor': accentColor.value,
      'gradient': gradient.map((c) => c.value).toList(),
      'particles': particles.map((c) => c.value).toList(),
    };
  }

  factory ThemePreset.fromJson(Map<String, dynamic> json) {
    return ThemePreset(
      name: json['name'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      accentColor: Color(json['accentColor']),
      gradient: (json['gradient'] as List).map((c) => Color(c)).toList(),
      particles: (json['particles'] as List).map((c) => Color(c)).toList(),
    );
  }
}

// Animated theme transition widget
class AnimatedThemeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedThemeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedThemeTransition> createState() => _AnimatedThemeTransitionState();
}

class _AnimatedThemeTransitionState extends State<AnimatedThemeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(AnimatedThemeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animation,
          child: widget.child,
        );
      },
    );
  }
}

// Color picker widget for theme customization
class AdvancedColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final String title;

  const AdvancedColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.title,
  });

  @override
  State<AdvancedColorPicker> createState() => _AdvancedColorPickerState();
}

class _AdvancedColorPickerState extends State<AdvancedColorPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Color _selectedColor;

  final List<Color> _presetColors = [
    IOSTheme.systemBlue,
    IOSTheme.systemGreen,
    IOSTheme.systemRed,
    IOSTheme.systemOrange,
    IOSTheme.systemYellow,
    IOSTheme.systemPurple,
    IOSTheme.systemPink,
    IOSTheme.systemTeal,
    IOSTheme.systemIndigo,
    IOSTheme.systemMint,
    IOSTheme.systemCyan,
    IOSTheme.systemBrown,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: IOSTheme.headline.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        
        // Current color preview
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _selectedColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
              style: IOSTheme.body.copyWith(
                color: _selectedColor.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Preset colors grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _presetColors.length,
          itemBuilder: (context, index) {
            final color = _presetColors[index];
            final isSelected = color.value == _selectedColor.value;
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedColor = color;
                });
                widget.onColorChanged(color);
                _controller.forward().then((_) => _controller.reverse());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: isSelected ? 15 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}

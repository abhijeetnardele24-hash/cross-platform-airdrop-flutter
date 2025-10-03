import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class IOSTheme {
  // Modern iOS 17+ Colors - Enhanced Vibrancy
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF30D158);
  static const Color systemRed = Color(0xFFFF453A);
  static const Color systemOrange = Color(0xFFFF9F0A);
  static const Color systemYellow = Color(0xFFFFD60A);
  static const Color systemPurple = Color(0xFFBF5AF2);
  static const Color systemPink = Color(0xFFFF375F);
  static const Color systemTeal = Color(0xFF64D2FF);
  static const Color systemIndigo = Color(0xFF5E5CE6);
  static const Color systemGray = Color(0xFF8E8E93);
  
  // Modern Accent Colors
  static const Color systemMint = Color(0xFF00C7BE);
  static const Color systemCyan = Color(0xFF32D74B);
  static const Color systemBrown = Color(0xFFAC8E68);
  
  // Dynamic Gradients
  static const List<Color> blueGradient = [Color(0xFF007AFF), Color(0xFF5AC8FA)];
  static const List<Color> purpleGradient = [Color(0xFFBF5AF2), Color(0xFF5E5CE6)];
  static const List<Color> pinkGradient = [Color(0xFFFF375F), Color(0xFFFF2D92)];
  static const List<Color> greenGradient = [Color(0xFF30D158), Color(0xFF00C7BE)];
  static const List<Color> orangeGradient = [Color(0xFFFF9F0A), Color(0xFFFFD60A)];
  static const List<Color> tealGradient = [Color(0xFF64D2FF), Color(0xFF00C7BE)];
  
  // Glassmorphism Colors
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x40000000);
  static const Color glassBlur = Color(0x20FFFFFF);

  // Modern Light Theme Colors
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSecondaryBackground = Color(0xFFFFFFFF);
  static const Color lightTertiaryBackground = Color(0xFFFAFAFA);
  static const Color lightGroupedBackground = Color(0xFFF2F2F7);
  static const Color lightSecondaryGroupedBackground = Color(0xFFFFFFFF);
  static const Color lightTertiaryGroupedBackground = Color(0xFFF8F8F8);
  
  // Modern Dark Theme Colors - Enhanced Depth
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSecondaryBackground = Color(0xFF1C1C1E);
  static const Color darkTertiaryBackground = Color(0xFF2C2C2E);
  static const Color darkGroupedBackground = Color(0xFF000000);
  static const Color darkSecondaryGroupedBackground = Color(0xFF1C1C1E);
  static const Color darkTertiaryGroupedBackground = Color(0xFF2C2C2E);
  
  // Enhanced Surface Colors
  static const Color lightSurface = Color(0xFFFBFBFD);
  static const Color darkSurface = Color(0xFF1A1A1C);
  static const Color lightElevated = Color(0xFFFFFFFF);
  static const Color darkElevated = Color(0xFF2C2C2E);

  // Text Colors
  static const Color lightPrimaryText = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF3C3C43);
  static const Color lightTertiaryText = Color(0xFF3C3C43);
  static const Color lightQuaternaryText = Color(0xFF3C3C43);

  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFEBEBF5);
  static const Color darkTertiaryText = Color(0xFFEBEBF5);
  // Separator Colors
  static const Color lightSeparator = Color(0x4D3C3C43);
  static const Color darkSeparator = Color(0x4DEBEBF5);

  // Typography - SF Pro Display/Text
  static const String fontFamily = 'SF Pro Display';
  static const String textFontFamily = 'SF Pro Text';
  static const String monoFontFamily = 'SF Mono';

  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    fontFamily: fontFamily,
    height: 1.12,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    fontFamily: fontFamily,
    height: 1.14,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
    height: 1.18,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    fontFamily: fontFamily,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    fontFamily: textFontFamily,
    height: 1.29,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    fontFamily: textFontFamily,
    height: 1.29,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    fontFamily: textFontFamily,
    height: 1.31,
  );

  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    fontFamily: textFontFamily,
    height: 1.33,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    fontFamily: textFontFamily,
    height: 1.38,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: textFontFamily,
    height: 1.33,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    fontFamily: textFontFamily,
    height: 1.36,
  );

  // Additional sophisticated typography
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.25,
    fontFamily: fontFamily,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamily,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamily,
    height: 1.22,
  );

  // Spacing constants
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Radius constants
  static const double smallRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 10.0;
  static const double largeRadius = 16.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Modern Shadow Definitions - Enhanced Depth
  static const List<BoxShadow> lightCardShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 32,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 40,
      offset: Offset(0, 16),
      spreadRadius: 0,
    ),
  ];
  
  // Glassmorphism Shadows
  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  // Elevated Shadows
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 28,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 56,
      offset: Offset(0, 24),
      spreadRadius: 0,
    ),
  ];

  // Get colors based on theme
  static Color backgroundColor(bool isDark) => 
    isDark ? darkGroupedBackground : lightGroupedBackground;

  static Color cardColor(bool isDark) => 
    isDark ? darkSecondaryGroupedBackground : lightSecondaryGroupedBackground;
    
  static Color surfaceColor(bool isDark) => 
    isDark ? darkSurface : lightSurface;
    
  static Color elevatedColor(bool isDark) => 
    isDark ? darkElevated : lightElevated;

  static Color primaryTextColor(bool isDark) => 
    isDark ? darkPrimaryText : lightPrimaryText;

  static Color secondaryTextColor(bool isDark) => 
    isDark ? darkSecondaryText.withOpacity(0.6) : lightSecondaryText.withOpacity(0.6);

  static Color separatorColor(bool isDark) => 
    isDark ? darkSeparator : lightSeparator;

  static List<BoxShadow> cardShadow(bool isDark) => 
    isDark ? darkCardShadow : lightCardShadow;
    
  // Modern Gradient Helpers
  static LinearGradient getGradient(List<Color> colors, {Alignment begin = Alignment.topLeft, Alignment end = Alignment.bottomRight}) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }
  
  static LinearGradient dynamicGradient(bool isDark) {
    return isDark 
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkSecondaryBackground, darkTertiaryBackground],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightSecondaryBackground, lightTertiaryBackground],
        );
  }
  
  // Glassmorphism Helper
  static Color glassColor(bool isDark, {double opacity = 0.2}) {
    return isDark 
      ? Colors.white.withOpacity(opacity * 0.5)
      : Colors.white.withOpacity(opacity);
  }

  // Haptic Feedback
  static void lightImpact() => HapticFeedback.lightImpact();
  static void mediumImpact() => HapticFeedback.mediumImpact();
  static void heavyImpact() => HapticFeedback.heavyImpact();
  static void selectionClick() => HapticFeedback.selectionClick();
}

// Modern iOS-style animated container with glassmorphism
class IOSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isGlass;
  final List<Color>? gradient;
  final double? elevation;

  const IOSCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding,
    this.margin,
    this.onTap,
    this.isGlass = false,
    this.gradient,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: IOSTheme.fastAnimation,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: IOSTheme.spacing16),
      decoration: BoxDecoration(
        gradient: gradient != null ? IOSTheme.getGradient(gradient!) : null,
        color: gradient == null ? (isGlass ? IOSTheme.glassColor(isDark) : IOSTheme.cardColor(isDark)) : null,
        borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
        boxShadow: elevation != null 
          ? [BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: elevation! * 2,
              offset: Offset(0, elevation!),
            )]
          : (isGlass ? IOSTheme.glassShadow : IOSTheme.cardShadow(isDark)),
        border: isGlass ? Border.all(
          color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
          width: 0.5,
        ) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
        child: isGlass ? BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: _buildContent(),
        ) : _buildContent(),
      ),
    );
  }
  
  Widget _buildContent() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
      child: InkWell(
        onTap: onTap != null ? () {
          IOSTheme.lightImpact();
          onTap!();
        } : null,
        borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(IOSTheme.spacing20),
          child: child,
        ),
      ),
    );
  }
}

// Modern Glassmorphism Card
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isDark;
  final double blurIntensity;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding,
    this.margin,
    this.onTap,
    this.blurIntensity = 20.0,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: IOSTheme.spacing16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
          width: 0.5,
        ),
        boxShadow: IOSTheme.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.white).withOpacity(opacity),
              borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap != null ? () {
                  IOSTheme.lightImpact();
                  onTap!();
                } : null,
                borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(IOSTheme.spacing20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// iOS-style button
class IOSButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isDestructive;
  final bool isSecondary;
  final bool isLoading;

  const IOSButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isDestructive = false,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = backgroundColor ?? 
      (isDestructive ? IOSTheme.systemRed : 
       isSecondary ? Colors.grey.withOpacity(0.2) : IOSTheme.systemBlue);
    
    Color fgColor = textColor ?? 
      (isSecondary ? IOSTheme.systemBlue : Colors.white);

    return AnimatedContainer(
      duration: IOSTheme.fastAnimation,
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          IOSTheme.mediumImpact();
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IOSTheme.buttonRadius),
          ),
        ),
        child: isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: IOSTheme.spacing8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

// iOS-style list tile
class IOSListTile extends StatelessWidget {
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;
  final Color? iconColor;

  const IOSListTile({
    super.key,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null ? () {
          IOSTheme.lightImpact();
          onTap!();
        } : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: IOSTheme.spacing20,
            vertical: IOSTheme.spacing12,
          ),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (iconColor ?? IOSTheme.systemBlue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(IOSTheme.smallRadius),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: iconColor ?? IOSTheme.systemBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: IOSTheme.spacing16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: IOSTheme.primaryTextColor(isDark),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: IOSTheme.secondaryTextColor(isDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

// iOS-style section header
class IOSSectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const IOSSectionHeader({
    super.key,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        IOSTheme.spacing20,
        IOSTheme.spacing24,
        IOSTheme.spacing20,
        IOSTheme.spacing8,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: IOSTheme.secondaryTextColor(isDark),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// iOS-style divider
class IOSDivider extends StatelessWidget {
  final bool isDark;
  final double indent;

  const IOSDivider({
    super.key,
    required this.isDark,
    this.indent = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent),
      height: 0.5,
      color: IOSTheme.separatorColor(isDark),
    );
  }
}

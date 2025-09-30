import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class IOSStyleTheme {
  // iOS System Colors - Enhanced Palette
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemYellow = Color(0xFFFFCC00);

  // Semantic Colors
  static const Color labelPrimary = Color(0xFF000000);
  static const Color labelSecondary = Color(0xFF3C3C43);
  static const Color labelTertiary = Color(0xFF3C3C43);
  static const Color labelQuaternary = Color(0xFF3C3C43);

  static const Color fillPrimary = Color(0xFF787880);
  static const Color fillSecondary = Color(0xFF787880);
  static const Color fillTertiary = Color(0xFF767680);
  static const Color fillQuaternary = Color(0xFF747480);

  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF2F2F7);
  static const Color backgroundTertiary = Color(0xFFFFFFFF);

  static const Color groupedBackgroundPrimary = Color(0xFFF2F2F7);
  static const Color groupedBackgroundSecondary = Color(0xFFFFFFFF);
  static const Color groupedBackgroundTertiary = Color(0xFFF2F2F7);

  static const Color separator = Color(0xFFC6C6C8);
  static const Color opaqueSeparator = Color(0xFF000000);

  // Dark Mode Colors
  static const Color labelPrimaryDark = Color(0xFFFFFFFF);
  static const Color labelSecondaryDark = Color(0xFFEBEBF5);
  static const Color labelTertiaryDark = Color(0xFFEBEBF5);
  static const Color labelQuaternaryDark = Color(0xFFEBEBF5);

  static const Color backgroundPrimaryDark = Color(0xFF000000);
  static const Color backgroundSecondaryDark = Color(0xFF1C1C1E);
  static const Color backgroundTertiaryDark = Color(0xFF2C2C2E);

  static const Color groupedBackgroundPrimaryDark = Color(0xFF1C1C1E);
  static const Color groupedBackgroundSecondaryDark = Color(0xFF2C2C2E);
  static const Color groupedBackgroundTertiaryDark = Color(0xFF3A3A3C);

  static const Color separatorDark = Color(0xFF38383A);
  static const Color opaqueSeparatorDark = Color(0xFFFFFFFF);

  // Enhanced Typography
  static TextTheme getLightTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: labelPrimary,
        letterSpacing: 0.37,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: labelPrimary,
        letterSpacing: 0.36,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        letterSpacing: 0.35,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        letterSpacing: 0.38,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        letterSpacing: -0.22,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
        letterSpacing: -0.32,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        letterSpacing: -0.41,
        height: 1.2,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
        letterSpacing: -0.24,
        height: 1.2,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
        letterSpacing: -0.08,
        height: 1.2,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: labelPrimary,
        letterSpacing: -0.41,
        height: 1.2,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: labelSecondary,
        letterSpacing: -0.24,
        height: 1.2,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: labelTertiary,
        letterSpacing: -0.08,
        height: 1.2,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
        letterSpacing: -0.08,
        height: 1.2,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: labelSecondary,
        letterSpacing: 0.0,
        height: 1.2,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: labelTertiary,
        letterSpacing: 0.07,
        height: 1.2,
      ),
    );
  }

  static TextTheme getDarkTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: labelPrimaryDark,
        letterSpacing: 0.37,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: labelPrimaryDark,
        letterSpacing: 0.36,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: labelPrimaryDark,
        letterSpacing: 0.35,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: labelPrimaryDark,
        letterSpacing: 0.38,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: labelPrimaryDark,
        letterSpacing: -0.22,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: labelPrimaryDark,
        letterSpacing: -0.32,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: labelPrimaryDark,
        letterSpacing: -0.41,
        height: 1.2,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: labelPrimaryDark,
        letterSpacing: -0.24,
        height: 1.2,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: labelPrimaryDark,
        letterSpacing: -0.08,
        height: 1.2,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: labelPrimaryDark,
        letterSpacing: -0.41,
        height: 1.2,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: labelSecondaryDark,
        letterSpacing: -0.24,
        height: 1.2,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: labelTertiaryDark,
        letterSpacing: -0.08,
        height: 1.2,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: labelPrimaryDark,
        letterSpacing: -0.08,
        height: 1.2,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: labelSecondaryDark,
        letterSpacing: 0.0,
        height: 1.2,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: labelTertiaryDark,
        letterSpacing: 0.07,
        height: 1.2,
      ),
    );
  }

  // Enhanced Light Theme
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: systemBlue,
        brightness: Brightness.light,
        primary: systemBlue,
        secondary: systemIndigo,
        tertiary: systemTeal,
        surface: backgroundPrimary,
        background: backgroundSecondary,
        error: systemRed,
        onPrimary: backgroundPrimary,
        onSecondary: backgroundPrimary,
        onSurface: labelPrimary,
        onBackground: labelPrimary,
        onError: backgroundPrimary,
      ),
      scaffoldBackgroundColor: backgroundSecondary,
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: groupedBackgroundSecondary,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: backgroundPrimary,
        foregroundColor: labelPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: labelPrimary,
          letterSpacing: -0.41,
        ),
        iconTheme: IconThemeData(color: systemBlue),
        actionsIconTheme: IconThemeData(color: systemBlue),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundPrimary,
        elevation: 0,
        selectedItemColor: systemBlue,
        unselectedItemColor: fillPrimary.withValues(alpha: 0.6),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: systemBlue,
        unselectedLabelColor: Color(0xFF787880),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.08,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.08,
        ),
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Color(0x1F007AFF),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: systemBlue,
          foregroundColor: backgroundPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: systemBlue,
          foregroundColor: backgroundPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: separator, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: separator, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: systemBlue, width: 2),
        ),
        filled: true,
        fillColor: groupedBackgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 17,
          color: labelQuaternary,
          letterSpacing: -0.41,
        ),
      ),
      textTheme: getLightTextTheme(),
      dividerTheme: DividerThemeData(
        color: separator,
        thickness: 0.5,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: groupedBackgroundSecondary,
        selectedTileColor: systemBlue.withValues(alpha: 0.1),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundPrimary,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: labelPrimary,
          letterSpacing: -0.24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Enhanced Dark Theme
  static final DialogThemeData dialogThemeDark = DialogThemeData(
    backgroundColor: backgroundPrimaryDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  static final CardThemeData cardThemeDark = CardThemeData(
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: groupedBackgroundSecondaryDark,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
  );

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: systemBlue,
        brightness: Brightness.dark,
        primary: systemBlue,
        secondary: systemIndigo,
        tertiary: systemTeal,
        surface: backgroundPrimaryDark,
        background: backgroundSecondaryDark,
        error: systemRed,
        onPrimary: backgroundPrimary,
        onSecondary: backgroundPrimary,
        onSurface: labelPrimaryDark,
        onBackground: labelPrimaryDark,
        onError: backgroundPrimary,
      ),
      scaffoldBackgroundColor: backgroundPrimaryDark,
      cardTheme: cardThemeDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: backgroundPrimaryDark,
        foregroundColor: labelPrimaryDark,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: labelPrimaryDark,
          letterSpacing: -0.41,
        ),
        iconTheme: IconThemeData(color: systemBlue),
        actionsIconTheme: IconThemeData(color: systemBlue),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundPrimaryDark,
        elevation: 0,
        selectedItemColor: systemBlue,
        unselectedItemColor: fillPrimary.withValues(alpha: 0.6),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: systemBlue,
        unselectedLabelColor: Color(0xFF787880),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.08,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.08,
        ),
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Color(0x1F007AFF),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: systemBlue,
          foregroundColor: backgroundPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: systemBlue,
          foregroundColor: backgroundPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: separatorDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: separatorDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: systemBlue, width: 2),
        ),
        filled: true,
        fillColor: groupedBackgroundSecondaryDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 17,
          color: labelQuaternaryDark,
          letterSpacing: -0.41,
        ),
      ),
      textTheme: getDarkTextTheme(),
      dividerTheme: DividerThemeData(
        color: separatorDark,
        thickness: 0.5,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: groupedBackgroundSecondaryDark,
        selectedTileColor: systemBlue.withValues(alpha: 0.1),
      ),
      dialogTheme: dialogThemeDark,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundPrimaryDark,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: labelPrimaryDark,
          letterSpacing: -0.24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Cupertino Theme Data
  static CupertinoThemeData getCupertinoTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return CupertinoThemeData(
      primaryColor: systemBlue,
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? backgroundSecondaryDark : backgroundSecondary,
      barBackgroundColor: (isDark ? backgroundPrimaryDark : backgroundPrimary)
          .withValues(alpha: 0.8),
      textTheme: CupertinoTextThemeData(
        navLargeTitleTextStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: isDark ? labelPrimaryDark : labelPrimary,
          letterSpacing: 0.37,
          height: 1.2,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: isDark ? labelPrimaryDark : labelPrimary,
          letterSpacing: -0.41,
          height: 1.2,
        ),
        textStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: isDark ? labelPrimaryDark : labelPrimary,
          letterSpacing: -0.41,
          height: 1.2,
        ),
        actionTextStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: systemBlue,
          letterSpacing: -0.41,
          height: 1.2,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
          height: 1.2,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 21,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          height: 1.2,
        ),
      ),
    );
  }
}

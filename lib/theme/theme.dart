import 'package:flutter/material.dart';

class AppColors {
  // --- Main Palette from Icon ---

  /// Deep, dark purple from the night sky background.
  /// Used for backgrounds and surfaces in dark mode.
  static const Color darkPurple = Color(0xFF2A264F);

  /// A slightly lighter purple for cards or surfaces in dark mode.
  static const Color darkSurface = Color(0xFF3A365F);

  /// Bright, magical blue from the character's hair and wisps.
  /// Ideal for primary interactive elements (buttons, links, highlights).
  static const Color brightBlue = Color(0xFF6AD5F0);

  /// Lighter lavender/purple from the icon's outer ring.
  /// Great for secondary elements or outlines.
  static const Color lightLavender = Color(0xFF8C7AB8);

  /// Soft pink from the cherry blossoms.
  /// Perfect for tertiary accents or special highlights.
  static const Color pink = Color(0xFFF08C9C);

  /// Creamy off-white from the book pages and title text.
  /// Used for text and content, especially in dark mode.
  static const Color creamWhite = Color(0xFFFDF5E6);

  /// Gold/Yellow from sparkles and book details.
  /// Can be used for highlights, ratings, or premium features.
  static const Color gold = Color(0xFFFFD700);

  /// Deep red from the book spines.
  /// Good for error states or destructive actions.
  static const Color deepRed = Color(0xFFC70039); // Brighter red for errors
}

/// The main dark theme, inspired directly by the app icon.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Inter',
  // Example font, replace with your app's font
  scaffoldBackgroundColor: AppColors.darkPurple,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    // Primary (interactive elements)
    primary: AppColors.brightBlue,
    onPrimary: AppColors.darkPurple,
    // Text on primary color

    // Secondary
    secondary: AppColors.lightLavender,
    onSecondary: AppColors.darkPurple,
    // Text on secondary color

    // Tertiary (accents)
    tertiary: AppColors.pink,
    onTertiary: AppColors.darkPurple,
    // Text on tertiary color

    // Backgrounds
    background: AppColors.darkPurple,

    onBackground: AppColors.creamWhite,
    // Main text color

    // Surfaces (cards, dialogs)
    surface: AppColors.darkSurface,
    onSurface: AppColors.creamWhite,
    // Text on cards

    // Error
    error: AppColors.deepRed,
    onError: AppColors.creamWhite,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.creamWhite,
    elevation: 0,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.brightBlue,
    foregroundColor: AppColors.darkPurple,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brightBlue,
      foregroundColor: AppColors.darkPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  textTheme:
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.creamWhite),
        bodyMedium: TextStyle(color: AppColors.creamWhite),
        titleLarge: TextStyle(
          color: AppColors.creamWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.creamWhite,
          fontWeight: FontWeight.bold,
        ),
      ).apply(
        fontFamily: 'Inter', // Ensure font is applied
      ),

  iconTheme: const IconThemeData(color: AppColors.lightLavender),
);

/// A light theme derived from the same color palette.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Inter',
  // Example font, replace with your app's font
  scaffoldBackgroundColor: AppColors.creamWhite,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    // Primary (interactive elements)
    primary: AppColors.brightBlue,
    onPrimary: AppColors.darkPurple,

    // Secondary
    secondary: AppColors.lightLavender,
    onSecondary: AppColors.creamWhite,

    // Tertiary (accents)
    tertiary: AppColors.pink,
    onTertiary: AppColors.darkPurple,

    // Backgrounds
    background: AppColors.creamWhite,
    onBackground: AppColors.darkPurple,
    // Main text color

    // Surfaces (cards, dialogs)
    surface: Colors.white,
    onSurface: AppColors.darkPurple,
    // Text on cards

    // Error
    error: AppColors.deepRed,
    onError: AppColors.creamWhite,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.darkPurple,
    elevation: 1,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.brightBlue,
    foregroundColor: AppColors.darkPurple,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brightBlue,
      foregroundColor: AppColors.darkPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: AppColors.lightLavender.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  textTheme:
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkPurple),
        bodyMedium: TextStyle(color: AppColors.darkPurple),
        titleLarge: TextStyle(
          color: AppColors.darkPurple,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkPurple,
          fontWeight: FontWeight.bold,
        ),
      ).apply(
        fontFamily: 'Inter', // Ensure font is applied
      ),

  iconTheme: const IconThemeData(color: AppColors.lightLavender),
);

class AnimeLibraryTheme {
  // 🌙 DARK THEME
  static ThemeData get dark {
    const primary = Color(0xFF4A5BDA);
    const secondary = Color(0xFFF57AC5);
    const background = Color(0xFF121336);
    const surface = Color(0xFF1E1F47);
    const textPrimary = Colors.white;
    const textSecondary = Color(0xFFB0B3D9);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1F47),
        selectedItemColor: secondary,
        unselectedItemColor: Color(0xFFB0B3D9),
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xFF1E1F47),
        selectedIconTheme: IconThemeData(color: secondary),
        unselectedIconTheme: IconThemeData(color: Color(0xFFB0B3D9)),
        selectedLabelTextStyle: TextStyle(color: secondary),
        unselectedLabelTextStyle: TextStyle(color: Color(0xFFB0B3D9)),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }

  // ☀️ LIGHT THEME
  static ThemeData get light {
    const primary = Color(0xFF4A5BDA);
    const secondary = Color(0xFFF57AC5);
    const background = Color(0xFFF8F8FF);
    const surface = Color(0xFFFFFFFF);
    const textPrimary = Color(0xFF1C1C2E);
    const textSecondary = Color(0xFF5A5B80);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: secondary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: secondary),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: TextStyle(color: secondary),
        unselectedLabelTextStyle: TextStyle(color: textSecondary),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }
}

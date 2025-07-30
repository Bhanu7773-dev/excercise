import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modern color palette
class AppColors {
  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF00639B);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFCEE5FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001D33);
  static const Color lightSecondary = Color(0xFF51606F);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFD5E4F7);
  static const Color lightOnSecondaryContainer = Color(0xFF0E1D2A);
  static const Color lightTertiary = Color(0xFF68587A);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFEFDBFF);
  static const Color lightOnTertiaryContainer = Color(0xFF231533);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);
  static const Color lightBackground = Color(0xFFF8F9FF);
  static const Color lightOnBackground = Color(0xFF191C20);
  static const Color lightSurface = Color(0xFFF8F9FF);
  static const Color lightOnSurface = Color(0xFF191C20);
  static const Color lightSurfaceVariant = Color(0xFFDEE3EB);
  static const Color lightOnSurfaceVariant = Color(0xFF42474E);
  static const Color lightOutline = Color(0xFF72787E);
  static const Color lightShadow = Color(0xFF000000);
  static const Color lightInverseSurface = Color(0xFF2E3135);
  static const Color lightOnInverseSurface = Color(0xFFF0F1F6);
  static const Color lightInversePrimary = Color(0xFF97CBFF);

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xFF97CBFF);
  static const Color darkOnPrimary = Color(0xFF003353);
  static const Color darkPrimaryContainer = Color(0xFF004A76);
  static const Color darkOnPrimaryContainer = Color(0xFFCEE5FF);
  static const Color darkSecondary = Color(0xFFB9C8DA);
  static const Color darkOnSecondary = Color(0xFF233240);
  static const Color darkSecondaryContainer = Color(0xFF3A4857);
  static const Color darkOnSecondaryContainer = Color(0xFFD5E4F7);
  static const Color darkTertiary = Color(0xFFD3BFEF);
  static const Color darkOnTertiary = Color(0xFF392A4A);
  static const Color darkTertiaryContainer = Color(0xFF504161);
  static const Color darkOnTertiaryContainer = Color(0xFFEFDBFF);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);
  static const Color darkBackground = Color(0xFF191C20);
  static const Color darkOnBackground = Color(0xFFE2E2E6);
  static const Color darkSurface = Color(0xFF191C20);
  static const Color darkOnSurface = Color(0xFFE2E2E6);
  static const Color darkSurfaceVariant = Color(0xFF42474E);
  static const Color darkOnSurfaceVariant = Color(0xFFC2C7CE);
  static const Color darkOutline = Color(0xFF8C9198);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkInverseSurface = Color(0xFFE2E2E6);
  static const Color darkOnInverseSurface = Color(0xFF191C20);
  static const Color darkInversePrimary = Color(0xFF00639B);
}

// Light theme data
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    primaryContainer: AppColors.lightPrimaryContainer,
    onPrimaryContainer: AppColors.lightOnPrimaryContainer,
    secondary: AppColors.lightSecondary,
    onSecondary: AppColors.lightOnSecondary,
    secondaryContainer: AppColors.lightSecondaryContainer,
    onSecondaryContainer: AppColors.lightOnSecondaryContainer,
    tertiary: AppColors.lightTertiary,
    onTertiary: AppColors.lightOnTertiary,
    tertiaryContainer: AppColors.lightTertiaryContainer,
    onTertiaryContainer: AppColors.lightOnTertiaryContainer,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
    errorContainer: AppColors.lightErrorContainer,
    onErrorContainer: AppColors.lightOnErrorContainer,
    background: AppColors.lightBackground,
    onBackground: AppColors.lightOnBackground,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    outline: AppColors.lightOutline,
    shadow: AppColors.lightShadow,
    inverseSurface: AppColors.lightInverseSurface,
    onInverseSurface: AppColors.lightOnInverseSurface,
    inversePrimary: AppColors.lightInversePrimary,
  ),
  scaffoldBackgroundColor: AppColors.lightBackground,
  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightPrimary,
    foregroundColor: AppColors.lightOnPrimary,
  ),
  cardTheme: CardThemeData(
    color: AppColors.lightSurface,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: AppColors.lightOutline.withOpacity(0.5),
      ),
    ),
  ),
);

// Dark theme data
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimaryContainer: AppColors.darkOnPrimaryContainer,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkOnSecondary,
    secondaryContainer: AppColors.darkSecondaryContainer,
    onSecondaryContainer: AppColors.darkOnSecondaryContainer,
    tertiary: AppColors.darkTertiary,
    onTertiary: AppColors.darkOnTertiary,
    tertiaryContainer: AppColors.darkTertiaryContainer,
    onTertiaryContainer: AppColors.darkOnTertiaryContainer,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
    errorContainer: AppColors.darkErrorContainer,
    onErrorContainer: AppColors.darkOnErrorContainer,
    background: AppColors.darkBackground,
    onBackground: AppColors.darkOnBackground,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    shadow: AppColors.darkShadow,
    inverseSurface: AppColors.darkInverseSurface,
    onInverseSurface: AppColors.darkOnInverseSurface,
    inversePrimary: AppColors.darkInversePrimary,
  ),
  scaffoldBackgroundColor: AppColors.darkBackground,
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkPrimaryContainer,
    foregroundColor: AppColors.darkOnPrimaryContainer,
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkSurfaceVariant,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: AppColors.darkOutline.withOpacity(0.5),
      ),
    ),
  ),
);

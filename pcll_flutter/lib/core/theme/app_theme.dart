// PCLL Theme System

import 'package:flutter/material.dart';

// =============================================================================
// COLOR SYSTEM - LIGHT MODE (Mint & Wood)
// =============================================================================

class PCLLColors {
  PCLLColors._();

  // ===== LIGHT THEME COLORS =====

  // Background hierarchy - soft cream/mint undertones
  static const Color background = Color(0xFFF5F9F7); // Soft mint white
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceAlt = Color(0xFFEDF5F1); // Subtle mint tint

  // Text hierarchy
  static const Color textPrimary = Color(0xFF2D3B36); // Deep forest
  static const Color textSecondary = Color(0xFF5A6B63); // Muted sage
  static const Color textTertiary = Color(0xFF8A9B92); // Light sage
  static const Color textDisabled = Color(0xFFB5C4BC); // Faded sage

  // Primary accent - Mint green
  static const Color accent = Color(0xFF4A9B7F); // Rich mint
  static const Color accentLight = Color(0xFFD4EDE3); // Pale mint
  static const Color accentDark = Color(0xFF357A62); // Deep mint

  // Secondary accent - Warm wood
  static const Color wood = Color(0xFF8B6B4D); // Warm brown
  static const Color woodLight = Color(0xFFD4C4B5); // Light wood
  static const Color woodDark = Color(0xFF5C4733); // Dark wood

  // Semantic colors - Nature inspired
  static const Color positive = Color(0xFF4A9B7F); // Mint for positive
  static const Color negative = Color(0xFFB85C5C); // Terracotta red
  static const Color neutral = Color(0xFF7A8B82); // Sage gray
  static const Color warning = Color(0xFFD4A574); // Amber wood

  // Borders and dividers
  static const Color border = Color(0xFFD4DDD8); // Soft mint gray
  static const Color divider = Color(0xFFE8F0EC); // Very light mint

  // State indicators (balance zones) - Nature palette
  static const Color zonePositive = Color(0xFF4A9B7F); // Rich mint (70+ CU)
  static const Color zoneModerate = Color(0xFF7AB09A); // Light mint (40-69 CU)
  static const Color zoneDepleted = Color(0xFFD4A574); // Amber (1-39 CU)
  static const Color zoneDeficit = Color(0xFFB85C5C); // Terracotta (Below 0)

  // Zone color aliases
  static const Color zoneGreen = Color(0xFF4A9B7F); // Surplus/well-rested
  static const Color zoneYellow = Color(0xFFD4A574); // Moderate/balanced
  static const Color zoneOrange = Color(0xFFC47F5C); // Depleted
  static const Color zoneRed = Color(0xFFB85C5C); // Critical

  // Chart colors
  static const Color chartWithdrawal =
      Color(0xFFB85C5C); // Terracotta for costs
  static const Color chartDeposit = Color(0xFF4A9B7F); // Mint for recovery
  static const Color chartBalance = Color(0xFF2D3B36); // Forest for balance
  static const Color chartGrid = Color(0xFFE8F0EC); // Light mint grid

  // ===== DARK THEME COLORS =====

  static const Color backgroundDark = Color(0xFF1A2421); // Deep forest
  static const Color surfaceDark = Color(0xFF232E2A); // Dark sage
  static const Color surfaceAltDark = Color(0xFF2A3632); // Lighter forest

  static const Color textPrimaryDark = Color(0xFFF0F5F2); // Soft white
  static const Color textSecondaryDark = Color(0xFFB5C4BC); // Muted sage
  static const Color textTertiaryDark = Color(0xFF7A8B82); // Dark sage
  static const Color textDisabledDark = Color(0xFF4A5B53); // Very dark sage

  static const Color accentDarkMode = Color(0xFF6BC4A6); // Bright mint
  static const Color accentLightDarkMode = Color(0xFF2A4A3D); // Dark mint bg
  static const Color woodDarkMode = Color(0xFFC4A484); // Light wood
  static const Color woodLightDarkMode = Color(0xFF3D3228); // Dark wood bg

  static const Color borderDark = Color(0xFF3A4A44); // Dark sage border
  static const Color dividerDark = Color(0xFF2A3632); // Very dark mint
}

// =============================================================================
// TYPOGRAPHY SYSTEM
// =============================================================================

class PCLLTypography {
  PCLLTypography._();

  // Font families (using system fonts as fallback)
  static const String monoFamily = 'Roboto Mono'; // For numbers/data
  static const String sansFamily = 'Roboto'; // For text

  // Fallback to system fonts if custom fonts not available
  static const String monoFallback = 'Roboto Mono';
  static const String sansFallback = 'Roboto';

  // Display styles (large numbers)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: monoFamily,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.5,
    height: 1.1,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: monoFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
    height: 1.2,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: monoFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    height: 1.2,
    color: PCLLColors.textPrimary,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: PCLLColors.textPrimary,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: PCLLColors.textSecondary,
  );

  // Label styles (for UI elements)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: PCLLColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
    color: PCLLColors.textTertiary,
  );

  // Monospace styles (for data/numbers)
  static const TextStyle dataLarge = TextStyle(
    fontFamily: monoFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.2,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle dataMedium = TextStyle(
    fontFamily: monoFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: PCLLColors.textPrimary,
  );

  static const TextStyle dataSmall = TextStyle(
    fontFamily: monoFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
    color: PCLLColors.textSecondary,
  );

  // Special: Ledger entry style
  static const TextStyle ledgerAmount = TextStyle(
    fontFamily: monoFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
    color: PCLLColors.textPrimary,
  );
}

// =============================================================================
// SPACING SYSTEM (8px base grid)
// =============================================================================

class PCLLSpacing {
  PCLLSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double smd = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius - slightly more rounded for softer feel
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(sm);
}

// =============================================================================
// THEME DATA
// =============================================================================

class PCLLTheme {
  PCLLTheme._();

  // ========== LIGHT THEME ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: PCLLColors.accent,
        onPrimary: Colors.white,
        primaryContainer: PCLLColors.accentLight,
        onPrimaryContainer: PCLLColors.accentDark,
        secondary: PCLLColors.wood,
        onSecondary: Colors.white,
        secondaryContainer: PCLLColors.woodLight,
        onSecondaryContainer: PCLLColors.woodDark,
        surface: PCLLColors.surface,
        onSurface: PCLLColors.textPrimary,
        surfaceContainerHighest: PCLLColors.surfaceAlt,
        error: PCLLColors.negative,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: PCLLColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: PCLLColors.background,
        foregroundColor: PCLLColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: PCLLTypography.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: PCLLColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PCLLColors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PCLLColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          borderSide: const BorderSide(color: PCLLColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          borderSide: const BorderSide(color: PCLLColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          borderSide: const BorderSide(color: PCLLColors.accent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: PCLLTypography.labelMedium,
        hintStyle: PCLLTypography.bodyMedium.copyWith(
          color: PCLLColors.textTertiary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PCLLColors.wood,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          ),
          textStyle: PCLLTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PCLLColors.wood,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: PCLLTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PCLLColors.wood,
          side: const BorderSide(color: PCLLColors.wood),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          ),
          textStyle: PCLLTypography.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PCLLColors.wood,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: PCLLColors.accent,
        inactiveTrackColor: PCLLColors.accentLight,
        thumbColor: PCLLColors.accent,
        overlayColor: PCLLColors.accent.withOpacity(0.1),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PCLLColors.wood;
          }
          return PCLLColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PCLLColors.woodLight;
          }
          return PCLLColors.border;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PCLLColors.surface,
        selectedItemColor: PCLLColors.accent,
        unselectedItemColor: PCLLColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: PCLLTypography.labelSmall,
        unselectedLabelStyle: PCLLTypography.labelSmall,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PCLLColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PCLLColors.wood,
        contentTextStyle:
            PCLLTypography.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PCLLColors.accentLight,
        labelStyle:
            PCLLTypography.labelMedium.copyWith(color: PCLLColors.accent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PCLLColors.accent,
        linearTrackColor: PCLLColors.accentLight,
      ),
    );
  }

  // ========== DARK THEME ==========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: PCLLColors.accentDarkMode,
        onPrimary: PCLLColors.backgroundDark,
        primaryContainer: PCLLColors.accentLightDarkMode,
        onPrimaryContainer: PCLLColors.accentDarkMode,
        secondary: PCLLColors.woodDarkMode,
        onSecondary: PCLLColors.backgroundDark,
        secondaryContainer: PCLLColors.woodLightDarkMode,
        onSecondaryContainer: PCLLColors.woodDarkMode,
        surface: PCLLColors.surfaceDark,
        onSurface: PCLLColors.textPrimaryDark,
        surfaceContainerHighest: PCLLColors.surfaceAltDark,
        error: PCLLColors.negative,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: PCLLColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: PCLLColors.backgroundDark,
        foregroundColor: PCLLColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: PCLLTypography.headlineMedium.copyWith(
          color: PCLLColors.textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: PCLLColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PCLLColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PCLLColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          borderSide: const BorderSide(color: PCLLColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          borderSide: const BorderSide(color: PCLLColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          borderSide:
              const BorderSide(color: PCLLColors.accentDarkMode, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: PCLLTypography.labelMedium.copyWith(
          color: PCLLColors.textSecondaryDark,
        ),
        hintStyle: PCLLTypography.bodyMedium.copyWith(
          color: PCLLColors.textTertiaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PCLLColors.woodDarkMode,
          foregroundColor: PCLLColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          ),
          textStyle: PCLLTypography.labelLarge.copyWith(
            color: PCLLColors.backgroundDark,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PCLLColors.woodDarkMode,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: PCLLTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PCLLColors.woodDarkMode,
          side: const BorderSide(color: PCLLColors.woodDarkMode),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          ),
          textStyle: PCLLTypography.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PCLLColors.woodDarkMode,
        foregroundColor: PCLLColors.backgroundDark,
        elevation: 2,
        shape: CircleBorder(),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: PCLLColors.accentDarkMode,
        inactiveTrackColor: PCLLColors.accentLightDarkMode,
        thumbColor: PCLLColors.accentDarkMode,
        overlayColor: PCLLColors.accentDarkMode.withOpacity(0.1),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PCLLColors.woodDarkMode;
          }
          return PCLLColors.textTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PCLLColors.woodLightDarkMode;
          }
          return PCLLColors.borderDark;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PCLLColors.surfaceDark,
        selectedItemColor: PCLLColors.accentDarkMode,
        unselectedItemColor: PCLLColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: PCLLTypography.labelSmall,
        unselectedLabelStyle: PCLLTypography.labelSmall,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PCLLColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PCLLColors.woodDarkMode,
        contentTextStyle: PCLLTypography.bodyMedium.copyWith(
          color: PCLLColors.backgroundDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        textColor: PCLLColors.textPrimaryDark,
        iconColor: PCLLColors.textSecondaryDark,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PCLLColors.accentLightDarkMode,
        labelStyle: PCLLTypography.labelMedium.copyWith(
          color: PCLLColors.accentDarkMode,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PCLLColors.accentDarkMode,
        linearTrackColor: PCLLColors.accentLightDarkMode,
      ),
      iconTheme: const IconThemeData(
        color: PCLLColors.textSecondaryDark,
      ),
    );
  }
}

// =============================================================================
// THEME MODE EXTENSION - Helper for dynamic theming
// =============================================================================

extension ThemeColors on BuildContext {
  /// Get current theme-aware colors
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? PCLLColors.backgroundDark : PCLLColors.background;

  Color get surfaceColor =>
      isDarkMode ? PCLLColors.surfaceDark : PCLLColors.surface;

  Color get textPrimaryColor =>
      isDarkMode ? PCLLColors.textPrimaryDark : PCLLColors.textPrimary;

  Color get textSecondaryColor =>
      isDarkMode ? PCLLColors.textSecondaryDark : PCLLColors.textSecondary;

  Color get accentColor =>
      isDarkMode ? PCLLColors.accentDarkMode : PCLLColors.accent;

  Color get borderColor =>
      isDarkMode ? PCLLColors.borderDark : PCLLColors.border;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// tuPoint theme configuration using Material 3 design system
/// Based on specifications in project-theme.md v3.0 (BLUE DOMINANCE)
///
/// Light Theme: "BLUE IMMERSION" - Location Blue DOMINATES with obvious blue backgrounds and borders
/// Dark Theme: "BLUE ELECTRIC" - Location Blue GLOWS everywhere with borders, shadows, and electric highlights
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // ============================================================================
  // CUSTOM COLOR DEFINITIONS (v3.0 - AGGRESSIVE BLUE DOMINANCE)
  // ============================================================================

  // Light Theme Colors - MUCH MORE BLUE!
  static const Color _lightScaffold = Color(0xFFD6EEFF); // OBVIOUSLY BLUE (40% more saturated)
  static const Color _lightSurface = Color(0xFFF0F7FF); // Blue-tinted cards (NOT white!)
  static const Color _lightSurfaceVariant = Color(0xFFC2E3FF); // CLEARLY VISIBLE BLUE
  static const Color _lightPrimaryContainer = Color(0xFF99CCFF); // SATURATED BLUE
  static const Color _lightOnBackground = Color(0xFF0D1F2D); // Darker for blue bg
  static const Color _lightOnSurfaceVariant = Color(0xFF1A3A52); // Secondary text
  static const Color _lightOnSurfaceMuted = Color(0xFF3D5A6B); // Tertiary text
  static const Color _lightPrimary = Color(0xFF3A9BFC); // Location Blue
  static const Color _lightOnPrimary = Color(0xFFFFFFFF); // White on blue
  static const Color _lightOnPrimaryContainer = Color(0xFF002D4D); // Dark blue text

  // Light Theme Border & Glow Colors (NEW in v3.0)
  static const Color _lightBorderBlue = Color(0xFF3A9BFC); // 3dp solid blue borders
  static const Color _lightShadowBlue = Color(0x263A9BFC); // 15% opacity blue shadows
  static const Color _lightDividerBlue = Color(0x4D3A9BFC); // 30% opacity dividers

  // Dark Theme Colors - EVEN MORE ELECTRIC!
  static const Color _darkScaffold = Color(0xFF0F1A26); // Darker for better glow contrast
  static const Color _darkSurface = Color(0xFF1A2836); // More obvious blue tint
  static const Color _darkSurfaceVariant = Color(0xFF243546); // CLEARLY blue-tinted
  static const Color _darkPrimaryContainer = Color(0xFF004C7A); // Darkened Location Blue
  static const Color _darkOnBackground = Color(0xFFE8EEF2); // Not pure white
  static const Color _darkOnSurfaceVariant = Color(0xFFB8C8D4); // Secondary text
  static const Color _darkOnSurfaceMuted = Color(0xFF8A9BAB); // Tertiary text
  static const Color _darkPrimary = Color(0xFF66B8FF); // BRIGHTER electric blue
  static const Color _darkOnPrimary = Color(0xFF001D33); // Dark text on bright blue
  static const Color _darkOnPrimaryContainer = Color(0xFFB3DCFF); // Light blue text

  // Dark Theme Border & Glow Colors (NEW in v3.0)
  static const Color _darkBorderBlue = Color(0xFF66B8FF); // 2dp glowing blue borders
  static const Color _darkGlowBlue = Color(0x3366B8FF); // 20% opacity card glow
  static const Color _darkDividerBlue = Color(0x6666B8FF); // 40% opacity dividers
  static const Color _darkHighlightGlow = Color(0x4D85C7FF); // 30% bright glow

  // ============================================================================
  // PUBLIC GETTERS FOR CUSTOM COLORS (v3.0)
  // ============================================================================

  /// Get border blue color for current brightness
  static Color getBorderBlue(Brightness brightness) {
    return brightness == Brightness.light ? _lightBorderBlue : _darkBorderBlue;
  }

  /// Get glow color for current brightness
  static Color getGlowBlue(Brightness brightness) {
    return brightness == Brightness.light ? _lightShadowBlue : _darkGlowBlue;
  }

  /// Get divider blue color for current brightness
  static Color getDividerBlue(Brightness brightness) {
    return brightness == Brightness.light ? _lightDividerBlue : _darkDividerBlue;
  }

  /// Get highlight glow color for dark mode FAB
  static Color get highlightGlow => _darkHighlightGlow;

  // ============================================================================
  // LIGHT THEME - "BLUE IMMERSION"
  // ============================================================================

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.light(
      // Primary colors
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,

      // Background & Surface colors (the key to making it pop!)
      surface: _lightSurface,
      onSurface: _lightOnBackground,
      surfaceContainerHighest: _lightSurfaceVariant,
      onSurfaceVariant: _lightOnSurfaceVariant,

      // Error colors
      error: const Color(0xFFD32F2F),
      onError: Colors.white,

      // Outline
      outline: _lightOnSurfaceMuted,
    );

    return _buildTheme(
      colorScheme,
      scaffoldBackground: _lightScaffold,
      isLight: true,
    );
  }

  // ============================================================================
  // DARK THEME - "BLUE ELECTRIC"
  // ============================================================================

  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.dark(
      // Primary colors (brighter for dark mode!)
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,

      // Background & Surface colors
      surface: _darkSurface,
      onSurface: _darkOnBackground,
      surfaceContainerHighest: _darkSurfaceVariant,
      onSurfaceVariant: _darkOnSurfaceVariant,

      // Error colors (lighter for dark backgrounds)
      error: const Color(0xFFEF5350),
      onError: const Color(0xFF001D33),

      // Outline
      outline: _darkOnSurfaceMuted,
    );

    return _buildTheme(
      colorScheme,
      scaffoldBackground: _darkScaffold,
      isLight: false,
    );
  }

  // ============================================================================
  // THEME BUILDER
  // ============================================================================

  static ThemeData _buildTheme(
    ColorScheme colorScheme, {
    required Color scaffoldBackground,
    required bool isLight,
  }) {
    return ThemeData(
      // Material 3 design system
      useMaterial3: true,

      // Custom color scheme with vibrant colors
      colorScheme: colorScheme,

      // Custom scaffold background (blue-tinted for light, dark gray for dark)
      scaffoldBackgroundColor: scaffoldBackground,

      // Typography using Inter font family
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // Visual density optimized for mobile touch
      visualDensity: VisualDensity.comfortable,

      // ========================================================================
      // CARD THEME (v3.0 - WITH BLUE BORDERS!)
      // ========================================================================
      cardTheme: CardThemeData(
        elevation: AppConstants.elevationDefault,
        shadowColor: isLight ? _lightShadowBlue : _darkGlowBlue,
        surfaceTintColor: Colors.transparent, // Disable Material 3 surface tint
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          side: BorderSide(
            color: isLight ? _lightBorderBlue : _darkBorderBlue,
            width: isLight ? 3.0 : 2.0, // 3dp light, 2dp dark
          ),
        ),
      ),

      // ========================================================================
      // BUTTON THEMES
      // ========================================================================

      // Filled buttons (primary actions)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppConstants.minTouchTarget,
            AppConstants.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppConstants.textSizeButton,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined buttons (secondary actions)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppConstants.minTouchTarget,
            AppConstants.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppConstants.textSizeButton,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ========================================================================
      // INPUT DECORATION THEME
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
        ),
        // v3.0: Even UNFOCUSED inputs have visible blue borders!
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: isLight ? 0.4 : 0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2.0,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: AppConstants.textSizeLabel,
          fontWeight: FontWeight.w400,
        ),
        helperStyle: GoogleFonts.inter(
          fontSize: AppConstants.textSizeLabel,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ========================================================================
      // FLOATING ACTION BUTTON THEME (v3.0 - MASSIVE BLUE GLOW!)
      // ========================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppConstants.elevationFAB,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusFAB),
        ),
        // Use primary color for maximum vibrancy
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        // Note: Additional glow effect added via BoxShadow in FAB implementation
      ),

      // ========================================================================
      // CHIP THEME
      // ========================================================================
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusChip),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: AppConstants.textSizeMaidenhead,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ========================================================================
      // APP BAR THEME
      // ========================================================================
      // NOTE: v3.0 specifies AppBar gradient (Location Blue → Lighter Blue)
      // This must be applied in individual AppBar widgets using flexibleSpace:
      //   AppBar(
      //     flexibleSpace: Container(
      //       decoration: BoxDecoration(
      //         gradient: LinearGradient(
      //           begin: Alignment.centerLeft,
      //           end: Alignment.centerRight,
      //           colors: [Color(0xFF3A9BFC), Color(0xFF5AB0FF)],
      //         ),
      //       ),
      //     ),
      //   )
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.primary, // Fallback for AppBars without gradient
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary, // White text on blue background
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary, // White icons on blue background
        ),
      ),
    );
  }
}

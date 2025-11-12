import 'package:flutter/material.dart';

/// Application-wide constants for tuPoint
/// These values are derived from project-theme.md specifications
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ============================================================================
  // COLORS
  // ============================================================================

  /// Primary brand color: Location Blue
  /// Used for primary actions, location indicators, and brand identity
  static const Color locationBlue = Color(0xFF3A9BFC);

  // ============================================================================
  // SPACING
  // ============================================================================

  /// Base spacing unit following Material Design's 8dp grid system
  static const double baseSpacing = 8.0;

  /// Tight spacing for related inline elements (0.5 units)
  static const double spacingXS = 4.0;

  /// Default padding within components (1 unit)
  static const double spacingSM = 8.0;

  /// Standard padding for cards, list items, screen edges (2 units)
  static const double spacingMD = 16.0;

  /// Section separation, grouping related content (3 units)
  static const double spacingLG = 24.0;

  /// Major section breaks, screen-level padding on large devices (4 units)
  static const double spacingXL = 32.0;

  /// Vertical rhythm for distinct content blocks (6 units)
  static const double spacingXXL = 48.0;

  /// Minimum touch target size (Material Design & HIG compliance)
  static const double minTouchTarget = 48.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// Default border radius for cards and buttons
  static const double borderRadiusDefault = 12.0;

  /// Border radius for chips (Maidenhead codes, distance badges)
  static const double borderRadiusChip = 8.0;

  /// Border radius for FAB and bottom sheets
  static const double borderRadiusFAB = 16.0;

  // ============================================================================
  // ELEVATION
  // ============================================================================

  /// Cards at rest, list items, inactive surfaces
  static const double elevationDefault = 1.0;

  /// Raised buttons at rest, cards on hover
  static const double elevationRaised = 2.0;

  /// Active/pressed buttons, selected cards
  static const double elevationActive = 3.0;

  /// FAB at rest, bottom navigation bar
  static const double elevationFAB = 6.0;

  /// FAB on press, active bottom sheets
  static const double elevationFABPressed = 8.0;

  /// Dialogs, modal overlays
  static const double elevationModal = 12.0;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  /// Short duration for micro-interactions (icon state changes, toggles)
  static const Duration animationShort = Duration(milliseconds: 150);

  /// Medium duration for screen transitions, card animations, modals
  static const Duration animationMedium = Duration(milliseconds: 300);

  // ============================================================================
  // ANIMATION CURVES
  // ============================================================================

  /// Default animation curve for balanced motion
  static const Curve animationCurveDefault = Curves.easeInOutCubic;

  /// Entrance animations (elements arriving on screen)
  static const Curve animationCurveEntrance = Curves.easeOut;

  /// Exit animations (elements leaving screen)
  static const Curve animationCurveExit = Curves.easeIn;

  // ============================================================================
  // COMPONENT SIZES
  // ============================================================================

  /// Standard FAB size
  static const double fabSize = 56.0;

  /// Standard icon size
  static const double iconSizeDefault = 24.0;

  /// Large icon size (for prominent actions like like button)
  static const double iconSizeLarge = 28.0;

  /// Small icon size (for metadata indicators)
  static const double iconSizeSmall = 20.0;

  /// Inline text icon size (slightly smaller to match text cap height)
  static const double iconSizeInline = 18.0;

  // ============================================================================
  // TYPOGRAPHY SIZES
  // ============================================================================

  /// Large headlines and app title
  static const double textSizeHeadlineLarge = 32.0;

  /// Point content (body text)
  static const double textSizeBody = 16.0;

  /// Button labels and taglines
  static const double textSizeButton = 16.0;

  /// Username labels
  static const double textSizeUsername = 14.0;

  /// Metadata (time, distance)
  static const double textSizeMetadata = 12.0;

  /// Floating labels and helper text
  static const double textSizeLabel = 12.0;

  /// Maidenhead codes in chips
  static const double textSizeMaidenhead = 11.0;

  // ============================================================================
  // DIVIDER PROPERTIES
  // ============================================================================

  /// Divider height (vertical space including the line)
  static const double dividerHeight = 24.0;

  /// Divider thickness (actual line thickness)
  static const double dividerThickness = 1.0;

  /// Divider horizontal indent
  static const double dividerIndent = 16.0;

  // ============================================================================
  // BORDER WIDTHS
  // ============================================================================

  /// Standard border width for outlined components
  static const double borderWidthDefault = 1.0;

  /// Focused input border width
  static const double focusedBorderWidth = 2.0;

  /// Card border width in light mode (more visible blue)
  static const double cardBorderWidthLight = 3.0;

  /// Card border width in dark mode (glowing blue)
  static const double cardBorderWidthDark = 2.0;

  // ============================================================================
  // FAB GLOW EFFECTS
  // ============================================================================

  /// FAB primary glow blur radius
  static const double fabGlowBlur = 24.0;

  /// FAB glow spread radius in light mode
  static const double fabGlowSpreadLight = 4.0;

  /// FAB glow spread radius in dark mode
  static const double fabGlowSpreadDark = 6.0;

  /// FAB highlight glow blur radius (dark mode only)
  static const double fabHighlightGlowBlur = 32.0;

  /// FAB highlight glow spread radius (dark mode only)
  static const double fabHighlightGlowSpread = 8.0;
}

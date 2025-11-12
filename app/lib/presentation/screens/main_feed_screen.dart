import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/point_card.dart';
import 'point_creation_screen.dart';

/// Main Feed Screen
///
/// Displays a scrollable list of nearby Points (location-based posts) sorted
/// by proximity to the user's current location.
///
/// This is a UI mockup using hardcoded test data - no actual geolocation,
/// API calls, or state management is implemented.
///
/// UI Components:
/// - AppBar with "📍 Near Me" title
/// - Scrollable ListView of Point cards
/// - Floating Action Button (FAB) to create new Points
///
/// Based on UX specification: Screen 3 - Main Feed & Drop Button
class MainFeedScreen extends StatelessWidget {
  const MainFeedScreen({super.key});

  /// Hardcoded test data representing Points near the user
  ///
  /// In production, this would come from:
  /// - Supabase PostgREST API (all active Points)
  /// - Client-side filtering using Haversine formula (5km radius)
  /// - Riverpod providers managing async state
  static const List<Map<String, dynamic>> _testPoints = [
    {
      'username': '@TestUser1',
      'content': 'Just found an amazing coffee shop here!',
      'likes': 5,
      'maidenhead': 'FN20sa',
      'distance': '0.8 km',
    },
    {
      'username': '@MapLover42',
      'content': 'Best sunset view in the city! 🌅',
      'likes': 12,
      'maidenhead': 'FN20sb',
      'distance': '2.3 km',
    },
    {
      'username': '@ExplorerJane',
      'content': 'Check out this hidden gem - amazing street art!',
      'likes': 3,
      'maidenhead': 'FN20sc',
      'distance': '1.5 km',
    },
    {
      'username': '@LocalGuide7',
      'content': 'Pro tip: This park has free parking on weekends',
      'likes': 8,
      'maidenhead': 'FN20sd',
      'distance': '4.2 km',
    },
    {
      'username': '@CityExplorer',
      'content': 'The new bike path is finally open! Perfect for evening rides 🚴',
      'likes': 15,
      'maidenhead': 'FN20se',
      'distance': '3.7 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with location-focused title
      appBar: AppBar(
        title: const Text('📍 Near Me'),
        automaticallyImplyLeading: false, // Remove back button (home screen)
      ),

      // Scrollable list of Point cards with blue dividers (v3.0)
      body: ListView.separated(
        padding: const EdgeInsets.only(
          top: AppConstants.spacingSM,
          bottom: AppConstants.spacingXXL + AppConstants.fabSize,
        ),
        itemCount: _testPoints.length,
        separatorBuilder: (context, index) => Divider(
          height: AppConstants.dividerHeight,
          thickness: AppConstants.dividerThickness,
          color: AppTheme.getDividerBlue(Theme.of(context).brightness),
          indent: AppConstants.dividerIndent,
          endIndent: AppConstants.dividerIndent,
        ),
        itemBuilder: (context, index) {
          final point = _testPoints[index];

          return PointCard(
            username: point['username'] as String,
            content: point['content'] as String,
            likes: point['likes'] as int,
            maidenhead: point['maidenhead'] as String,
            distance: point['distance'] as String,
            onLikeTapped: () {
              // Callback already handles logging in PointCard widget
              // In production, this would trigger a use case to persist the like
            },
          );
        },
      ),

      // Floating Action Button with MASSIVE blue glow (v3.0)
      floatingActionButton: _buildFABWithGlow(context),
    );
  }

  /// Build FAB with MASSIVE blue glow effect (v3.0)
  ///
  /// Creates a layered shadow effect with:
  /// - Primary blue glow shadow (24px blur)
  /// - Optional highlight glow in dark mode (32px blur, more spread)
  Widget _buildFABWithGlow(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusFAB),
        boxShadow: [
          // MASSIVE blue glow shadow
          BoxShadow(
            color: AppTheme.getGlowBlue(brightness),
            blurRadius: AppConstants.fabGlowBlur,
            spreadRadius: brightness == Brightness.light
                ? AppConstants.fabGlowSpreadLight
                : AppConstants.fabGlowSpreadDark,
            offset: Offset.zero,
          ),
          // Optional: Add highlight glow in dark mode
          if (brightness == Brightness.dark)
            BoxShadow(
              color: AppTheme.highlightGlow,
              blurRadius: AppConstants.fabHighlightGlowBlur,
              spreadRadius: AppConstants.fabHighlightGlowSpread,
              offset: Offset.zero,
            ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToPointCreation(context),
        child: const Icon(Icons.add_location),
      ),
    );
  }

  /// Navigate to Point Creation screen
  ///
  /// In production, this would first check location permissions and
  /// capture current GPS coordinates before navigating.
  void _navigateToPointCreation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PointCreationScreen(),
      ),
    );
  }
}

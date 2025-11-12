import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Point Creation Screen
///
/// Allows users to compose and post a new Point (location-based message) at
/// their current location.
///
/// This is a UI mockup using hardcoded location data - no actual geolocation,
/// Maidenhead calculation, or API integration is implemented.
///
/// UI Components:
/// - Multi-line text field for message input
/// - Display of captured location (lat/lon and Maidenhead code)
/// - Cancel button (navigates back)
/// - Post button (navigates back, no data persistence)
///
/// Based on UX specification: Screen 4 - Point Creation
class PointCreationScreen extends StatefulWidget {
  const PointCreationScreen({super.key});

  @override
  State<PointCreationScreen> createState() => _PointCreationScreenState();
}

class _PointCreationScreenState extends State<PointCreationScreen> {
  /// Text editing controller for the message input field
  final TextEditingController _messageController = TextEditingController();

  /// Hardcoded coordinates for demonstration
  /// In production, these would come from device geolocation services
  static const String _mockLatitude = '37.7749';
  static const String _mockLongitude = '-122.4194';

  /// Hardcoded Maidenhead grid locator
  /// In production, this would be calculated from GPS coordinates
  /// using the location-spatial-utility agent's Maidenhead converter
  static const String _mockMaidenhead = 'CM87ts';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Drop a Point'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message input section
              Text(
                'Your Message:',
                style: TextStyle(
                  fontSize: AppConstants.textSizeBody,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppConstants.spacingSM),

              // Multi-line text field for Point content
              TextField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 280, // Twitter-like character limit
                decoration: InputDecoration(
                  hintText: 'Share what\'s happening here...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                style: TextStyle(
                  fontSize: AppConstants.textSizeBody,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: AppConstants.spacingLG),

              // Location display section
              Text(
                'Location:',
                style: TextStyle(
                  fontSize: AppConstants.textSizeBody,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppConstants.spacingSM),

              // Coordinates display (read-only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusDefault,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lat: $_mockLatitude, Lon: $_mockLongitude',
                      style: TextStyle(
                        fontSize: AppConstants.textSizeMetadata,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: const [
                          FontFeature.tabularFigures(), // Monospaced numbers
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSM),
                    // Maidenhead code chip (v3.0: SATURATED blue background)
                    Chip(
                      label: Text(
                        _mockMaidenhead,
                        style: TextStyle(
                          fontSize: AppConstants.textSizeMaidenhead,
                          fontWeight: FontWeight.w600, // v3.0: Semibold for prominence
                          color: theme.colorScheme.onPrimaryContainer,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primaryContainer, // v3.0: SATURATED blue (#99CCFF)
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingSM,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons row
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleCancel(context),
                      child: const Text('Cancel'),
                    ),
                  ),

                  const SizedBox(width: AppConstants.spacingMD),

                  // Post button
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _handlePost(context),
                      child: const Text('Post'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle Cancel button tap
  ///
  /// Navigates back to Main Feed without posting.
  void _handleCancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Handle Post button tap
  ///
  /// In production, this would:
  /// 1. Validate message content
  /// 2. Create a Point entity with user ID, message, coordinates, Maidenhead
  /// 3. Invoke a use case to POST to Supabase
  /// 4. Handle success/error states
  /// 5. Navigate back with success feedback
  ///
  /// For this mockup, it just navigates back to demonstrate the flow.
  void _handlePost(BuildContext context) {
    final message = _messageController.text.trim();

    // Basic validation (for demonstration)
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message before posting'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Log the mock post action
    debugPrint('Mock POST: Creating Point with message: "$message"');
    debugPrint('  Location: $_mockLatitude, $_mockLongitude');
    debugPrint('  Maidenhead: $_mockMaidenhead');

    // Navigate back to Main Feed
    Navigator.of(context).pop();

    // In production, would show success feedback after navigation
  }
}

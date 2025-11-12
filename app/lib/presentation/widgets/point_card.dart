import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Point Card Widget
///
/// A reusable card component that displays a single Point (location-based post)
/// with all associated metadata.
///
/// This widget is purely presentational - all data is passed via parameters
/// and callbacks handle user interactions (like button).
///
/// UI Components:
/// - Username (clickable, styled with Location Blue)
/// - Point content/message
/// - Like button with count
/// - Maidenhead grid code in a chip
/// - Distance from user
///
/// Based on UX specification: Point cards in Main Feed
class PointCard extends StatefulWidget {
  /// Username of the Point creator (e.g., "@TestUser1")
  final String username;

  /// The Point's text content/message
  final String content;

  /// Number of likes this Point has received
  final int likes;

  /// Maidenhead grid locator code (6-character format)
  final String maidenhead;

  /// Distance from current user's location (e.g., "0.8 km")
  final String distance;

  /// Callback invoked when the like button is tapped
  /// For this mockup, it just logs to console
  final VoidCallback? onLikeTapped;

  const PointCard({
    super.key,
    required this.username,
    required this.content,
    required this.likes,
    required this.maidenhead,
    required this.distance,
    this.onLikeTapped,
  });

  @override
  State<PointCard> createState() => _PointCardState();
}

class _PointCardState extends State<PointCard> {
  /// Local UI state for like animation
  /// In production, this would be managed by state management layer
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: AppConstants.elevationDefault,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingSM,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username row (v3.0: semibold for prominence)
            Text(
              widget.username,
              style: TextStyle(
                fontSize: AppConstants.textSizeUsername,
                fontWeight: FontWeight.w600, // v3.0: Semibold (was w500)
                color: theme.colorScheme.primary, // Location Blue
              ),
            ),

            const SizedBox(height: AppConstants.spacingSM),

            // Point content
            Text(
              widget.content,
              style: TextStyle(
                fontSize: AppConstants.textSizeBody,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppConstants.spacingMD),

            // Metadata row (like button, Maidenhead, distance)
            Row(
              children: [
                // Like button with count
                InkWell(
                  onTap: _handleLikeTap,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusDefault,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSM,
                      vertical: AppConstants.spacingXS,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          size: AppConstants.iconSizeLarge, // v3.0: Increased from 24dp to 28dp
                          color: _isLiked
                              ? theme.colorScheme.primary // Location Blue
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          '${widget.likes}',
                          style: TextStyle(
                            fontSize: AppConstants.textSizeMetadata,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: AppConstants.spacingMD),

                // Maidenhead code chip (v3.0: SATURATED blue background)
                Chip(
                  label: Text(
                    widget.maidenhead,
                    style: TextStyle(
                      fontSize: AppConstants.textSizeMaidenhead,
                      fontWeight: FontWeight.w600, // v3.0: Semibold for prominence
                      color: theme.colorScheme.onPrimaryContainer,
                      fontFeatures: const [
                        FontFeature.tabularFigures(), // Monospaced numbers
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

                const Spacer(),

                // Distance indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.near_me,
                      size: AppConstants.iconSizeSmall, // v3.0: Slightly increased for more blue presence
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      widget.distance,
                      style: TextStyle(
                        fontSize: AppConstants.textSizeMetadata,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: const [
                          FontFeature.tabularFigures(), // Monospaced numbers
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Handle like button tap
  ///
  /// Toggles local UI state for visual feedback and invokes callback.
  /// In production, this would trigger a use case to persist the like.
  void _handleLikeTap() {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Invoke callback (mockup just logs to console)
    widget.onLikeTapped?.call();

    // Log for demonstration purposes
    debugPrint(
      '${_isLiked ? "Liked" : "Unliked"} Point by ${widget.username}',
    );
  }
}

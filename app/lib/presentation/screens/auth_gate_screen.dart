import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'main_feed_screen.dart';

/// Authentication Gate Screen
///
/// The initial screen shown to unauthenticated users, offering sign-in options
/// via third-party providers (Google and Apple).
///
/// This is a UI mockup only - no actual authentication logic is implemented.
/// Buttons navigate directly to the Main Feed screen for demonstration purposes.
///
/// Based on UX specification: Screen 1 - Authentication Gate
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App branding section
                Text(
                  'tuPoint',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeHeadlineLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Sign in with Google button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _navigateToMainFeed(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingSM,
                      ),
                      child: Text(
                        'Sign In with Google',
                        style: TextStyle(
                          fontSize: AppConstants.textSizeButton,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingMD),

                // Sign in with Apple button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _navigateToMainFeed(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface,
                      foregroundColor: theme.colorScheme.surface,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingSM,
                      ),
                      child: Text(
                        'Sign In with Apple',
                        style: TextStyle(
                          fontSize: AppConstants.textSizeButton,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to Main Feed screen
  ///
  /// In a production app, this would only occur after successful authentication.
  /// For this mockup, navigation happens immediately to demonstrate the UI flow.
  void _navigateToMainFeed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MainFeedScreen(),
      ),
    );
  }
}

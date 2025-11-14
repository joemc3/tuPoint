import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_providers.dart';
import '../../domain/entities/auth_state.dart';

/// Profile Creation Screen
///
/// Shown to authenticated users who have signed in via OAuth (Google/Apple)
/// but haven't created a profile yet. Users must choose a username to continue.
///
/// This screen is only shown once, after OAuth sign-in, when hasProfile = false.
///
/// Based on UX specification: Screen 2 - Profile Creation (Conditional)
class ProfileCreationScreen extends ConsumerStatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  ConsumerState<ProfileCreationScreen> createState() =>
      _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends ConsumerState<ProfileCreationScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    // Listen for state changes to show errors
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Text(
                  'Welcome to tuPoint!',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeHeadlineLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingSM),

                Text(
                  'Pick a username to get started',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeBody,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: '@CoolMapMaker_99',
                    prefixText: '@',
                    helperText:
                        '3-20 characters, letters, numbers, underscores only',
                    helperMaxLines: 2,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (value.trim().length > 20) {
                      return 'Username must be 20 characters or less';
                    }
                    // Basic validation - full validation happens server-side
                    final validPattern = RegExp(r'^[a-zA-Z0-9_]+$');
                    if (!validPattern.hasMatch(value.trim())) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.spacingLG),

                // Bio field (optional)
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio (Optional)',
                    hintText: 'Tell others about yourself...',
                    helperText: 'Max 280 characters',
                  ),
                  maxLines: 3,
                  maxLength: 280,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: authState.maybeWhen(
                      loading: () => null, // Disable during loading
                      orElse: () => _handleCreateProfile,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingSM,
                      ),
                      child: authState.maybeWhen(
                        loading: () => SizedBox(
                          height: AppConstants.textSizeButton,
                          width: AppConstants.textSizeButton,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        orElse: () => const Text('Done'),
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

  /// Handle profile creation
  Future<void> _handleCreateProfile() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get current user ID
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not authenticated. Please sign in again.'),
        ),
      );
      return;
    }

    // Create profile via AuthNotifier
    await ref.read(authNotifierProvider.notifier).completeProfile(
          userId: userId,
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
        );

    // Navigation is handled automatically by AuthGateScreen
    // when authState transitions to authenticated(hasProfile: true)
  }
}

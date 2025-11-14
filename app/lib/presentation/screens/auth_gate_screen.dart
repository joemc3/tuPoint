import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_providers.dart';
import '../../domain/entities/auth_state.dart';
import 'main_feed_screen.dart';
import 'profile_creation_screen.dart';

/// Authentication Gate Screen
///
/// The root screen that determines which screen to show based on auth state:
/// - Unauthenticated → Login screen with OAuth buttons
/// - Authenticated without profile → Profile creation screen
/// - Authenticated with profile → Main feed screen
/// - Loading → Splash screen with loading indicator
/// - Error → Error message with retry
///
/// Based on UX specification: Screen 1 - Authentication Gate
class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Route to appropriate screen based on auth state
    return authState.when(
      unauthenticated: () => const _LoginScreen(),
      authenticated: (userId, hasProfile) {
        if (!hasProfile) {
          return const ProfileCreationScreen();
        }
        return const MainFeedScreen();
      },
      loading: () => const _LoadingScreen(),
      error: (message) => _ErrorScreen(message: message),
    );
  }
}

/// Login Screen - shown when user is not authenticated
class _LoginScreen extends ConsumerStatefulWidget {
  const _LoginScreen();

  @override
  ConsumerState<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<_LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final authState = ref.watch(authStateProvider);

    // Listen for errors during sign-in
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
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
      // v3.0 BLUE DOMINANCE: Bold gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLight
                ? [
                    const Color(0xFFB3DCFF), // Top - SATURATED blue
                    const Color(0xFFD6EEFF), // Bottom - OBVIOUS blue
                  ]
                : [
                    const Color(0xFF0F1A26), // Top - dark blue
                    const Color(0xFF1A2836), // Bottom - lighter blue
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spacingXL),

                // App branding section
                Text(
                  'tuPoint',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeHeadlineLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingSM),

                Text(
                  'what\'s your point?',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeBody,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Email/Password Section (for testing)
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMD),

                      // Email field
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !authState.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMD),

                      // Password field
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          helperText: _isSignUp
                              ? 'Min 6 chars with uppercase, lowercase, and digit'
                              : null,
                          helperMaxLines: 2,
                        ),
                        obscureText: true,
                        enabled: !authState.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        ),
                      ),

                      const SizedBox(height: AppConstants.spacingLG),

                      // Info text for sign up flow
                      if (_isSignUp)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                          child: Text(
                            'After signing up, you\'ll choose your username',
                            style: TextStyle(
                              fontSize: AppConstants.textSizeMetadata,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: authState.maybeWhen(
                            loading: () => null,
                            orElse: () => _handleEmailPasswordAuth,
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
                              orElse: () => Text(
                                _isSignUp ? 'Sign Up' : 'Sign In',
                                style: const TextStyle(
                                  fontSize: AppConstants.textSizeButton,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spacingSM),

                      // Toggle sign in/sign up
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Need an account? Sign Up',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLG),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSM),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingLG),

                // OAuth buttons (disabled for now)
                Opacity(
                  opacity: 0.5,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: null, // Disabled - OAuth not configured
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppConstants.spacingSM,
                            ),
                            child: Text(
                              'Sign In with Google (Not Configured)',
                              style: TextStyle(
                                fontSize: AppConstants.textSizeButton,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: null, // Disabled - OAuth not configured
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.onSurface,
                            foregroundColor: theme.colorScheme.surface,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppConstants.spacingSM,
                            ),
                            child: Text(
                              'Sign In with Apple (Not Configured)',
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
              ],
            ), // End of Column
          ), // End of SingleChildScrollView
        ), // End of SafeArea
      ), // End of Container
    ); // End of Scaffold
  }

  /// Handle email/password authentication (sign in or sign up)
  Future<void> _handleEmailPasswordAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
      return;
    }

    if (_isSignUp) {
      // Sign up - only create auth account, profile creation happens next
      await ref.read(authNotifierProvider.notifier).signUpEmailOnly(
            email: email,
            password: password,
          );
    } else {
      // Sign in
      await ref.read(authNotifierProvider.notifier).signInWithEmail(
            email,
            password,
          );
    }
  }
}

/// Loading Screen - shown during auth state checks
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLight
                ? [
                    const Color(0xFFB3DCFF),
                    const Color(0xFFD6EEFF),
                  ]
                : [
                    const Color(0xFF0F1A26),
                    const Color(0xFF1A2836),
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMD),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: AppConstants.textSizeBody,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error Screen - shown when auth state has an error
class _ErrorScreen extends ConsumerWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppConstants.spacingMD),
              Text(
                'Authentication Error',
                style: TextStyle(
                  fontSize: 24.0, // Medium headline size
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSM),
              Text(
                message,
                style: TextStyle(
                  fontSize: AppConstants.textSizeBody,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingLG),
              FilledButton(
                onPressed: () {
                  // Retry by checking auth status
                  ref.read(authNotifierProvider.notifier).checkAuthStatus();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

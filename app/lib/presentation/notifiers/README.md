# Authentication Notifiers

This directory contains StateNotifiers that manage complex application state using Riverpod.

## AuthNotifier

The `AuthNotifier` manages all authentication state and operations for the application.

### Features

- **Email/Password Authentication**: Sign in and sign up with email/password
- **OAuth Providers**: Google and Apple Sign In support
- **Session Persistence**: Automatically restores auth state on app restart
- **Profile Integration**: Checks profile existence and manages profile creation
- **Error Handling**: User-friendly error messages for all auth scenarios
- **Loading States**: Proper loading state management for async operations

### Usage Examples

#### Basic Sign In

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return authState.when(
      authenticated: (userId, hasProfile) {
        if (!hasProfile) {
          return ProfileCreationScreen();
        }
        return HomeScreen();
      },
      unauthenticated: () => LoginForm(
        onSignIn: (email, password) {
          authNotifier.signInWithEmail(email, password);
        },
      ),
      loading: () => LoadingScreen(),
      error: (message) => ErrorScreen(message: message),
    );
  }
}
```

#### Sign Up with Profile Creation

```dart
class SignUpScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return SignUpForm(
      onSignUp: (email, password, username, bio) {
        // This automatically creates the profile after signup
        authNotifier.signUp(
          email: email,
          password: password,
          username: username,
          bio: bio,
        );
      },
    );
  }
}
```

#### OAuth Sign In

```dart
class OAuthButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () => authNotifier.signInWithGoogle(),
          child: Text('Sign in with Google'),
        ),
        ElevatedButton(
          onPressed: () => authNotifier.signInWithApple(),
          child: Text('Sign in with Apple'),
        ),
      ],
    );
  }
}
```

#### Accessing Current User ID

```dart
class UserProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return LoginPrompt();
    }

    // Use userId for fetching user data
    return FutureBuilder(
      future: fetchUserProfile(userId),
      builder: (context, snapshot) {
        // ... build UI with profile data
      },
    );
  }
}
```

#### Sign Out

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return ElevatedButton(
      onPressed: () async {
        await authNotifier.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
      },
      child: Text('Sign Out'),
    );
  }
}
```

### Auth State Flow

```
App Start
    ↓
[Loading] - Checking for existing session
    ↓
    ├─→ No Session → [Unauthenticated]
    │
    └─→ Session Found → Check Profile
            ↓
            ├─→ Profile Exists → [Authenticated(userId, hasProfile: true)]
            └─→ No Profile → [Authenticated(userId, hasProfile: false)]
                                        ↓
                                Profile Creation Screen
```

### Error Handling

The `AuthNotifier` maps Supabase auth exceptions to user-friendly error messages:

- Invalid credentials → "Invalid email or password. Please try again."
- Email not confirmed → "Please verify your email address before signing in."
- Duplicate email → "An account with this email already exists."
- Weak password → "Password must be at least 6 characters long."
- Network errors → "Network error. Please check your connection."

### Profile Creation Flow

When a user signs up:

1. Create auth account via Supabase Auth
2. Automatically create profile using `CreateProfileUseCase`
3. If profile creation fails (e.g., duplicate username):
   - User remains authenticated but `hasProfile = false`
   - Error message is shown in UI
   - User can retry profile creation with different username

### Session Persistence

The notifier listens to Supabase's `onAuthStateChange` stream, which:

- Automatically restores sessions when the app restarts
- Handles token refresh
- Detects when sessions expire
- Updates app state when user signs out from another device

### Dependencies

The `AuthNotifier` requires:

- `SupabaseClient`: For auth operations
- `CreateProfileUseCase`: For creating profiles during signup
- `FetchProfileUseCase`: For checking profile existence

These dependencies are automatically injected via the `authNotifierProvider`.

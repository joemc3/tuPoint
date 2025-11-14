# tuPoint Authentication Architecture

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Presentation Layer                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────────────────────────────────────┐            │
│  │              AuthGateScreen                          │            │
│  │           (ConsumerWidget - Root Router)             │            │
│  │                                                       │            │
│  │  Routes based on authState:                          │            │
│  │  • unauthenticated → _LoginScreen                    │            │
│  │  • authenticated(hasProfile=false) →                 │            │
│  │      ProfileCreationScreen                           │            │
│  │  • authenticated(hasProfile=true) → MainFeedScreen   │            │
│  │  • loading → _LoadingScreen                          │            │
│  │  • error → _ErrorScreen                              │            │
│  └──────────────────────┬───────────────────────────────┘            │
│                         │                                            │
│                         │ watches authStateProvider                 │
│                         ▼                                            │
│  ┌────────────────────────────────────────────────┐                 │
│  │        authNotifierProvider                    │                 │
│  │        StateNotifierProvider<AuthNotifier,     │                 │
│  │                              AuthState>        │                 │
│  └───────────────┬────────────────────────────────┘                 │
│                  │                                                   │
│                  │ provides                                          │
│                  ▼                                                   │
│  ┌─────────────────────────────────────────────────────────┐        │
│  │                    AuthNotifier                         │        │
│  │              StateNotifier<AuthState>                   │        │
│  │                                                          │        │
│  │  Methods:                                                │        │
│  │  • signInWithEmail(email, password)                     │        │
│  │  • signInWithGoogle()                                   │        │
│  │  • signInWithApple()                                    │        │
│  │  • signUp(email, password, username, bio) [LEGACY]      │        │
│  │  • signUpEmailOnly(email, password) [NEW]               │        │
│  │  • completeProfile(userId, username, bio) [NEW]         │        │
│  │  • signOut()                                             │        │
│  │  • checkAuthStatus()                                    │        │
│  │                                                          │        │
│  │  State: AuthState (Freezed Union)                       │        │
│  │  • Unauthenticated                                       │        │
│  │  • Authenticated(userId, hasProfile)                    │        │
│  │  • Loading                                               │        │
│  │  • Error(message)                                        │        │
│  └──────────┬────────────────────────────┬─────────────────┘        │
│             │                            │                           │
└─────────────┼────────────────────────────┼───────────────────────────┘
              │                            │
              │ uses                       │ uses
              ▼                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           Domain Layer                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────────────┐      ┌────────────────────────┐         │
│  │  CreateProfileUseCase  │      │  FetchProfileUseCase   │         │
│  │                        │      │                        │         │
│  │  • Validates username  │      │  • Checks if profile   │         │
│  │  • Validates bio       │      │    exists              │         │
│  │  • Creates profile     │      │  • Returns Profile or  │         │
│  │    via repository      │      │    NotFoundException   │         │
│  └──────────┬─────────────┘      └──────────┬─────────────┘         │
│             │                               │                        │
│             │ depends on                    │ depends on             │
│             ▼                               ▼                        │
│  ┌──────────────────────────────────────────────────────┐           │
│  │           IProfileRepository (Interface)             │           │
│  │                                                       │           │
│  │  • createProfile(id, username, bio)                  │           │
│  │  • fetchProfileById(id)                              │           │
│  │  • updateProfile(id, username, bio)                  │           │
│  └──────────────────────┬───────────────────────────────┘           │
│                         │                                            │
└─────────────────────────┼────────────────────────────────────────────┘
                          │
                          │ implements
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            Data Layer                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────────────────────────────────────┐           │
│  │       SupabaseProfileRepository                      │           │
│  │       implements IProfileRepository                  │           │
│  │                                                       │           │
│  │  • Communicates with Supabase via PostgREST          │           │
│  │  • Enforces RLS policies                             │           │
│  │  • Maps exceptions to domain exceptions              │           │
│  └──────────────────────┬───────────────────────────────┘           │
│                         │                                            │
│                         │ uses                                       │
│                         ▼                                            │
│  ┌──────────────────────────────────────────────────────┐           │
│  │            Supabase Client                           │           │
│  │                                                       │           │
│  │  • Auth: supabase.auth                               │           │
│  │  • Database: supabase.from('profile')                │           │
│  │  • Session management                                │           │
│  └──────────────────────────────────────────────────────┘           │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

## Authentication State Flow

```
┌─────────────────┐
│   App Starts    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  AuthNotifier._initialize()             │
│  • Subscribes to auth state changes     │
│  • Calls checkAuthStatus()              │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  checkAuthStatus()                      │
│  • Get current session                  │
└────────┬────────────────────────────────┘
         │
         ├───► No Session ─────────────────────┐
         │                                      │
         └───► Session Found                   │
                    │                           │
                    ▼                           │
         ┌──────────────────────┐              │
         │  Check Profile       │              │
         │  via FetchProfile    │              │
         │  UseCase             │              │
         └──────┬───────────────┘              │
                │                               │
                ├───► Profile Exists            │
                │         │                     │
                │         ▼                     │
                │  ┌──────────────────────┐    │
                │  │ Authenticated        │    │
                │  │ (userId,             │    │
                │  │  hasProfile: true)   │    │
                │  └──────────────────────┘    │
                │                               │
                └───► NotFoundException         │
                          │                     │
                          ▼                     │
                   ┌──────────────────────┐    │
                   │ Authenticated        │    │
                   │ (userId,             │    │
                   │  hasProfile: false)  │    │
                   └──────────────────────┘    │
                                                │
                                                ▼
                                         ┌──────────────────┐
                                         │ Unauthenticated  │
                                         └──────────────────┘
```

## Sign Up Flow with Profile Creation

### Modern Flow (Email/Password + OAuth Consistent)

**Step 1: Create Auth Account Only**
```
User clicks "Sign Up"
         │
         ▼
┌─────────────────────────────────────────────┐
│  authNotifier.signUpEmailOnly(              │
│    email, password                          │
│  )                                          │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  Create Auth Account                        │
│  supabase.auth.signUp(email, password)      │
└────────┬────────────────────────────────────┘
         │
         ├───► Success (userId) ──────┐
         │                             │
         └───► Error ────────────┐    │
                                  │    │
                                  │    ▼
                                  │ ┌──────────────────────────────────┐
                                  │ │  Set State:                      │
                                  │ │  Authenticated(userId,           │
                                  │ │    hasProfile: false)            │
                                  │ │                                  │
                                  │ │  → Routes to ProfileCreation     │
                                  │ │     Screen                       │
                                  │ └──────────────────────────────────┘
                                  │
                                  ▼
                           ┌─────────────┐
                           │   Error     │
                           │  (message)  │
                           └─────────────┘
```

**Step 2: Complete Profile (User interaction on ProfileCreationScreen)**
```
User enters username and bio, clicks "Done"
         │
         ▼
┌─────────────────────────────────────────────┐
│  authNotifier.completeProfile(              │
│    userId, username, bio                    │
│  )                                          │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  Create Profile                             │
│  createProfileUseCase(userId, username,     │
│    bio)                                     │
└────────┬────────────────────────────────────┘
         │
         ├───► Success ────────────────────────┐
         │                                      │
         ├───► DuplicateUsername                │
         │          │                           │
         └───► ValidationError                  │
                    │                           │
                    ▼                           ▼
          ┌──────────────────┐        ┌──────────────────┐
          │  Authenticated   │        │  Authenticated   │
          │  (userId,        │        │  (userId,        │
          │   hasProfile:    │        │   hasProfile:    │
          │   false)         │        │   true)          │
          │                  │        │                  │
          │  +               │        │  → Routes to     │
          │  Error(message)  │        │     MainFeed     │
          └──────────────────┘        └──────────────────┘
```

### Legacy Flow (Direct Sign Up with Username)

**Note**: The `signUp(email, password, username, bio)` method still exists for programmatic use but is not used by the UI. It creates both auth account and profile in a single operation.

```
authNotifier.signUp(email, password, username, bio)
         │
         ├───► Step 1: Create Auth Account
         │
         └───► Step 2: Create Profile (automatic)
                    │
                    ├───► Success → Authenticated(hasProfile: true)
                    │
                    └───► Error → Authenticated(hasProfile: false) + Error
```

## Provider Dependency Graph

```
authNotifierProvider
    │
    ├─► supabaseClientProvider (from repository_providers.dart)
    │
    ├─► createProfileUseCaseProvider
    │       │
    │       └─► profileRepositoryProvider
    │               │
    │               └─► supabaseClientProvider
    │
    └─► fetchProfileUseCaseProvider
            │
            └─► profileRepositoryProvider
                    │
                    └─► supabaseClientProvider

Convenience Providers:
    authStateProvider
        └─► authNotifierProvider

    currentUserIdProvider
        └─► authStateProvider

    hasProfileProvider
        └─► authStateProvider
```

## OAuth Flow

```
User clicks "Sign in with Google"
         │
         ▼
┌─────────────────────────────────────────────┐
│  authNotifier.signInWithGoogle()            │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  supabase.auth.signInWithOAuth(             │
│    OAuthProvider.google,                    │
│    redirectTo: 'io.supabase.tupoint://...'  │
│  )                                          │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  State: Loading                             │
│  (OAuth flow in progress)                   │
└────────┬────────────────────────────────────┘
         │
         │  User completes OAuth in browser/dialog
         │
         ▼
┌─────────────────────────────────────────────┐
│  Redirect back to app                       │
│  io.supabase.tupoint://login-callback/      │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  Supabase auth.onAuthStateChange fires      │
│  • Session created with user                │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  AuthNotifier listener updates state        │
│  • Calls _checkProfileAfterAuthChange()     │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  Check if profile exists                    │
└────────┬────────────────────────────────────┘
         │
         ├───► Profile Exists ────► Authenticated(userId, hasProfile: true)
         │
         └───► No Profile ────────► Authenticated(userId, hasProfile: false)
                                    (User needs to create profile)
```

## Session Persistence

```
App Closed
    │
    ▼
Supabase stores session in secure storage
    │
    ▼
App Reopened
    │
    ▼
┌─────────────────────────────────────────────┐
│  AuthNotifier._initialize()                 │
│  • Subscribes to onAuthStateChange          │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  Supabase automatically restores session    │
│  from secure storage                        │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  onAuthStateChange emits session            │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  AuthNotifier listener updates state        │
│  • User is automatically signed in          │
│  • State: Authenticated(userId, hasProfile) │
└─────────────────────────────────────────────┘
```

## Error Handling Strategy

```
Auth Operation
    │
    ▼
Try-Catch Block
    │
    ├───► AuthException ────────► Map to user-friendly message
    │         │                    │
    │         │                    ├─► "Invalid email or password"
    │         │                    ├─► "Please verify your email"
    │         │                    ├─► "Account already exists"
    │         │                    ├─► "Password too weak"
    │         │                    └─► "Network error"
    │         │
    │         └──────────────────► State: Error(message)
    │
    ├───► ValidationException ───► State: Error(message)
    │                               (from use case validation)
    │
    ├───► DuplicateUsernameException ─► State: Authenticated(userId, false)
    │                                    + Error(message)
    │
    └───► Generic Exception ──────► State: Error("Unexpected error")
```

## Key Design Patterns

1. **State Pattern**: AuthState union type for type-safe state management
2. **Repository Pattern**: IProfileRepository abstraction with Supabase implementation
3. **Use Case Pattern**: Business logic encapsulated in use cases
4. **Observer Pattern**: Listening to Supabase auth state changes
5. **Dependency Injection**: Providers inject dependencies via constructor
6. **Error Mapping**: Transform backend errors to domain exceptions
7. **Optimistic UI**: Show loading state immediately, update when complete

## Security Considerations

1. **Session Storage**: Supabase stores tokens in secure platform-specific storage
2. **Token Refresh**: Supabase automatically refreshes JWT tokens
3. **RLS Enforcement**: Profile repository enforces Row Level Security
4. **Validation**: Use cases validate all input before database calls
5. **Error Messages**: Don't leak sensitive information in error messages
6. **OAuth Redirect**: Uses app-specific deep link for security

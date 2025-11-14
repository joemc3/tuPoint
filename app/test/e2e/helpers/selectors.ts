/**
 * Centralized Selectors for tuPoint E2E Tests
 *
 * This file contains all selectors used across tests to make maintenance easier.
 * When UI changes, update selectors here instead of in individual test files.
 *
 * Note: Flutter web doesn't expose traditional HTML selectors, so we primarily use:
 * - Text content matching
 * - ARIA roles and labels
 * - Placeholder text
 * - CSS selectors for specific cases (gradient validation, colors)
 */

/**
 * Authentication Screen Selectors
 */
export const AuthSelectors = {
  // App branding
  appTitle: 'tuPoint',
  tagline: "what's your point?",

  // Email/Password form
  emailInput: 'Email',
  passwordInput: 'Password',
  signUpButton: 'Sign Up',
  signInButton: 'Sign In',
  toggleSignUpLink: 'Need an account? Sign Up',
  toggleSignInLink: 'Already have an account? Sign In',

  // OAuth buttons (disabled in current implementation)
  googleSignInButton: 'Sign In with Google (Not Configured)',
  appleSignInButton: 'Sign In with Apple (Not Configured)',

  // Loading states
  loadingSpinner: 'role=progressbar',

  // Error messages
  snackbar: 'role=alert',
  emptyFieldsError: 'Please enter email and password',

  // Form sections
  createAccountHeader: 'Create Account',
  signInHeader: 'Sign In',
  infoText: "After signing up, you'll choose your username",
} as const;

/**
 * Profile Creation Screen Selectors
 */
export const ProfileSelectors = {
  // Screen header
  pageTitle: 'Create Profile',
  welcomeMessage: 'Welcome to tuPoint!',
  subtitle: 'Pick a username to get started',

  // Form fields
  usernameInput: 'Username',
  usernamePlaceholder: '@CoolMapMaker_99',
  bioInput: 'Bio (Optional)',
  bioPlaceholder: 'Tell others about yourself...',

  // Submit button
  doneButton: 'Done',

  // Loading states
  loadingSpinner: 'role=progressbar',

  // Validation messages
  usernameRequired: 'Username is required',
  usernameTooShort: 'Username must be at least 3 characters',
  usernameTooLong: 'Username must be 20 characters or less',
  usernameInvalidChars: 'Username can only contain letters, numbers, and underscores',

  // Helper text
  usernameHelper: '3-20 characters, letters, numbers, underscores only',
  bioHelper: 'Max 280 characters',
} as const;

/**
 * Main Feed Screen Selectors
 */
export const FeedSelectors = {
  // App bar
  appBarTitle: 'tuPoint',

  // FAB (Floating Action Button)
  createPointFAB: 'Create Point',

  // Points list
  pointCard: 'role=article', // Point cards should have article role
  pointContent: '.point-content',
  pointUsername: '.point-username',
  pointDistance: '.point-distance',
  pointTime: '.point-timestamp',

  // Like button
  likeButton: 'role=button[name*="like"]',

  // Empty state
  emptyMessage: 'No points nearby',
  emptySubtext: 'Be the first to drop a point!',

  // Loading state
  loadingIndicator: 'role=progressbar',
} as const;

/**
 * Theme-related Selectors (CSS)
 */
export const ThemeSelectors = {
  // Background gradient
  gradientContainer: 'flt-semantics', // Flutter semantic container

  // Point cards
  pointCard: 'flt-semantics[role="article"]',

  // FAB
  fab: 'role=button[name="Create Point"]',

  // Snackbar
  snackbar: 'role=alert',
} as const;

/**
 * Helper function to get input by label (case-insensitive)
 */
export function getInputByLabel(label: string): string {
  return `role=textbox[name="${label}"i]`;
}

/**
 * Helper function to get button by text (exact match)
 */
export function getButtonByText(text: string): string {
  return `role=button[name="${text}"]`;
}

/**
 * Helper function to wait for Flutter to be ready
 * Returns a selector that can be used with page.waitForSelector()
 */
export const FLUTTER_READY_SELECTOR = 'flt-glass-pane';

/**
 * Common timeouts (in milliseconds)
 */
export const Timeouts = {
  SHORT: 2000,   // For fast operations (button clicks)
  MEDIUM: 5000,  // For API calls
  LONG: 10000,   // For page loads
  FLUTTER: 15000, // For Flutter app initialization
} as const;

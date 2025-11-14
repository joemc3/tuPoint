/**
 * Test User Fixtures for tuPoint E2E Tests
 *
 * This file contains test data used across tests.
 * Use these fixtures for consistent test data.
 */

/**
 * Valid test credentials
 */
export const ValidCredentials = {
  email: 'testuser@example.com',
  password: 'ValidPass123',
  username: 'test_user_valid',
  bio: 'I am a test user for automated testing',
} as const;

/**
 * Invalid email addresses for validation testing
 */
export const InvalidEmails = {
  missing_at: 'invalid.email.com',
  missing_domain: 'invalid@',
  missing_username: '@example.com',
  spaces: 'test user@example.com',
  special_chars: 'test!user@example.com',
} as const;

/**
 * Invalid passwords for validation testing
 */
export const InvalidPasswords = {
  too_short: '12345',              // Less than 6 characters
  no_uppercase: 'testpass123',     // No uppercase letter
  no_lowercase: 'TESTPASS123',     // No lowercase letter
  no_number: 'TestPassword',       // No digit
  only_letters: 'TestPass',        // No digit
  empty: '',                       // Empty password
} as const;

/**
 * Valid passwords for testing
 */
export const ValidPasswords = {
  standard: 'TestPass123',
  with_special: 'Test@Pass123',
  long: 'VeryLongTestPassword123',
  minimum: 'Aa1bcd',              // Exactly 6 chars with all requirements
} as const;

/**
 * Invalid usernames for validation testing
 */
export const InvalidUsernames = {
  too_short: 'ab',                // Less than 3 characters
  too_long: 'a'.repeat(21),       // More than 20 characters
  with_spaces: 'test user',       // Contains spaces
  with_special: 'test@user',      // Contains special characters
  with_hyphen: 'test-user',       // Contains hyphen
  empty: '',                      // Empty username
} as const;

/**
 * Valid usernames for testing
 */
export const ValidUsernames = {
  short: 'abc',                   // Exactly 3 characters
  long: 'a'.repeat(20),           // Exactly 20 characters
  with_underscore: 'test_user_99', // Contains underscore
  with_numbers: 'user123',        // Contains numbers
  mixed: 'Test_User_2024',        // Mixed case with underscore and numbers
} as const;

/**
 * Valid bios for testing
 */
export const ValidBios = {
  short: 'Hello!',
  medium: 'I love dropping points on the map and exploring my neighborhood.',
  long: 'A'.repeat(280),          // Maximum length (280 characters)
  with_emoji: 'Map enthusiast 🗺️ | Explorer 🧭 | Point dropper 📍',
  multiline: 'Line 1\nLine 2\nLine 3',
} as const;

/**
 * Test point data for main feed testing
 */
export const TestPoints = {
  nearby: {
    content: 'Test point nearby',
    distance: '50m',
  },
  far: {
    content: 'Test point far away',
    distance: '4.5km',
  },
  recent: {
    content: 'Just dropped!',
    timestamp: 'Just now',
  },
  old: {
    content: 'Posted a while ago',
    timestamp: '2 hours ago',
  },
} as const;

/**
 * Expected error messages from the backend/frontend
 */
export const ExpectedErrors = {
  // Auth errors
  invalidCredentials: 'Invalid login credentials',
  userAlreadyExists: 'User already registered',
  weakPassword: 'Password should be at least 6 characters',
  invalidEmail: 'Invalid email',
  emptyFields: 'Please enter email and password',

  // Profile errors
  usernameRequired: 'Username is required',
  usernameTooShort: 'Username must be at least 3 characters',
  usernameTooLong: 'Username must be 20 characters or less',
  usernameInvalidChars: 'Username can only contain letters, numbers, and underscores',
  usernameTaken: 'Username already taken',

  // Network errors
  networkError: 'Network request failed',
  timeout: 'Request timed out',
} as const;

/**
 * Theme colors (for validation)
 */
export const ThemeColors = {
  light: {
    locationBlue: '#3A9BFC',
    backgroundStart: '#B3DCFF',  // Top gradient
    backgroundEnd: '#D6EEFF',    // Bottom gradient
    cardBackground: '#F0F7FF',
    chipBackground: '#99CCFF',
  },
  dark: {
    locationBlue: '#66B8FF',      // Electric blue
    backgroundStart: '#0F1A26',   // Blue-tinted dark
    backgroundEnd: '#1A2836',     // Lighter blue
    cardBackground: '#1A2836',
    primary: '#66B8FF',
  },
} as const;

/**
 * Helper function to generate test user data
 */
export function generateTestUser(index: number = 0) {
  const timestamp = Date.now();
  return {
    email: `testuser${index}_${timestamp}@test.tupoint.local`,
    password: ValidPasswords.standard,
    username: `testuser${index}_${timestamp}`,
    bio: `Test user #${index} created at ${new Date().toISOString()}`,
  };
}

/**
 * Helper function to generate multiple test users
 */
export function generateTestUsers(count: number) {
  return Array.from({ length: count }, (_, i) => generateTestUser(i));
}

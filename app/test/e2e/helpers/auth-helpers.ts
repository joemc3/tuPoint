import { Page, expect } from '@playwright/test';
import { AuthSelectors, ProfileSelectors, Timeouts } from './selectors';
import {
  waitForLoadingToComplete,
  isOnScreen,
  generateUniqueEmail,
  generateUniqueUsername,
} from './test-setup';

/**
 * Authentication Helper Functions for tuPoint E2E Tests
 *
 * This file contains reusable functions for authentication flows.
 */

/**
 * Sign up a new user with email and password
 *
 * @param page - Playwright page object
 * @param email - Email address (defaults to unique test email)
 * @param password - Password (defaults to valid password)
 * @returns Object containing the credentials used
 */
export async function signUpWithEmail(
  page: Page,
  email?: string,
  password: string = 'TestPass123'
): Promise<{ email: string; password: string }> {
  const testEmail = email || generateUniqueEmail();

  // Should be on login screen
  await expect(page.getByText(AuthSelectors.appTitle)).toBeVisible();

  // Toggle to sign up mode if not already
  const toggleButton = page.getByText(AuthSelectors.toggleSignUpLink);
  const isVisible = await toggleButton.isVisible().catch(() => false);
  if (isVisible) {
    await toggleButton.click();
  }

  // Fill in email and password
  await page.getByLabel(AuthSelectors.emailInput).fill(testEmail);
  await page.getByLabel(AuthSelectors.passwordInput).fill(password);

  // Click sign up button
  await page.getByRole('button', { name: AuthSelectors.signUpButton }).click();

  // Wait for loading to complete
  await waitForLoadingToComplete(page);

  return { email: testEmail, password };
}

/**
 * Sign in an existing user with email and password
 *
 * @param page - Playwright page object
 * @param email - Email address
 * @param password - Password
 */
export async function signInWithEmail(
  page: Page,
  email: string,
  password: string
): Promise<void> {
  // Should be on login screen
  await expect(page.getByText(AuthSelectors.appTitle)).toBeVisible();

  // Toggle to sign in mode if not already
  const toggleButton = page.getByText(AuthSelectors.toggleSignUpLink);
  const isVisible = await toggleButton.isVisible().catch(() => false);
  if (isVisible) {
    // We're in sign up mode, need to toggle to sign in
    // Do nothing, we're already in sign up mode
  } else {
    // Check if we need to toggle to sign in
    const signInToggle = page.getByText(AuthSelectors.toggleSignInLink);
    const needsToggle = await signInToggle.isVisible().catch(() => false);
    if (needsToggle) {
      await signInToggle.click();
    }
  }

  // Fill in credentials
  await page.getByLabel(AuthSelectors.emailInput).fill(email);
  await page.getByLabel(AuthSelectors.passwordInput).fill(password);

  // Click sign in button
  await page.getByRole('button', { name: AuthSelectors.signInButton }).click();

  // Wait for loading to complete
  await waitForLoadingToComplete(page);
}

/**
 * Complete profile creation
 *
 * @param page - Playwright page object
 * @param username - Username (defaults to unique test username)
 * @param bio - Bio (optional)
 * @returns Object containing the profile data used
 */
export async function completeProfile(
  page: Page,
  username?: string,
  bio?: string
): Promise<{ username: string; bio?: string }> {
  const testUsername = username || generateUniqueUsername();

  // Should be on profile creation screen
  await expect(page.getByText(ProfileSelectors.pageTitle)).toBeVisible();

  // Fill in username
  await page.getByLabel(ProfileSelectors.usernameInput).fill(testUsername);

  // Fill in bio if provided
  if (bio) {
    await page.getByLabel(ProfileSelectors.bioInput).fill(bio);
  }

  // Click done button
  await page.getByRole('button', { name: ProfileSelectors.doneButton }).click();

  // Wait for loading to complete
  await waitForLoadingToComplete(page);

  return { username: testUsername, bio };
}

/**
 * Complete full sign up flow (email + password + profile creation)
 *
 * @param page - Playwright page object
 * @param email - Email (optional, defaults to unique)
 * @param password - Password (optional, defaults to valid password)
 * @param username - Username (optional, defaults to unique)
 * @param bio - Bio (optional)
 * @returns Object containing all credentials and profile data
 */
export async function completeSignUpFlow(
  page: Page,
  email?: string,
  password?: string,
  username?: string,
  bio?: string
): Promise<{
  email: string;
  password: string;
  username: string;
  bio?: string;
}> {
  // Sign up with email
  const credentials = await signUpWithEmail(page, email, password);

  // Complete profile
  const profile = await completeProfile(page, username, bio);

  return { ...credentials, ...profile };
}

/**
 * Check if user is authenticated (on main feed screen)
 *
 * @param page - Playwright page object
 * @returns true if authenticated
 */
export async function isAuthenticated(page: Page): Promise<boolean> {
  // Check for main feed screen indicators
  // Looking for the app bar or FAB
  return await isOnScreen(page, 'Create Point');
}

/**
 * Check if user is on login screen
 *
 * @param page - Playwright page object
 * @returns true if on login screen
 */
export async function isOnLoginScreen(page: Page): Promise<boolean> {
  return await isOnScreen(page, AuthSelectors.tagline);
}

/**
 * Check if user is on profile creation screen
 *
 * @param page - Playwright page object
 * @returns true if on profile creation screen
 */
export async function isOnProfileCreationScreen(page: Page): Promise<boolean> {
  return await isOnScreen(page, ProfileSelectors.welcomeMessage);
}

/**
 * Attempt to sign up with invalid credentials and expect error
 *
 * @param page - Playwright page object
 * @param email - Email address
 * @param password - Password
 * @param expectedError - Expected error message (partial match)
 */
export async function signUpExpectingError(
  page: Page,
  email: string,
  password: string,
  expectedError: string
): Promise<void> {
  // Toggle to sign up mode
  const toggleButton = page.getByText(AuthSelectors.toggleSignUpLink);
  const isVisible = await toggleButton.isVisible().catch(() => false);
  if (isVisible) {
    await toggleButton.click();
  }

  // Fill in credentials
  await page.getByLabel(AuthSelectors.emailInput).fill(email);
  await page.getByLabel(AuthSelectors.passwordInput).fill(password);

  // Click sign up button
  await page.getByRole('button', { name: AuthSelectors.signUpButton }).click();

  // Wait for error snackbar
  await page.waitForTimeout(Timeouts.SHORT);

  // Verify error message appears
  await expect(page.getByText(expectedError, { exact: false })).toBeVisible();
}

/**
 * Attempt to sign in with invalid credentials and expect error
 *
 * @param page - Playwright page object
 * @param email - Email address
 * @param password - Password
 * @param expectedError - Expected error message (partial match)
 */
export async function signInExpectingError(
  page: Page,
  email: string,
  password: string,
  expectedError: string
): Promise<void> {
  // Ensure we're in sign in mode
  const toggleButton = page.getByText(AuthSelectors.toggleSignInLink);
  const needsToggle = await toggleButton.isVisible().catch(() => false);
  if (!needsToggle) {
    // Already in sign in mode
  } else {
    await toggleButton.click();
  }

  // Fill in credentials
  await page.getByLabel(AuthSelectors.emailInput).fill(email);
  await page.getByLabel(AuthSelectors.passwordInput).fill(password);

  // Click sign in button
  await page.getByRole('button', { name: AuthSelectors.signInButton }).click();

  // Wait for error snackbar
  await page.waitForTimeout(Timeouts.SHORT);

  // Verify error message appears
  await expect(page.getByText(expectedError, { exact: false })).toBeVisible();
}

/**
 * Validate that password field shows helper text in sign up mode
 *
 * @param page - Playwright page object
 */
export async function expectPasswordHelperText(page: Page): Promise<void> {
  // Should show helper text in sign up mode
  await expect(
    page.getByText('Min 6 chars with uppercase, lowercase, and digit')
  ).toBeVisible();
}

/**
 * Validate username field rules in profile creation
 *
 * @param page - Playwright page object
 * @param username - Username to test
 * @param expectedError - Expected validation error
 */
export async function validateUsername(
  page: Page,
  username: string,
  expectedError: string
): Promise<void> {
  // Should be on profile creation screen
  await expect(page.getByText(ProfileSelectors.pageTitle)).toBeVisible();

  // Fill in invalid username
  await page.getByLabel(ProfileSelectors.usernameInput).fill(username);

  // Try to submit
  await page.getByRole('button', { name: ProfileSelectors.doneButton }).click();

  // Verify error message
  await expect(page.getByText(expectedError)).toBeVisible();
}

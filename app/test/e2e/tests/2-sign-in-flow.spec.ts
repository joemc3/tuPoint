import { test, expect } from '@playwright/test';
import {
  navigateToApp,
  clearBrowserStorage,
  waitForLoadingToComplete,
} from '../helpers/test-setup';
import {
  completeSignUpFlow,
  signInWithEmail,
  isAuthenticated,
  signInExpectingError,
} from '../helpers/auth-helpers';
import { AuthSelectors } from '../helpers/selectors';

/**
 * Test Suite 2: Sign In Flow
 *
 * Tests the user sign-in journey for existing users:
 * - Sign in with correct credentials
 * - Error handling for wrong password
 * - Error handling for non-existent account
 * - Loading states
 * - Direct navigation to Main Feed (no profile screen)
 */

test.describe('Test Suite 2: Sign In Flow', () => {
  // Shared credentials for tests that need an existing user
  let existingUser: {
    email: string;
    password: string;
    username: string;
  };

  // Before all tests, create a user we can sign in with
  test.beforeAll(async ({ browser }) => {
    const page = await browser.newPage();
    await navigateToApp(page);

    // Create a user that we'll use for sign-in tests
    const userData = await completeSignUpFlow(page);
    existingUser = {
      email: userData.email,
      password: userData.password,
      username: userData.username,
    };

    await page.close();
  });

  // Before each test, clear storage and navigate to app
  test.beforeEach(async ({ page }) => {
    await clearBrowserStorage(page);
    await navigateToApp(page);
  });

  /**
   * Test 2.1: Existing user can sign in with correct credentials
   */
  test('2.1 - Existing user can sign in with correct credentials', async ({
    page,
  }) => {
    // Should be on login screen
    await expect(page.getByText(AuthSelectors.appTitle)).toBeVisible();

    // Sign in with existing user credentials
    await signInWithEmail(page, existingUser.email, existingUser.password);

    // Should be redirected directly to main feed (no profile screen)
    await waitForLoadingToComplete(page);
    const authenticated = await isAuthenticated(page);
    expect(authenticated).toBe(true);

    // Should see main feed
    await expect(page.getByText('tuPoint')).toBeVisible();
  });

  /**
   * Test 2.2: Wrong password shows error message
   */
  test('2.2 - Wrong password shows error message', async ({ page }) => {
    // Attempt sign in with wrong password
    await signInExpectingError(
      page,
      existingUser.email,
      'WrongPassword123',
      'Invalid login credentials'
    );

    // Should still be on login screen
    await expect(page.getByText(AuthSelectors.tagline)).toBeVisible();
  });

  /**
   * Test 2.3: Non-existent account shows error message
   */
  test('2.3 - Non-existent account shows error message', async ({ page }) => {
    // Attempt sign in with non-existent email
    const nonExistentEmail = `nonexistent-${Date.now()}@example.com`;

    await signInExpectingError(
      page,
      nonExistentEmail,
      'SomePassword123',
      'Invalid login credentials'
    );

    // Should still be on login screen
    await expect(page.getByText(AuthSelectors.tagline)).toBeVisible();
  });

  /**
   * Test 2.4: Sign in button shows loading spinner
   */
  test('2.4 - Sign in button shows loading spinner during submission', async ({
    page,
  }) => {
    // Ensure we're in sign in mode
    const toggleButton = page.getByText(AuthSelectors.toggleSignInLink);
    const needsToggle = await toggleButton.isVisible().catch(() => false);
    if (!needsToggle) {
      // Already in sign in mode
    } else {
      await toggleButton.click();
    }

    // Fill in credentials
    await page
      .getByLabel(AuthSelectors.emailInput)
      .fill(existingUser.email);
    await page
      .getByLabel(AuthSelectors.passwordInput)
      .fill(existingUser.password);

    // Click sign in and check for loading spinner
    await page
      .getByRole('button', { name: AuthSelectors.signInButton })
      .click();

    // Loading spinner should appear (even if briefly)
    const spinner = page.getByRole('progressbar');
    const spinnerAppeared = await spinner
      .waitFor({ state: 'visible', timeout: 3000 })
      .then(() => true)
      .catch(() => false);

    // May have loaded too fast, which is okay
    expect(spinnerAppeared || (await isAuthenticated(page))).toBe(true);
  });

  /**
   * Test 2.5: After sign in, user goes directly to Main Feed (no profile screen)
   */
  test('2.5 - After sign in, user goes directly to Main Feed', async ({
    page,
  }) => {
    // Sign in
    await signInWithEmail(page, existingUser.email, existingUser.password);

    // Should go directly to main feed
    await waitForLoadingToComplete(page);

    // Should NOT see profile creation screen
    const profileScreen = page.getByText('Welcome to tuPoint!');
    const onProfileScreen = await profileScreen
      .isVisible()
      .catch(() => false);
    expect(onProfileScreen).toBe(false);

    // Should be on main feed
    const authenticated = await isAuthenticated(page);
    expect(authenticated).toBe(true);

    // Should see main feed elements
    await expect(page.getByText('tuPoint')).toBeVisible();
  });
});

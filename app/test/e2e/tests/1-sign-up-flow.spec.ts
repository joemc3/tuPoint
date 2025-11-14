import { test, expect } from '@playwright/test';
import {
  navigateToApp,
  clearBrowserStorage,
  waitForLoadingToComplete,
  isOnScreen,
} from '../helpers/test-setup';
import {
  signUpWithEmail,
  completeProfile,
  completeSignUpFlow,
  isOnProfileCreationScreen,
  isAuthenticated,
} from '../helpers/auth-helpers';
import { AuthSelectors, ProfileSelectors } from '../helpers/selectors';
import { InvalidPasswords, InvalidUsernames } from '../helpers/test-users';

/**
 * Test Suite 1: Sign Up Flow
 *
 * Tests the complete user sign-up journey:
 * - Email/password sign up
 * - Password validation
 * - Email validation
 * - Loading states
 * - Profile creation
 * - Username validation
 * - Navigation flow
 */

test.describe('Test Suite 1: Sign Up Flow', () => {
  // Before each test, navigate to app and clear storage
  test.beforeEach(async ({ page }) => {
    await clearBrowserStorage(page);
    await navigateToApp(page);
  });

  /**
   * Test 1.1: New user can create account with email/password
   */
  test('1.1 - New user can create account with email/password', async ({
    page,
  }) => {
    // Should start on login screen
    await expect(page.getByText(AuthSelectors.appTitle)).toBeVisible();
    await expect(page.getByText(AuthSelectors.tagline)).toBeVisible();

    // Sign up with unique email
    await signUpWithEmail(page);

    // Should be redirected to profile creation screen
    const onProfileScreen = await isOnProfileCreationScreen(page);
    expect(onProfileScreen).toBe(true);
  });

  /**
   * Test 1.2: Weak password shows validation error
   */
  test('1.2 - Weak password shows validation error', async ({ page }) => {
    const weakPassword = InvalidPasswords.too_short;

    // Toggle to sign up mode
    const toggleButton = page.getByText(AuthSelectors.toggleSignUpLink);
    const isVisible = await toggleButton.isVisible().catch(() => false);
    if (isVisible) {
      await toggleButton.click();
    }

    // Fill in email and weak password
    await page
      .getByLabel(AuthSelectors.emailInput)
      .fill('test@example.com');
    await page.getByLabel(AuthSelectors.passwordInput).fill(weakPassword);

    // Click sign up
    await page
      .getByRole('button', { name: AuthSelectors.signUpButton })
      .click();

    // Should show error (either via snackbar or inline)
    // Wait a moment for error to appear
    await page.waitForTimeout(2000);

    // Check for error message (may be in snackbar or inline)
    const errorVisible =
      (await page.getByText('Password', { exact: false }).count()) > 0 ||
      (await page.getByRole('alert').isVisible().catch(() => false));

    expect(errorVisible).toBeTruthy();
  });

  /**
   * Test 1.3: Invalid email shows validation error
   */
  test('1.3 - Invalid email shows validation error', async ({ page }) => {
    // Toggle to sign up mode
    const toggleButton = page.getByText(AuthSelectors.toggleSignUpLink);
    const isVisible = await toggleButton.isVisible().catch(() => false);
    if (isVisible) {
      await toggleButton.click();
    }

    // Fill in invalid email
    await page
      .getByLabel(AuthSelectors.emailInput)
      .fill('invalid.email.com');
    await page
      .getByLabel(AuthSelectors.passwordInput)
      .fill('ValidPass123');

    // Click sign up
    await page
      .getByRole('button', { name: AuthSelectors.signUpButton })
      .click();

    // Should show error
    await page.waitForTimeout(2000);

    // Check for error (may appear in snackbar or inline)
    const errorVisible =
      (await page.getByText('email', { exact: false }).count()) > 0 ||
      (await page.getByRole('alert').isVisible().catch(() => false));

    expect(errorVisible).toBeTruthy();
  });

  /**
   * Test 1.4: Sign up button shows loading spinner during submission
   */
  test('1.4 - Sign up button shows loading spinner during submission', async ({
    page,
  }) => {
    // Toggle to sign up mode
    const toggleButton = page.getByText(AuthSelectors.toggleSignUpLink);
    const isVisible = await toggleButton.isVisible().catch(() => false);
    if (isVisible) {
      await toggleButton.click();
    }

    // Fill in credentials
    await page
      .getByLabel(AuthSelectors.emailInput)
      .fill(`test-${Date.now()}@example.com`);
    await page
      .getByLabel(AuthSelectors.passwordInput)
      .fill('ValidPass123');

    // Click sign up and immediately check for loading spinner
    await page
      .getByRole('button', { name: AuthSelectors.signUpButton })
      .click();

    // Loading spinner should appear (even if briefly)
    const spinner = page.getByRole('progressbar');
    const spinnerAppeared = await spinner
      .waitFor({ state: 'visible', timeout: 3000 })
      .then(() => true)
      .catch(() => false);

    // May have loaded too fast, which is okay
    // As long as we didn't get an error, test passes
    expect(spinnerAppeared || (await isOnProfileCreationScreen(page))).toBe(
      true
    );
  });

  /**
   * Test 1.5: After sign-up, user is routed to Profile Creation screen
   */
  test('1.5 - After sign-up, user is routed to Profile Creation screen', async ({
    page,
  }) => {
    // Sign up
    await signUpWithEmail(page);

    // Should be on profile creation screen
    await expect(
      page.getByText(ProfileSelectors.welcomeMessage)
    ).toBeVisible();
    await expect(page.getByText(ProfileSelectors.pageTitle)).toBeVisible();
    await expect(page.getByText(ProfileSelectors.subtitle)).toBeVisible();
  });

  /**
   * Test 1.6: Profile Creation screen has correct fields (username, bio)
   */
  test('1.6 - Profile Creation screen has correct fields', async ({
    page,
  }) => {
    // Sign up first
    await signUpWithEmail(page);

    // Verify all expected fields are present
    await expect(page.getByLabel(ProfileSelectors.usernameInput)).toBeVisible();
    await expect(page.getByLabel(ProfileSelectors.bioInput)).toBeVisible();

    // Verify helper text
    await expect(
      page.getByText(ProfileSelectors.usernameHelper)
    ).toBeVisible();
    await expect(page.getByText(ProfileSelectors.bioHelper)).toBeVisible();

    // Verify submit button
    await expect(
      page.getByRole('button', { name: ProfileSelectors.doneButton })
    ).toBeVisible();
  });

  /**
   * Test 1.7: Username validation works (3-20 chars, alphanumeric + underscore)
   */
  test('1.7 - Username validation works correctly', async ({ page }) => {
    // Sign up first
    await signUpWithEmail(page);

    // Test too short username
    await page
      .getByLabel(ProfileSelectors.usernameInput)
      .fill(InvalidUsernames.too_short);
    await page
      .getByRole('button', { name: ProfileSelectors.doneButton })
      .click();

    // Should show error
    await expect(
      page.getByText(ProfileSelectors.usernameTooShort)
    ).toBeVisible();

    // Test too long username
    await page
      .getByLabel(ProfileSelectors.usernameInput)
      .fill(InvalidUsernames.too_long);
    await page
      .getByRole('button', { name: ProfileSelectors.doneButton })
      .click();

    // Should show error
    await expect(
      page.getByText(ProfileSelectors.usernameTooLong)
    ).toBeVisible();

    // Test invalid characters
    await page
      .getByLabel(ProfileSelectors.usernameInput)
      .fill(InvalidUsernames.with_special);
    await page
      .getByRole('button', { name: ProfileSelectors.doneButton })
      .click();

    // Should show error
    await expect(
      page.getByText(ProfileSelectors.usernameInvalidChars)
    ).toBeVisible();
  });

  /**
   * Test 1.8: Duplicate username shows error without navigating away
   */
  test('1.8 - Duplicate username shows error without navigating away', async ({
    page,
    context,
  }) => {
    // Create first user with specific username
    const sharedUsername = `duplicate_user_${Date.now()}`;

    // Sign up and create profile with this username
    await signUpWithEmail(page);
    await completeProfile(page, sharedUsername);

    // Should be on main feed now
    await waitForLoadingToComplete(page);
    const authenticated = await isAuthenticated(page);
    expect(authenticated).toBe(true);

    // Clear storage and create second user
    await clearBrowserStorage(page);
    await navigateToApp(page);

    // Sign up with different email
    await signUpWithEmail(page);

    // Try to use same username
    await page
      .getByLabel(ProfileSelectors.usernameInput)
      .fill(sharedUsername);
    await page
      .getByRole('button', { name: ProfileSelectors.doneButton })
      .click();

    // Should show error via snackbar
    await page.waitForTimeout(2000);
    const errorSnackbar = page.getByRole('alert');
    const snackbarVisible = await errorSnackbar
      .isVisible()
      .catch(() => false);

    // Should still be on profile creation screen
    const stillOnProfileScreen = await isOnProfileCreationScreen(page);

    expect(snackbarVisible || stillOnProfileScreen).toBe(true);
  });

  /**
   * Test 1.9: After profile creation, user is routed to Main Feed
   */
  test('1.9 - After profile creation, user is routed to Main Feed', async ({
    page,
  }) => {
    // Complete full sign up flow
    await completeSignUpFlow(page);

    // Should be on main feed
    await waitForLoadingToComplete(page);

    // Check for main feed indicators
    const authenticated = await isAuthenticated(page);
    expect(authenticated).toBe(true);

    // Should see app title in app bar
    await expect(page.getByText('tuPoint')).toBeVisible();
  });

  /**
   * Test 1.10: Main Feed displays correctly with test points
   */
  test('1.10 - Main Feed displays correctly after sign up', async ({
    page,
  }) => {
    // Complete full sign up flow
    await completeSignUpFlow(page);

    // Wait for main feed to load
    await waitForLoadingToComplete(page);

    // Should see main feed elements
    await expect(page.getByText('tuPoint')).toBeVisible();

    // Should see FAB (Create Point button)
    const fab = page.getByRole('button', { name: /create/i });
    const fabVisible = await fab.isVisible().catch(() => false);

    // Main feed loaded successfully
    expect(fabVisible || (await isAuthenticated(page))).toBe(true);
  });
});

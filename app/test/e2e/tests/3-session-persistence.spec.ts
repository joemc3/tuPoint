import { test, expect } from '@playwright/test';
import {
  navigateToApp,
  clearBrowserStorage,
  waitForLoadingToComplete,
} from '../helpers/test-setup';
import {
  completeSignUpFlow,
  isAuthenticated,
  isOnLoginScreen,
} from '../helpers/auth-helpers';
import { AuthSelectors } from '../helpers/selectors';

/**
 * Test Suite 3: Session Persistence
 *
 * Tests that user sessions persist correctly:
 * - Page refresh maintains session
 * - New browser tab maintains session
 * - Unauthenticated user sees login screen after refresh
 */

test.describe('Test Suite 3: Session Persistence', () => {
  /**
   * Test 3.1: Page refresh maintains authenticated session
   */
  test('3.1 - Page refresh maintains authenticated session', async ({
    page,
  }) => {
    // Create and sign in user
    await navigateToApp(page);
    await completeSignUpFlow(page);
    await waitForLoadingToComplete(page);

    // Verify authenticated
    let authenticated = await isAuthenticated(page);
    expect(authenticated).toBe(true);

    // Refresh the page
    await page.reload();
    await waitForLoadingToComplete(page);

    // Should still be authenticated
    authenticated = await isAuthenticated(page);
    expect(authenticated).toBe(true);

    // Should still see main feed
    await expect(page.getByText('tuPoint')).toBeVisible();
  });

  /**
   * Test 3.2: New browser tab maintains session
   */
  test('3.2 - New browser tab maintains session', async ({
    page,
    context,
  }) => {
    // Create and sign in user
    await navigateToApp(page);
    await completeSignUpFlow(page);
    await waitForLoadingToComplete(page);

    // Verify authenticated
    let authenticated = await isAuthenticated(page);
    expect(authenticated).toBe(true);

    // Open new tab in same context
    const newPage = await context.newPage();
    await navigateToApp(newPage);
    await waitForLoadingToComplete(newPage);

    // Should be authenticated in new tab
    authenticated = await isAuthenticated(newPage);
    expect(authenticated).toBe(true);

    // Should see main feed in new tab
    await expect(newPage.getByText('tuPoint')).toBeVisible();

    await newPage.close();
  });

  /**
   * Test 3.3: Unauthenticated user sees login screen after refresh
   */
  test('3.3 - Unauthenticated user sees login screen after refresh', async ({
    page,
  }) => {
    // Navigate to app without signing in
    await clearBrowserStorage(page);
    await navigateToApp(page);

    // Should see login screen
    let onLoginScreen = await isOnLoginScreen(page);
    expect(onLoginScreen).toBe(true);

    // Refresh the page
    await page.reload();
    await waitForLoadingToComplete(page);

    // Should still see login screen
    onLoginScreen = await isOnLoginScreen(page);
    expect(onLoginScreen).toBe(true);

    // Should see login elements
    await expect(page.getByText(AuthSelectors.appTitle)).toBeVisible();
    await expect(page.getByText(AuthSelectors.tagline)).toBeVisible();
  });
});

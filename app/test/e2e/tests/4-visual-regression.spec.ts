import { test, expect } from '@playwright/test';
import {
  navigateToApp,
  clearBrowserStorage,
  waitForLoadingToComplete,
} from '../helpers/test-setup';
import { signUpWithEmail, completeSignUpFlow } from '../helpers/auth-helpers';

/**
 * Test Suite 4: Visual Regression
 *
 * Tests visual consistency across theme changes:
 * - Login screen (light and dark mode)
 * - Profile creation screen (light and dark mode)
 * - Main feed screen (light and dark mode)
 *
 * Note: First run will capture baseline screenshots.
 * Subsequent runs will compare against baselines.
 */

test.describe('Test Suite 4: Visual Regression', () => {
  /**
   * Helper function to set color scheme
   */
  async function setColorScheme(page: any, scheme: 'light' | 'dark') {
    await page.emulateMedia({ colorScheme: scheme });
    // Small wait for theme to apply
    await page.waitForTimeout(500);
  }

  /**
   * Test 4.1: Login screen matches baseline (light mode)
   */
  test('4.1 - Login screen matches baseline screenshot (light mode)', async ({
    page,
  }) => {
    await clearBrowserStorage(page);
    await setColorScheme(page, 'light');
    await navigateToApp(page);

    // Take screenshot and compare to baseline
    await expect(page).toHaveScreenshot('login-light.png', {
      fullPage: true,
      maxDiffPixels: 100, // Allow minor rendering differences
    });
  });

  /**
   * Test 4.2: Login screen matches baseline (dark mode)
   */
  test('4.2 - Login screen matches baseline screenshot (dark mode)', async ({
    page,
  }) => {
    await clearBrowserStorage(page);
    await setColorScheme(page, 'dark');
    await navigateToApp(page);

    // Take screenshot and compare to baseline
    await expect(page).toHaveScreenshot('login-dark.png', {
      fullPage: true,
      maxDiffPixels: 100,
    });
  });

  /**
   * Test 4.3: Profile creation screen matches baseline (light mode)
   */
  test('4.3 - Profile creation screen matches baseline (light mode)', async ({
    page,
  }) => {
    await clearBrowserStorage(page);
    await setColorScheme(page, 'light');
    await navigateToApp(page);

    // Sign up to get to profile screen
    await signUpWithEmail(page);

    // Take screenshot of profile creation screen
    await expect(page).toHaveScreenshot('profile-creation-light.png', {
      fullPage: true,
      maxDiffPixels: 100,
    });
  });

  /**
   * Test 4.4: Profile creation screen matches baseline (dark mode)
   */
  test('4.4 - Profile creation screen matches baseline (dark mode)', async ({
    page,
  }) => {
    await clearBrowserStorage(page);
    await setColorScheme(page, 'dark');
    await navigateToApp(page);

    // Sign up to get to profile screen
    await signUpWithEmail(page);

    // Take screenshot of profile creation screen
    await expect(page).toHaveScreenshot('profile-creation-dark.png', {
      fullPage: true,
      maxDiffPixels: 100,
    });
  });

  /**
   * Test 4.5: Main feed screen matches baseline (light mode)
   */
  test('4.5 - Main feed screen matches baseline (light mode)', async ({
    page,
  }) => {
    await clearBrowserStorage(page);
    await setColorScheme(page, 'light');
    await navigateToApp(page);

    // Complete sign up to get to main feed
    await completeSignUpFlow(page);
    await waitForLoadingToComplete(page);

    // Small wait for feed to render
    await page.waitForTimeout(1000);

    // Take screenshot of main feed
    await expect(page).toHaveScreenshot('main-feed-light.png', {
      fullPage: true,
      maxDiffPixels: 150, // Feed may have dynamic content
    });
  });

  /**
   * Test 4.6: Main feed screen matches baseline (dark mode)
   */
  test('4.6 - Main feed screen matches baseline (dark mode)', async ({
    page,
  }) => {
    await clearBrowserStorage(page);
    await setColorScheme(page, 'dark');
    await navigateToApp(page);

    // Complete sign up to get to main feed
    await completeSignUpFlow(page);
    await waitForLoadingToComplete(page);

    // Small wait for feed to render
    await page.waitForTimeout(1000);

    // Take screenshot of main feed
    await expect(page).toHaveScreenshot('main-feed-dark.png', {
      fullPage: true,
      maxDiffPixels: 150, // Feed may have dynamic content
    });
  });
});

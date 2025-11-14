import { Page } from '@playwright/test';
import { FLUTTER_READY_SELECTOR, Timeouts } from './selectors';

/**
 * Test Setup Utilities for tuPoint E2E Tests
 *
 * This file contains common setup and teardown functions used across all tests.
 */

/**
 * Wait for Flutter web app to be fully loaded and ready
 *
 * @param page - Playwright page object
 */
export async function waitForFlutterReady(page: Page): Promise<void> {
  // Wait for Flutter's glass pane to be present (indicates Flutter is loaded)
  await page.waitForSelector(FLUTTER_READY_SELECTOR, {
    timeout: Timeouts.FLUTTER,
  });

  // Additional wait for Flutter framework to finish initialization
  await page.waitForFunction(
    () => {
      // Check if Flutter framework is ready
      const flutterApp = document.querySelector('flt-glass-pane');
      return flutterApp !== null;
    },
    { timeout: Timeouts.FLUTTER }
  );

  // Small buffer to ensure all initial renders are complete
  await page.waitForTimeout(1000);
}

/**
 * Navigate to the app and wait for it to be ready
 *
 * @param page - Playwright page object
 */
export async function navigateToApp(page: Page): Promise<void> {
  await page.goto('/');
  await waitForFlutterReady(page);
}

/**
 * Clear all browser storage (localStorage, sessionStorage, cookies)
 * Useful for ensuring clean state between tests
 *
 * @param page - Playwright page object
 */
export async function clearBrowserStorage(page: Page): Promise<void> {
  await page.context().clearCookies();
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
}

/**
 * Reset database to clean state via Supabase
 * This ensures tests start with a known state
 *
 * NOTE: This requires Supabase CLI to be running and accessible
 */
export async function resetTestDatabase(): Promise<void> {
  // This would typically call a Supabase migration reset
  // For now, we'll rely on unique test data (timestamped emails)
  // to avoid conflicts
  console.log('Database reset: Using unique test data per test run');
}

/**
 * Take a screenshot with a descriptive name
 *
 * @param page - Playwright page object
 * @param name - Screenshot name (without extension)
 * @param folder - Subfolder in screenshots/ (default: 'failures')
 */
export async function takeScreenshot(
  page: Page,
  name: string,
  folder: 'failures' | 'baseline' | 'diffs' = 'failures'
): Promise<void> {
  const path = `screenshots/${folder}/${name}.png`;
  await page.screenshot({ path, fullPage: true });
}

/**
 * Wait for a snackbar to appear with specific text
 *
 * @param page - Playwright page object
 * @param expectedText - Expected snackbar message (partial match)
 * @returns The snackbar element
 */
export async function waitForSnackbar(
  page: Page,
  expectedText?: string
): Promise<void> {
  const snackbar = page.getByRole('alert');
  await snackbar.waitFor({ state: 'visible', timeout: Timeouts.MEDIUM });

  if (expectedText) {
    await page.getByText(expectedText, { exact: false }).waitFor({
      state: 'visible',
      timeout: Timeouts.SHORT,
    });
  }
}

/**
 * Wait for a snackbar to disappear
 *
 * @param page - Playwright page object
 */
export async function waitForSnackbarToDisappear(page: Page): Promise<void> {
  const snackbar = page.getByRole('alert');
  await snackbar.waitFor({ state: 'hidden', timeout: Timeouts.MEDIUM });
}

/**
 * Wait for a loading spinner to disappear
 *
 * @param page - Playwright page object
 */
export async function waitForLoadingToComplete(page: Page): Promise<void> {
  const spinner = page.getByRole('progressbar');
  await spinner.waitFor({ state: 'hidden', timeout: Timeouts.LONG });
}

/**
 * Check if we're on a specific screen by looking for a unique text element
 *
 * @param page - Playwright page object
 * @param screenIdentifier - Unique text that identifies the screen
 * @returns true if on the expected screen
 */
export async function isOnScreen(
  page: Page,
  screenIdentifier: string
): Promise<boolean> {
  try {
    await page.getByText(screenIdentifier).waitFor({
      state: 'visible',
      timeout: Timeouts.SHORT,
    });
    return true;
  } catch {
    return false;
  }
}

/**
 * Generate a unique email for testing
 * Uses timestamp to ensure uniqueness across test runs
 *
 * @param prefix - Email prefix (default: 'test')
 * @returns Unique email address
 */
export function generateUniqueEmail(prefix: string = 'test'): string {
  const timestamp = Date.now();
  return `${prefix}-${timestamp}@test.tupoint.local`;
}

/**
 * Generate a unique username for testing
 *
 * @param prefix - Username prefix (default: 'testuser')
 * @returns Unique username
 */
export function generateUniqueUsername(prefix: string = 'testuser'): string {
  const timestamp = Date.now();
  return `${prefix}_${timestamp}`;
}

/**
 * Extract computed styles for theme validation
 *
 * @param page - Playwright page object
 * @param selector - CSS selector for the element
 * @returns Object containing relevant computed styles
 */
export async function getComputedStyles(
  page: Page,
  selector: string
): Promise<Record<string, string>> {
  return await page.evaluate((sel) => {
    const element = document.querySelector(sel);
    if (!element) return {};

    const styles = window.getComputedStyle(element);
    return {
      backgroundColor: styles.backgroundColor,
      color: styles.color,
      borderColor: styles.borderColor,
      borderWidth: styles.borderWidth,
      boxShadow: styles.boxShadow,
    };
  }, selector);
}

/**
 * Check if an element has a gradient background
 *
 * @param page - Playwright page object
 * @param selector - CSS selector for the element
 * @returns true if element has gradient background
 */
export async function hasGradientBackground(
  page: Page,
  selector: string
): Promise<boolean> {
  return await page.evaluate((sel) => {
    const element = document.querySelector(sel);
    if (!element) return false;

    const styles = window.getComputedStyle(element);
    const backgroundImage = styles.backgroundImage;

    return (
      backgroundImage.includes('gradient') ||
      backgroundImage.includes('linear-gradient')
    );
  }, selector);
}

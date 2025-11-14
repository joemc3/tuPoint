import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright Configuration for tuPoint Flutter Web E2E Tests
 *
 * Phase 6.1A: Authentication Flow Testing
 *
 * See https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  // Test directory
  testDir: './tests',

  // Maximum time one test can run (30 seconds)
  timeout: 30 * 1000,

  // Maximum time to wait for expect() assertions (5 seconds)
  expect: {
    timeout: 5000,
  },

  // Run tests in files in parallel
  fullyParallel: false, // Sequential to avoid database conflicts

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry on CI only
  retries: process.env.CI ? 2 : 1,

  // Opt out of parallel tests on CI
  workers: 1, // Single worker to avoid database conflicts

  // Reporter to use
  reporter: [
    ['html', { outputFolder: 'reports', open: 'never' }],
    ['list'],
    ['json', { outputFile: 'reports/test-results.json' }],
  ],

  // Shared settings for all the projects below
  use: {
    // Base URL to use in actions like `await page.goto('/')`
    // NOTE: Update this to match your Flutter web dev server port
    baseURL: process.env.FLUTTER_URL || 'http://localhost:53241',

    // Collect trace when retrying the failed test
    trace: 'retain-on-failure',

    // Screenshot on failure
    screenshot: 'only-on-failure',

    // Video on first retry
    video: 'retain-on-failure',

    // Desktop viewport (not mobile)
    viewport: { width: 1280, height: 720 },

    // Increased action timeout for Flutter rendering
    actionTimeout: 10 * 1000,

    // Increased navigation timeout for Flutter app loading
    navigationTimeout: 20 * 1000,
  },

  // Configure projects for major browsers
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        // Flutter web works best in Chrome
        launchOptions: {
          args: [
            '--disable-web-security', // Allow CORS for local dev
            '--disable-features=IsolateOrigins,site-per-process',
          ],
        },
      },
    },

    // Uncomment for cross-browser testing (future)
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },
    //
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    // },
  ],

  // Run your local dev server before starting the tests
  // NOTE: Comment this out if you're running Flutter web manually
  // webServer: {
  //   command: 'cd ../.. && flutter run -d web-server --web-port=53241',
  //   port: 53241,
  //   timeout: 120 * 1000,
  //   reuseExistingServer: !process.env.CI,
  // },
});

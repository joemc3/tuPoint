# tuPoint E2E Tests (Phase 6.1A)

Automated end-to-end tests for tuPoint authentication flow using Playwright.

## 📋 Test Coverage

### Test Suite 1: Sign Up Flow (10 tests)
- ✅ New user account creation with email/password
- ✅ Weak password validation
- ✅ Invalid email validation
- ✅ Loading spinner during submission
- ✅ Navigation to Profile Creation screen
- ✅ Profile Creation screen field validation
- ✅ Username validation (3-20 chars, alphanumeric + underscore)
- ✅ Duplicate username error handling
- ✅ Navigation to Main Feed after profile creation
- ✅ Main Feed display validation

### Test Suite 2: Sign In Flow (5 tests)
- ✅ Existing user sign in with correct credentials
- ✅ Wrong password error handling
- ✅ Non-existent account error handling
- ✅ Loading spinner during sign in
- ✅ Direct navigation to Main Feed (skip profile screen)

### Test Suite 3: Session Persistence (3 tests)
- ✅ Page refresh maintains authenticated session
- ✅ New browser tab maintains session
- ✅ Unauthenticated user sees login screen after refresh

### Test Suite 4: Visual Regression (6 tests)
- ✅ Login screen baseline comparison (light mode)
- ✅ Login screen baseline comparison (dark mode)
- ✅ Profile creation screen baseline comparison (light mode)
- ✅ Profile creation screen baseline comparison (dark mode)
- ✅ Main feed screen baseline comparison (light mode)
- ✅ Main feed screen baseline comparison (dark mode)

### Test Suite 5: Theme Compliance (5 tests)
- ✅ Blue gradient background on login screen
- ✅ Main feed renders with theme styling
- ✅ FAB (Create Point button) has blue styling
- ✅ Tagline displays "what's your point?" correctly
- ✅ App uses consistent color scheme

### Test Suite 6: Error Handling (4 tests)
- ✅ Authentication errors show appropriate messages
- ✅ Error snackbar appears at bottom of screen
- ✅ Error snackbar auto-dismisses after timeout
- ✅ Error snackbar has appropriate error styling

**Total: 33 E2E tests**

---

## 🚀 Prerequisites

### 1. Playwright MCP Server
The tests run through the Playwright MCP server in your Docker MCP gateway.

**Verify MCP server is running:**
```bash
# Check Docker containers
docker ps | grep mcp

# The Playwright MCP server should be configured in your MCP gateway
```

### 2. Supabase
Supabase must be running for authentication tests.

```bash
# Start Supabase
cd /Users/joemc3/tmp/tuPoint
supabase start

# Verify it's running
supabase status
```

### 3. Flutter Web App
The Flutter web app must be running on localhost.

```bash
# Terminal 1: Start Flutter web app
cd app
flutter run -d chrome

# Note the port (usually http://localhost:53241)
```

### 4. Node.js and Playwright
Install Playwright and dependencies:

```bash
# Navigate to e2e test directory
cd app/test/e2e

# Install dependencies
npm install

# Install Playwright browsers (if not using MCP server directly)
npx playwright install chromium
```

---

## 🧪 Running Tests

### Run All Tests
```bash
cd app/test/e2e
npx playwright test
```

### Run Specific Test Suite
```bash
# Test Suite 1: Sign Up Flow
npx playwright test 1-sign-up-flow

# Test Suite 2: Sign In Flow
npx playwright test 2-sign-in-flow

# Test Suite 3: Session Persistence
npx playwright test 3-session-persistence

# Test Suite 4: Visual Regression
npx playwright test 4-visual-regression

# Test Suite 5: Theme Compliance
npx playwright test 5-theme-compliance

# Test Suite 6: Error Handling
npx playwright test 6-error-handling
```

### Run Single Test
```bash
# Run a specific test by name
npx playwright test -g "1.1 - New user can create account"
```

### Run Tests in UI Mode (Interactive)
```bash
npx playwright test --ui
```

### Run Tests in Debug Mode
```bash
npx playwright test --debug
```

### Run Tests with Headed Browser (Visual)
```bash
npx playwright test --headed
```

---

## 📊 Viewing Test Results

### HTML Report
After running tests, view the HTML report:

```bash
npx playwright show-report reports
```

This opens an interactive HTML report showing:
- Test pass/fail status
- Screenshots of failures
- Trace files for debugging
- Execution time per test

### Console Output
Tests output results to console in real-time:

```
✓ Test Suite 1: Sign Up Flow › 1.1 - New user can create account (3.2s)
✓ Test Suite 1: Sign Up Flow › 1.2 - Weak password shows validation error (1.8s)
...

33 passed (2.5m)
```

### Screenshots
- **Baseline screenshots**: `screenshots/baseline/`
- **Failure screenshots**: `screenshots/failures/`
- **Visual diff images**: `screenshots/diffs/`

### Trace Files
For failed tests, trace files are saved in `traces/` and can be viewed:

```bash
npx playwright show-trace traces/test-name-trace.zip
```

---

## 🔧 Configuration

### Update Flutter Web App URL
If your Flutter app runs on a different port, update `playwright.config.ts`:

```typescript
export default defineConfig({
  use: {
    baseURL: 'http://localhost:YOUR_PORT', // Change this
  },
});
```

Or set an environment variable:

```bash
FLUTTER_URL=http://localhost:8080 npx playwright test
```

### Adjust Timeouts
If tests are timing out, increase timeouts in `playwright.config.ts`:

```typescript
export default defineConfig({
  timeout: 60 * 1000, // 60 seconds per test
  use: {
    actionTimeout: 15 * 1000, // 15 seconds for actions
    navigationTimeout: 30 * 1000, // 30 seconds for page loads
  },
});
```

---

## 🖼️ Updating Baseline Screenshots

When you intentionally change the UI design, update baseline screenshots:

### Option 1: Delete and Regenerate
```bash
# Delete old baselines
rm -rf screenshots/baseline/*

# Run visual regression tests (creates new baselines)
npx playwright test 4-visual-regression --update-snapshots
```

### Option 2: Update Specific Baselines
```bash
# Update only light mode baselines
npx playwright test 4-visual-regression -g "light mode" --update-snapshots

# Update only dark mode baselines
npx playwright test 4-visual-regression -g "dark mode" --update-snapshots
```

---

## 🐛 Troubleshooting

### Tests Fail to Connect to Flutter App
**Problem**: `Error: page.goto: net::ERR_CONNECTION_REFUSED`

**Solution**:
1. Verify Flutter web app is running: `curl http://localhost:53241`
2. Check the port in `playwright.config.ts` matches your Flutter app
3. Make sure Supabase is running: `supabase status`

### Flaky Tests
**Problem**: Tests pass sometimes, fail other times

**Solution**:
1. Increase wait times in helpers (`Timeouts` constants)
2. Add explicit waits instead of fixed delays
3. Check for race conditions in async operations

### Visual Regression False Positives
**Problem**: Screenshot tests fail but images look identical

**Solution**:
1. Increase `maxDiffPixels` in test configuration
2. Mask dynamic content (timestamps, etc.)
3. Ensure consistent viewport size and rendering

### MCP Server Not Connected
**Problem**: Tests can't connect to Playwright MCP server

**Solution**:
1. Verify Docker MCP gateway is running: `docker ps | grep mcp`
2. Check MCP configuration in Claude Code settings
3. Restart Docker MCP gateway if needed

### Database Conflicts
**Problem**: Tests fail due to duplicate data

**Solution**:
1. Tests use unique timestamped emails (should avoid conflicts)
2. Reset Supabase database: `supabase db reset`
3. Run tests sequentially (already configured)

---

## 📝 Writing New Tests

### Test Structure
```typescript
import { test, expect } from '@playwright/test';
import { navigateToApp, clearBrowserStorage } from '../helpers/test-setup';

test.describe('My Test Suite', () => {
  test.beforeEach(async ({ page }) => {
    await clearBrowserStorage(page);
    await navigateToApp(page);
  });

  test('My test case', async ({ page }) => {
    // Test implementation
    await expect(page.getByText('Something')).toBeVisible();
  });
});
```

### Use Helper Functions
```typescript
import { signUpWithEmail, completeProfile } from '../helpers/auth-helpers';
import { waitForLoadingToComplete } from '../helpers/test-setup';

// Sign up a user
await signUpWithEmail(page);

// Complete profile
await completeProfile(page, 'testuser', 'Bio text');

// Wait for loading
await waitForLoadingToComplete(page);
```

### Use Test Fixtures
```typescript
import { ValidPasswords, InvalidEmails } from '../fixtures/test-users';

// Use predefined test data
await page.getByLabel('Password').fill(ValidPasswords.standard);
```

---

## 🎯 Best Practices

### 1. Use Unique Test Data
Always use timestamped emails/usernames to avoid conflicts:

```typescript
const uniqueEmail = `test-${Date.now()}@example.com`;
```

### 2. Clean State Before Each Test
```typescript
test.beforeEach(async ({ page }) => {
  await clearBrowserStorage(page);
  await navigateToApp(page);
});
```

### 3. Use Explicit Waits
```typescript
// ❌ BAD
await page.waitForTimeout(2000);

// ✅ GOOD
await page.waitForSelector('[role="button"]', { state: 'visible' });
```

### 4. Use Semantic Selectors
```typescript
// ✅ GOOD - Uses text/role
await page.getByRole('button', { name: 'Sign Up' }).click();
await page.getByText('tuPoint').isVisible();

// ⚠️ OK - Uses label
await page.getByLabel('Email').fill('test@example.com');

// ❌ AVOID - Fragile CSS selectors
await page.locator('.button-class-name').click();
```

### 5. Handle Async Properly
```typescript
// Always await async operations
await waitForLoadingToComplete(page);
await signUpWithEmail(page);
```

---

## 📚 Additional Resources

- [Playwright Documentation](https://playwright.dev)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Flutter Web Testing](https://docs.flutter.dev/testing/overview)
- [tuPoint Architecture](/project_standards/architecture_and_state_management.md)
- [tuPoint Testing Strategy](/project_standards/testing_strategy.md)

---

## 🆘 Getting Help

If you encounter issues:

1. **Check the HTML report** for detailed error messages and screenshots
2. **Run tests in debug mode** to step through failures: `npx playwright test --debug`
3. **View trace files** for detailed execution logs: `npx playwright show-trace traces/...`
4. **Check Prerequisites** - Ensure Supabase, Flutter app, and MCP server are all running
5. **Review CLAUDE.md** for project-specific requirements

---

## ✅ Success Criteria

Phase 6.1A is complete when:

- ✅ All 33 tests passing (≥95% pass rate)
- ✅ Test execution time < 5 minutes
- ✅ HTML reports generating correctly
- ✅ Baseline screenshots captured for both themes
- ✅ Visual regression detection working
- ✅ Flake rate < 5%

---

**Created**: 2025-11-14
**Phase**: 6.1A - Playwright UI Testing
**Status**: Implementation Complete

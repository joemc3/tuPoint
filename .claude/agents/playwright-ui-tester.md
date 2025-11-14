# playwright-ui-tester

**Type**: Specialized Testing Agent
**Purpose**: Execute automated UI tests using Playwright via MCP server integration
**Trigger**: Invoke after UI changes, theme updates, or authentication flow modifications

---

## When to Use This Agent

### Automatic Triggers
- After modifying any screen in `app/lib/presentation/screens/`
- After updating theme files in `app/lib/core/theme/`
- After changing state notifiers that affect UI behavior
- Before merging UI-related pull requests

### Manual Invocation
- When validating complete user flows end-to-end
- After fixing bugs related to authentication or navigation
- When updating baseline screenshots (intentional design changes)
- When running pre-deployment validation

---

## Agent Capabilities

### Test Execution
1. **E2E Test Orchestration**
   - Execute Playwright test suites via MCP server
   - Run tests sequentially or in parallel
   - Handle test retries for flaky tests
   - Generate detailed execution reports

2. **Visual Testing**
   - Capture screenshots at key checkpoints
   - Compare against baseline images
   - Detect pixel-level visual regressions
   - Test both light and dark themes

3. **Functional Testing**
   - Validate form inputs and validation logic
   - Test loading states and transitions
   - Verify error handling and snackbar behavior
   - Check session persistence and auth flows

4. **Performance Monitoring**
   - Track page load times
   - Measure interaction responsiveness
   - Identify performance regressions

---

## Test Environment Setup

### Prerequisites (Verified Before Execution)
```bash
# 1. Supabase must be running
supabase status | grep "API URL" || echo "❌ Start Supabase first"

# 2. Flutter web app must be running
curl http://localhost:PORT || echo "❌ Start Flutter web app"

# 3. MCP Playwright server must be accessible
# Agent will verify MCP connection before test execution
```

### Environment Configuration
```typescript
// app/test/e2e/playwright.config.ts
export default {
  testDir: './tests',
  timeout: 30000,
  retries: 2, // Retry flaky tests
  use: {
    baseURL: 'http://localhost:PORT',
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
    viewport: { width: 1280, height: 720 },
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
};
```

---

## Test Execution Workflow

### Step 1: Pre-Flight Checks
Agent verifies:
- ✅ MCP Playwright server is accessible
- ✅ Flutter web app is running and reachable
- ✅ Supabase is running (for auth tests)
- ✅ Test database is in clean state

### Step 2: Test Execution
```typescript
// Agent executes tests via MCP server
await playwright.runTest('auth_flow.spec.ts');
await playwright.runTest('profile_creation.spec.ts');
await playwright.runTest('visual_regression.spec.ts');
// ... etc
```

### Step 3: Result Analysis
Agent parses results and identifies:
- ✅ Passed tests (GREEN)
- ❌ Failed tests (RED) - with screenshots
- ⚠️ Flaky tests (YELLOW) - passed on retry
- ⏭️ Skipped tests (GRAY)

### Step 4: Report Generation
Agent creates:
- **HTML Report** (`app/test/e2e/reports/latest.html`)
  - Test suite summary
  - Failed test screenshots
  - Trace files for debugging
  - Visual diff images

- **Console Summary**
  ```
  ✅ Test Suite 1: Sign Up Flow - 10/10 passing
  ✅ Test Suite 2: Sign In Flow - 5/5 passing
  ❌ Test Suite 3: Session Persistence - 2/3 passing
     ❌ Test 3.2: New browser tab maintains session (FAILED)
  ✅ Test Suite 4: Visual Regression - 6/6 passing
  ✅ Test Suite 5: Theme Compliance - 5/5 passing
  ✅ Test Suite 6: Error Handling - 4/4 passing

  Overall: 32/33 tests passing (96.97%)
  ```

### Step 5: Failure Diagnosis
For each failed test, agent provides:
- **Screenshot** of failure state
- **Stack trace** with error details
- **Suggested fix** based on common patterns
- **Related code** locations to check

---

## Test Coverage

### Phase 6.1: Authentication Flow (33 tests)
- ✅ **Suite 1**: Sign Up Flow (10 tests)
- ✅ **Suite 2**: Sign In Flow (5 tests)
- ✅ **Suite 3**: Session Persistence (3 tests)
- ✅ **Suite 4**: Visual Regression (6 tests)
- ✅ **Suite 5**: Theme Compliance (5 tests)
- ✅ **Suite 6**: Error Handling (4 tests)

### Future Expansion
- **Phase 6.2**: Main Feed tests (point rendering, likes)
- **Phase 6.3**: Point Creation tests (GPS, Maidenhead)
- **Phase 6.4**: Location Permission tests

---

## Common Issues & Solutions

### Issue 1: Flaky Tests Due to Timing
**Symptom**: Test passes sometimes, fails other times
**Solution**: Use explicit waits instead of fixed delays
```typescript
// ❌ BAD
await page.waitForTimeout(2000);

// ✅ GOOD
await page.waitForSelector('[data-testid="main-feed"]', { state: 'visible' });
```

### Issue 2: Selector Not Found
**Symptom**: `Error: Element not found`
**Solution**: Check if Flutter has rendered the element
```typescript
// Wait for Flutter framework to be ready
await page.waitForFunction(() => window.flutterReady === true);
```

### Issue 3: Visual Regression False Positive
**Symptom**: Screenshot differs but looks identical
**Solution**: Adjust pixel threshold or mask dynamic content
```typescript
await expect(page).toHaveScreenshot('login.png', {
  maxDiffPixels: 100, // Allow minor rendering differences
  mask: [page.locator('.timestamp')], // Mask dynamic content
});
```

---

## Output Artifacts

### Generated Files
```
app/test/e2e/
├── reports/
│   ├── latest.html                  # Latest test report
│   └── 2025-11-14-14-30-00.html     # Timestamped reports
├── screenshots/
│   ├── baseline/                    # Baseline screenshots
│   │   ├── login-light.png
│   │   ├── login-dark.png
│   │   └── ...
│   ├── failures/                    # Failure screenshots
│   │   └── test-3.2-failed.png
│   └── diffs/                       # Visual diff images
│       └── login-light-diff.png
└── traces/
    └── test-3.2-trace.zip           # Playwright trace files
```

---

## Success Criteria

### Minimum Viable Test Suite (Phase 6.1A Complete)
- ✅ At least 30 E2E tests passing
- ✅ Test pass rate ≥ 95%
- ✅ Test execution time < 5 minutes
- ✅ HTML report generation working
- ✅ Baseline screenshots captured for both themes
- ✅ Zero tests skipped due to infrastructure issues

### Quality Metrics
- **Flake Rate**: < 5% (tests that need retries)
- **Coverage**: 80%+ of critical user paths
- **Maintenance**: Tests update in < 10 minutes when UI changes

---

## Invocation Examples

### Example 1: Run All Tests
```
User: "Run all Playwright tests for Phase 6.1"

Agent Response:
"I'll run the complete Phase 6.1 E2E test suite via Playwright MCP server."

[Executes all 33 tests]
[Generates HTML report]
[Reports results with summary]
```

### Example 2: Visual Regression Only
```
User: "Check if the theme changes broke anything visually"

Agent Response:
"I'll run the visual regression test suite to compare against baselines."

[Executes Test Suite 4: Visual Regression (6 tests)]
[Shows diff images if failures found]
```

### Example 3: Update Baselines
```
User: "Update baseline screenshots for the new design"

Agent Response:
"I'll capture new baseline screenshots for all screens in both themes."

[Captures new baselines]
[Saves to screenshots/baseline/]
[Confirms completion]
```

---

## Integration with Development Workflow

### Before Committing UI Changes
1. Make UI changes in code
2. Invoke playwright-ui-tester agent
3. Review test results
4. Fix any failures
5. Commit with confidence

### During Code Review
1. Push UI changes to feature branch
2. Run Playwright tests
3. Attach HTML report to PR
4. Reviewers can see visual diffs

### Pre-Deployment
1. Merge to main branch
2. Run full test suite
3. Verify 100% pass rate
4. Deploy with confidence

---

## Limitations & Constraints

### Current Limitations
- **Chrome Only**: Firefox/Safari testing not yet configured
- **Desktop Only**: Mobile viewport testing is future work
- **No Performance Budgets**: Performance tracking is observational only
- **Manual Baseline Updates**: Requires manual invocation to update baselines

### Known Issues
- **OAuth Not Testable**: Google/Apple Sign In requires real credentials (mocking not implemented)
- **Real Database Required**: Tests use actual Supabase, not mocks
- **No Parallelization**: Tests run sequentially to avoid database conflicts

---

## Future Enhancements

### Post-MVP Features
1. **CI/CD Integration**: Run tests automatically on PR creation
2. **Slack Notifications**: Alert team when tests fail
3. **Performance Budgets**: Fail tests if page load > 3 seconds
4. **Accessibility Scoring**: Automated WCAG 2.1 AA audits
5. **Mobile Testing**: iOS Safari and Android Chrome
6. **Video Recording**: Record test execution for debugging

---

## Expected Agent Behavior

When invoked, the agent will:

1. **Acknowledge Request**
   ```
   "I'll run Phase 6.1 Playwright tests via MCP server.
    Verifying prerequisites..."
   ```

2. **Run Pre-Flight Checks**
   ```
   ✅ MCP Playwright server: Connected
   ✅ Flutter web app: Running on http://localhost:53241
   ✅ Supabase: Running (http://127.0.0.1:54321)
   ✅ Test database: Clean state
   ```

3. **Execute Tests with Progress Updates**
   ```
   Running Test Suite 1: Sign Up Flow... ✅ 10/10 passing
   Running Test Suite 2: Sign In Flow... ✅ 5/5 passing
   Running Test Suite 3: Session Persistence... ❌ 2/3 passing
   ...
   ```

4. **Report Results**
   ```
   📊 Test Results:
   - Total: 33 tests
   - Passed: 32 (96.97%)
   - Failed: 1 (3.03%)
   - Flaky: 0

   ❌ Failed Tests:
   - Test 3.2: New browser tab maintains session
     Location: app/test/e2e/tests/session_persistence.spec.ts:42
     Error: Expected session to persist, but user was logged out
     Screenshot: app/test/e2e/screenshots/failures/test-3.2.png

   📄 Full Report: app/test/e2e/reports/latest.html
   ```

5. **Provide Recommendations**
   ```
   💡 Recommendations:
   - Fix Test 3.2: Check if session tokens are properly stored in localStorage
   - Consider: All other tests passing - safe to proceed with caution
   ```

---

## Agent Metadata

- **Author**: Phase 6.1A Implementation
- **Created**: 2025-11-14
- **Test Coverage**: 33 tests (Phase 6.1 complete)
- **Estimated Execution Time**: 3-5 minutes (full suite)
- **Dependencies**:
  - Playwright MCP Server (Docker gateway)
  - Flutter web app running
  - Supabase running
  - Clean test database

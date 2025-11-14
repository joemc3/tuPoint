# Phase 6.1A: Playwright UI Testing Agent

**Status**: 📋 Planned
**Created**: 2025-11-14
**Purpose**: Automate comprehensive UI testing using Playwright via MCP server integration

---

## Overview

Phase 6.1A introduces an automated UI testing system powered by Playwright, integrated through the Model Context Protocol (MCP) server. This agent will run extensive UI tests after any changes that affect the user interface, providing rapid feedback on visual regressions, functionality breakage, and user flow disruptions.

---

## Goals

### Primary Objectives

1. **Automated UI Testing** - Run comprehensive UI tests without manual intervention
2. **Regression Detection** - Catch visual and functional regressions before they reach production
3. **Fast Feedback Loop** - Provide test results within minutes of UI changes
4. **Cross-Browser Testing** - Verify functionality across Chrome, Firefox, and Safari
5. **Screenshot Comparison** - Detect visual regressions through pixel-perfect comparisons
6. **E2E Flow Validation** - Test complete user journeys from sign-up to point creation

### Secondary Objectives

1. **Test Report Generation** - Produce detailed HTML reports with screenshots and traces
2. **Flaky Test Detection** - Identify and flag unreliable tests
3. **Performance Metrics** - Track page load times and interaction responsiveness
4. **Accessibility Auditing** - Run automated accessibility checks (WCAG 2.1 AA compliance)

---

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code Agent                        │
│                  (playwright-ui-tester)                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Invokes via Task tool
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   MCP Gateway (Docker)                       │
│              Playwright MCP Server Running                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Browser automation
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                 Flutter Web App (Chrome)                     │
│                 http://localhost:<port>                      │
└─────────────────────────────────────────────────────────────┘
```

### Agent Responsibilities

The `playwright-ui-tester` agent will:

1. **Test Discovery** - Identify UI test scenarios from specification documents
2. **Test Execution** - Run Playwright tests via MCP server
3. **Result Analysis** - Parse test results and identify failures
4. **Screenshot Comparison** - Detect visual regressions
5. **Report Generation** - Create comprehensive test reports
6. **Failure Diagnosis** - Provide actionable feedback on test failures

---

## Test Scenarios

### Phase 6.1: Authentication Flow Tests

#### Test Suite 1: Sign Up Flow
- ✅ **Test 1.1**: New user can create account with email/password
- ✅ **Test 1.2**: Weak password shows validation error
- ✅ **Test 1.3**: Invalid email shows validation error
- ✅ **Test 1.4**: Sign up button shows loading spinner during submission
- ✅ **Test 1.5**: After sign-up, user is routed to Profile Creation screen
- ✅ **Test 1.6**: Profile Creation screen has correct fields (username, bio)
- ✅ **Test 1.7**: Username validation works (3-20 chars, alphanumeric + underscore)
- ✅ **Test 1.8**: Duplicate username shows error without navigating away
- ✅ **Test 1.9**: After profile creation, user is routed to Main Feed
- ✅ **Test 1.10**: Main Feed displays correctly with test points

#### Test Suite 2: Sign In Flow
- ✅ **Test 2.1**: Existing user can sign in with correct credentials
- ✅ **Test 2.2**: Wrong password shows error message
- ✅ **Test 2.3**: Non-existent account shows error message
- ✅ **Test 2.4**: Sign in button shows loading spinner
- ✅ **Test 2.5**: After sign in, user goes directly to Main Feed (no profile screen)

#### Test Suite 3: Session Persistence
- ✅ **Test 3.1**: Page refresh maintains authenticated session
- ✅ **Test 3.2**: New browser tab maintains session
- ✅ **Test 3.3**: Unauthenticated user sees login screen after refresh

#### Test Suite 4: Visual Regression
- ✅ **Test 4.1**: Login screen matches baseline screenshot (light mode)
- ✅ **Test 4.2**: Login screen matches baseline screenshot (dark mode)
- ✅ **Test 4.3**: Profile creation screen matches baseline (light mode)
- ✅ **Test 4.4**: Profile creation screen matches baseline (dark mode)
- ✅ **Test 4.5**: Main feed screen matches baseline (light mode)
- ✅ **Test 4.6**: Main feed screen matches baseline (dark mode)

#### Test Suite 5: Theme Compliance
- ✅ **Test 5.1**: Blue gradient background present on login screen
- ✅ **Test 5.2**: Point cards have blue borders (3dp light, 2dp dark)
- ✅ **Test 5.3**: FAB has blue glow effect
- ✅ **Test 5.4**: Tagline displays "what's your point?" correctly
- ✅ **Test 5.5**: No hardcoded colors detected in rendered HTML

#### Test Suite 6: Error Handling
- ✅ **Test 6.1**: Network error shows appropriate message
- ✅ **Test 6.2**: Snackbar appears at bottom of screen
- ✅ **Test 6.3**: Snackbar auto-dismisses after ~4 seconds
- ✅ **Test 6.4**: Error snackbar has red background

---

## Implementation Plan

### Step 1: Agent Definition (.claude/agents/)

Create `playwright-ui-tester.md` agent specification:

```markdown
# Playwright UI Testing Agent

Use this agent to run automated UI tests using Playwright via the MCP server.

## When to Use

- After making changes to UI screens
- After updating theme or styling
- After modifying authentication flows
- Before merging UI-related pull requests
- When validating user flows end-to-end

## Capabilities

- Execute Playwright tests via MCP server
- Take screenshots for visual regression testing
- Generate HTML test reports with traces
- Run accessibility audits
- Test across multiple browsers (Chrome, Firefox, Safari)
- Validate form interactions and error states
- Check loading states and transitions

## Test Execution

The agent will:
1. Start Flutter web app on localhost
2. Connect to Playwright MCP server
3. Execute test scenarios defined in test suite
4. Capture screenshots and traces
5. Generate comprehensive test report
6. Report pass/fail status with details

## Output

- Test results (pass/fail counts)
- Screenshots of failures
- Trace files for debugging
- HTML report with detailed results
- Visual regression comparison (if baseline exists)
```

### Step 2: MCP Server Configuration

**Prerequisites** (User Setup):
```bash
# User must have Playwright MCP server running in Docker MCP gateway
# Configuration should be added to MCP gateway config
```

**MCP Server Capabilities Needed**:
- `playwright.navigate(url)` - Navigate to URL
- `playwright.click(selector)` - Click element
- `playwright.fill(selector, text)` - Fill input field
- `playwright.screenshot(path)` - Capture screenshot
- `playwright.waitForSelector(selector)` - Wait for element
- `playwright.evaluate(script)` - Run JavaScript
- `playwright.runTest(testFile)` - Execute Playwright test file

### Step 3: Test File Generation

Agent will generate Playwright test files in `app/test/e2e/`:

```
app/test/e2e/
├── auth_flow.spec.ts           # Sign up, sign in, session tests
├── profile_creation.spec.ts    # Profile creation flow tests
├── visual_regression.spec.ts   # Screenshot comparison tests
├── theme_compliance.spec.ts    # Theme validation tests
├── error_handling.spec.ts      # Error state tests
└── playwright.config.ts        # Playwright configuration
```

### Step 4: Baseline Screenshot Generation

On first run, agent will:
1. Capture baseline screenshots for all screens
2. Store in `app/test/e2e/screenshots/baseline/`
3. Use for future visual regression comparisons

### Step 5: CI Integration (Future)

Test execution flow:
```yaml
# .github/workflows/ui-tests.yml (future)
name: UI Tests

on: [pull_request]

jobs:
  playwright-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Flutter
      - name: Start Supabase
      - name: Build Flutter Web
      - name: Run Playwright Tests
        run: npx playwright test
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v3
```

---

## Test Execution Workflow

### Manual Invocation (MVP)

```bash
# User invokes agent via Claude Code
# Agent flow:
```

1. **Agent Initialization**
   - Read test scenarios from this specification
   - Check if Flutter web app is running
   - If not, prompt user to start: `flutter run -d chrome`

2. **Test Execution**
   - Connect to Playwright MCP server
   - Execute test suites sequentially
   - Capture results, screenshots, traces

3. **Result Analysis**
   - Parse test results
   - Compare screenshots against baseline (if exists)
   - Identify failures and flaky tests
   - Calculate pass rate

4. **Report Generation**
   - Create HTML report with:
     - Test suite summary (X/Y passing)
     - Failed test details with screenshots
     - Trace files for debugging
     - Visual diff images (for regression tests)
     - Performance metrics (page load times)
   - Save report to `app/test/e2e/reports/latest.html`

5. **Feedback to User**
   - Display summary in Claude Code chat
   - Link to full HTML report
   - Highlight critical failures
   - Suggest fixes for common issues

---

## Expected Deliverables

### Phase 6.1A Completion Criteria

- ✅ Playwright UI testing agent created (`.claude/agents/playwright-ui-tester.md`)
- ✅ Test files generated in `app/test/e2e/`
- ✅ Baseline screenshots captured for Phase 6.1 screens
- ✅ At least 30 E2E tests passing (covering all Test Suites 1-6)
- ✅ HTML report generation working
- ✅ Visual regression detection functional
- ✅ Documentation for running tests manually
- ✅ Integration with MCP Playwright server verified

### Test Coverage Goals

- **Minimum**: 30 E2E tests (Phase 6.1 authentication flow)
- **Target**: 50+ E2E tests (Phase 6.1 + error states)
- **Future**: 100+ E2E tests (Phase 6.2-6.4 main feed, point creation, likes)

---

## Benefits

### Development Velocity

1. **Faster Iteration** - Catch regressions immediately, not during manual testing
2. **Confident Refactoring** - Change code knowing tests will catch breaks
3. **Reduced Manual Testing** - Automate repetitive test scenarios
4. **Better Code Reviews** - Test results available in PR reviews

### Quality Assurance

1. **Visual Consistency** - Screenshot comparison catches unintended style changes
2. **User Flow Validation** - E2E tests ensure complete user journeys work
3. **Cross-Browser Compatibility** - Test on Chrome, Firefox, Safari automatically
4. **Accessibility Compliance** - Automated WCAG 2.1 AA checks

### Documentation

1. **Living Documentation** - Tests serve as executable specifications
2. **Onboarding Tool** - New developers can understand flows from tests
3. **Regression Prevention** - Tests document expected behavior

---

## Risks & Mitigation

### Risk 1: Flaky Tests

**Problem**: Tests fail intermittently due to timing issues, animations, or network conditions

**Mitigation**:
- Use explicit waits instead of sleep()
- Set reasonable timeouts (30s for page loads)
- Retry flaky tests automatically (up to 3 times)
- Flag tests with >10% failure rate as flaky
- Use Playwright's built-in retry mechanism

### Risk 2: MCP Server Availability

**Problem**: Playwright MCP server might not be running or accessible

**Mitigation**:
- Check MCP server status before test execution
- Provide clear error message if server is unavailable
- Document MCP server setup requirements
- Fallback to manual testing instructions

### Risk 3: Test Maintenance Burden

**Problem**: UI changes require updating many tests

**Mitigation**:
- Use Page Object Model pattern for reusable selectors
- Define test data in separate fixtures
- Use data-testid attributes for stable selectors
- Group related tests into suites for easier updates

### Risk 4: Long Test Execution Time

**Problem**: Running all tests takes too long for rapid feedback

**Mitigation**:
- Run critical tests first (smoke tests)
- Parallelize test execution across multiple browsers
- Use test tagging to run subsets (e.g., @auth-only)
- Cache baseline screenshots to speed up comparisons

---

## Future Enhancements (Post-MVP)

### Phase 6.2+: Additional Test Coverage

- **Main Feed Tests**: Point rendering, like/unlike interactions, distance calculations
- **Point Creation Tests**: GPS capture, Maidenhead display, content validation
- **Location Permission Tests**: Permission request flows, error states
- **Real-Time Update Tests**: Supabase Realtime integration validation

### Advanced Features

1. **Performance Monitoring**
   - Track Core Web Vitals (LCP, FID, CLS)
   - Alert on performance regressions
   - Generate performance trend reports

2. **Accessibility Scoring**
   - Full WCAG 2.1 AAA audit
   - Color contrast validation
   - Keyboard navigation testing
   - Screen reader compatibility

3. **Mobile Device Testing**
   - Test on iOS Safari (Playwright mobile emulation)
   - Test on Android Chrome
   - Validate responsive layouts
   - Test touch interactions

4. **Video Recording**
   - Record test execution videos
   - Attach to failed test reports
   - Useful for debugging flaky tests

5. **Network Condition Testing**
   - Test under slow 3G conditions
   - Test offline behavior
   - Test with high latency

---

## Success Metrics

### Quantitative Metrics

- **Test Pass Rate**: Target 95%+ passing
- **Test Execution Time**: Target <5 minutes for full suite
- **Code Coverage**: Target 80%+ UI code coverage
- **Flake Rate**: Target <5% flaky tests

### Qualitative Metrics

- **Developer Confidence**: Team feels confident making UI changes
- **Bug Detection**: Tests catch bugs before manual QA
- **Documentation Value**: Tests serve as clear user flow documentation
- **Maintenance Burden**: Tests are easy to update when UI changes

---

## Next Steps

1. **User Setup** (Manual)
   - Configure Playwright MCP server in Docker MCP gateway
   - Verify MCP server is accessible from Claude Code
   - Start Flutter web app on localhost

2. **Agent Implementation** (Phase 6.1A)
   - Create playwright-ui-tester agent
   - Generate initial test files
   - Capture baseline screenshots
   - Run first test suite
   - Generate first HTML report

3. **Iteration** (Ongoing)
   - Add more test scenarios as UI evolves
   - Update baselines when intentional design changes occur
   - Improve test reliability and execution speed
   - Expand to Phase 6.2+ test coverage

---

## Conclusion

Phase 6.1A establishes a robust automated UI testing foundation that will accelerate development velocity, improve code quality, and provide confidence when making UI changes. By leveraging Playwright via MCP server integration, we create a maintainable and scalable testing system that grows with the application.

**Estimated Effort**: 4-6 hours
**Priority**: High (prevents regressions during Phase 6.2-6.4)
**Blockers**: MCP Playwright server must be configured and running

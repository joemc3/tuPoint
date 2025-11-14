# Security Remediation Plan
**Project**: tuPoint
**Date**: 2025-11-13
**Status**: DRAFT - Awaiting Approval

## Overview

This document provides a prioritized, actionable plan to address all security findings from the comprehensive security audit. Each item includes specific implementation steps, estimated effort, and acceptance criteria.

---

## Priority 1: CRITICAL - Immediate Action Required

### 1.1 Remove Hardcoded Anon Key

**Issue**: Supabase anon key hardcoded in `app/lib/core/config/env_config.dart`

**Timeline**: Immediate (before any further commits)
**Effort**: 30 minutes
**Owner**: Backend/Security Team

**Implementation Steps**:

1. **Update `env_config.dart`**:
```dart
// BEFORE:
static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH', // ❌ Remove this
);

// AFTER:
static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '', // Empty default - forces explicit configuration
);
```

2. **Add validation in `main.dart`**:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration
  if (!EnvConfig.isValid) {
    throw Exception(
      'Missing required environment variables. '
      'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
    );
  }

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    debug: kDebugMode, // Use Flutter's debug flag
  );

  runApp(const ProviderScope(child: TuPointApp()));
}
```

3. **Update documentation**:
   - Add setup instructions to README.md
   - Document required environment variables
   - Provide example .env file

4. **Verify**:
   - Run `flutter run` without env vars (should fail with clear error)
   - Run with proper env vars (should succeed)
   - Check that no keys are in git history

**Acceptance Criteria**:
- ✅ No hardcoded keys in source code
- ✅ App fails gracefully with clear error if keys missing
- ✅ Documentation updated
- ✅ Git history clean (use `git-secrets` tool to verify)

**Notes**:
- If the existing key was ever used in production, rotate it immediately via Supabase dashboard
- Consider using git-secrets or similar tool to prevent future accidental commits

---

## Priority 2: HIGH - Within 48 Hours

### 2.1 Fix Debug Mode Configuration

**Issue**: Debug logging enabled in production builds

**Timeline**: 48 hours
**Effort**: 1 hour
**Owner**: Flutter Development Team

**Implementation Steps**:

1. **Update `main.dart`**:
```dart
import 'package:flutter/foundation.dart'; // Add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    debug: kDebugMode, // ✅ Use Flutter's debug flag
  );

  runApp(const ProviderScope(child: TuPointApp()));
}
```

2. **Verify build configurations**:
```bash
# Debug build should have debug=true
flutter run --debug

# Release build should have debug=false
flutter run --release

# Profile build should have debug=false
flutter run --profile
```

3. **Test logging levels**:
   - Verify no sensitive data logged in release builds
   - Confirm auth tokens not exposed
   - Check database queries not printed

**Acceptance Criteria**:
- ✅ Debug logging only in debug builds
- ✅ No sensitive data in production logs
- ✅ Build variants tested

---

### 2.2 Add Android Network Security Configuration

**Issue**: No network security config to enforce HTTPS

**Timeline**: 48 hours
**Effort**: 2 hours
**Owner**: Android Development Team

**Implementation Steps**:

1. **Create `app/android/app/src/main/res/xml/network_security_config.xml`**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Production configuration: Only HTTPS allowed -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>

    <!-- Allow localhost for development only -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">127.0.0.1</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain> <!-- Android emulator -->
    </domain-config>

    <!-- Pin Supabase certificates (optional but recommended) -->
    <!-- Uncomment and configure for production:
    <domain-config>
        <domain includeSubdomains="true">your-project.supabase.co</domain>
        <pin-set expiration="2026-01-01">
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
    </domain-config>
    -->
</network-security-config>
```

2. **Update `app/android/app/src/main/AndroidManifest.xml`**:
```xml
<application
    android:label="tuPoint"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:networkSecurityConfig="@xml/network_security_config"> <!-- Add this line -->
```

3. **Create the xml directory if it doesn't exist**:
```bash
mkdir -p app/android/app/src/main/res/xml
```

4. **Test**:
   - Build release APK and verify HTTPS enforcement
   - Test localhost connections work in debug builds
   - Verify production HTTPS-only

**Acceptance Criteria**:
- ✅ HTTPS enforced in production builds
- ✅ Local development still works
- ✅ No cleartext HTTP traffic in release builds
- ✅ Certificate pinning documented for future

**References**:
- [Android Network Security Config](https://developer.android.com/training/articles/security-config)
- [Certificate Pinning Guide](https://developer.android.com/training/articles/security-ssl)

---

### 2.3 Strengthen Password Requirements

**Issue**: Weak password policy (6 char minimum, no complexity)

**Timeline**: 48 hours
**Effort**: 1 hour
**Owner**: Backend/Security Team

**Implementation Steps**:

1. **Update `supabase/config.toml`**:
```toml
# BEFORE:
minimum_password_length = 6
password_requirements = ""

# AFTER:
minimum_password_length = 8
password_requirements = "lower_upper_letters_digits"
```

2. **Apply changes**:
```bash
# Stop Supabase if running
supabase stop

# Apply configuration
supabase start

# Or reset to apply new config
supabase db reset
```

3. **Update client-side validation** (optional but recommended):
   - Add password strength indicator in UI
   - Provide real-time feedback on password requirements
   - Show clear error messages

4. **Notify existing users** (if applicable):
   - Send notification about updated password policy
   - Force password reset for weak passwords (optional)

**Acceptance Criteria**:
- ✅ Minimum 8 characters enforced
- ✅ Requires uppercase, lowercase, and digits
- ✅ Existing users can still log in (grandfather clause)
- ✅ New signups follow new policy

---

### 2.4 Make OAuth Nonce Check Environment-Dependent

**Issue**: Google OAuth nonce check disabled for all environments

**Timeline**: 48 hours
**Effort**: 1 hour
**Owner**: Backend/Security Team

**Implementation Steps**:

1. **Update `supabase/config.toml`**:
```toml
[auth.external.google]
enabled = true
client_id = "env(GOOGLE_OAUTH_CLIENT_ID)"
secret = "env(GOOGLE_OAUTH_SECRET)"
skip_nonce_check = false  # ✅ Enable for production
# Note: For local development with Google OAuth, you may need to set this to true
# in a separate config file or use environment-specific configuration
```

2. **Create environment-specific configuration** (recommended approach):

Create `supabase/config.local.toml` for local development:
```toml
[auth.external.google]
skip_nonce_check = true  # Only for local development
```

Add to `.gitignore`:
```
supabase/config.local.toml
```

3. **Update documentation**:
   - Document why nonce check is important
   - Explain local development setup
   - Provide troubleshooting for OAuth issues

4. **Test OAuth flows**:
   - Test Google sign-in in local development
   - Test in production/staging with nonce check enabled
   - Verify replay attack protection works

**Acceptance Criteria**:
- ✅ Nonce check enabled in production
- ✅ Local development still functional
- ✅ OAuth security improved
- ✅ Documentation updated

---

## Priority 3: MEDIUM - Within 1 Week

### 3.1 Implement Input Sanitization

**Issue**: No explicit sanitization for user-generated content

**Timeline**: 1 week
**Effort**: 4 hours
**Owner**: Application Development Team

**Implementation Steps**:

1. **Create sanitization utility** (`app/lib/core/utils/input_sanitizer.dart`):
```dart
class InputSanitizer {
  /// Sanitize username: remove dangerous characters, normalize Unicode
  static String sanitizeUsername(String username) {
    // Normalize Unicode (prevent homograph attacks)
    final normalized = username.trim().toLowerCase();

    // Remove any non-ASCII characters to prevent homograph attacks
    final asciiOnly = normalized.replaceAll(RegExp(r'[^\x00-\x7F]'), '');

    // Remove any control characters
    final cleaned = asciiOnly.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    return cleaned;
  }

  /// Sanitize text content: normalize Unicode, remove dangerous characters
  static String sanitizeText(String text) {
    // Normalize Unicode
    String sanitized = text.trim();

    // Remove control characters except newline and tab
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'), '');

    // Remove RTL override characters (prevent text direction attacks)
    sanitized = sanitized.replaceAll(RegExp(r'[\u202A-\u202E\u2066-\u2069]'), '');

    // Remove zero-width characters (prevent invisible text)
    sanitized = sanitized.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

    return sanitized;
  }

  /// Validate and sanitize Maidenhead locator
  static String sanitizeMaidenhead(String locator) {
    return locator.trim().toUpperCase();
  }
}
```

2. **Update use cases to use sanitization**:

In `create_profile_use_case.dart`:
```dart
return _profileRepository.createProfile(
  id: request.userId,
  username: InputSanitizer.sanitizeUsername(request.username),
  bio: request.bio != null ? InputSanitizer.sanitizeText(request.bio!) : null,
);
```

In `drop_point_use_case.dart`:
```dart
return _pointsRepository.createPoint(
  userId: request.userId,
  content: InputSanitizer.sanitizeText(request.content),
  location: request.location,
  maidenhead6char: InputSanitizer.sanitizeMaidenhead(request.maidenhead6char),
);
```

3. **Add tests** (`app/test/core/utils/input_sanitizer_test.dart`):
```dart
void main() {
  group('InputSanitizer.sanitizeUsername', () {
    test('removes Unicode characters', () {
      expect(InputSanitizer.sanitizeUsername('user™'), 'user');
    });

    test('prevents homograph attacks', () {
      expect(InputSanitizer.sanitizeUsername('аdmin'), 'admin'); // Cyrillic 'а'
    });

    test('removes control characters', () {
      expect(InputSanitizer.sanitizeUsername('user\x00name'), 'username');
    });
  });

  group('InputSanitizer.sanitizeText', () {
    test('removes RTL override', () {
      expect(InputSanitizer.sanitizeText('text\u202Eoverride'), 'textoverride');
    });

    test('removes zero-width characters', () {
      expect(InputSanitizer.sanitizeText('text\u200Bhidden'), 'texthidden');
    });
  });
}
```

**Acceptance Criteria**:
- ✅ All user inputs sanitized
- ✅ Homograph attacks prevented
- ✅ RTL override attacks prevented
- ✅ Test coverage for sanitization
- ✅ No breaking changes to existing functionality

---

### 3.2 Adjust Rate Limiting

**Issue**: Some rate limits may be too permissive

**Timeline**: 1 week
**Effort**: 2 hours
**Owner**: Backend/Security Team

**Implementation Steps**:

1. **Review and update `supabase/config.toml`**:
```toml
[auth.rate_limit]
# Reduce from 30 to 10 sign-ups per 5 minutes per IP
sign_in_sign_ups = 10

# Reduce token refresh from 150 to 60 per 5 minutes per IP
token_refresh = 60

# Keep other limits as-is (they're reasonable)
email_sent = 2
sms_sent = 30
anonymous_users = 30
token_verifications = 30
web3 = 30
```

2. **Monitor after deployment**:
   - Track legitimate users hitting limits
   - Adjust if causing UX issues
   - Log rate limit violations for analysis

3. **Add application-level rate limiting** (optional):
   - Implement exponential backoff for failed attempts
   - Add client-side throttling
   - Show user-friendly messages when rate limited

**Acceptance Criteria**:
- ✅ Rate limits reduced to reasonable levels
- ✅ No impact on legitimate users
- ✅ Monitoring in place
- ✅ Documentation updated

---

### 3.3 Configure Production Environment Variables

**Issue**: Ensure production uses secure configuration

**Timeline**: 1 week
**Effort**: 3 hours
**Owner**: DevOps/Backend Team

**Implementation Steps**:

1. **Create production environment checklist**:
   - [ ] `enable_confirmations = true` for email
   - [ ] `minimum_password_length = 8`
   - [ ] `skip_nonce_check = false` for OAuth
   - [ ] `debug = false` in Flutter app
   - [ ] Custom JWT signing keys configured
   - [ ] HTTPS URLs only
   - [ ] Proper CORS configuration

2. **Document environment-specific configs**:
   - Create `supabase/config.production.toml`
   - Document required environment variables
   - Provide deployment checklist

3. **Set up CI/CD security checks**:
   - Validate no debug mode in release builds
   - Check for hardcoded secrets
   - Verify HTTPS endpoints
   - Run security linters

**Acceptance Criteria**:
- ✅ Production configuration documented
- ✅ CI/CD checks in place
- ✅ Deployment checklist created
- ✅ Team trained on secure deployment

---

## Priority 4: LOW - Within 2 Weeks

### 4.1 Implement Certificate Pinning (Optional)

**Timeline**: 2 weeks
**Effort**: 6 hours
**Owner**: Mobile Development Team

**Implementation Steps**:

1. **Get Supabase SSL certificate**:
```bash
# Get certificate chain
openssl s_client -servername your-project.supabase.co \
  -connect your-project.supabase.co:443 < /dev/null | \
  openssl x509 -outform DER -out supabase.der

# Get SHA-256 hash
openssl x509 -inform DER -in supabase.der -pubkey -noout | \
  openssl pkey -pubin -outform DER | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64
```

2. **Update network_security_config.xml**:
```xml
<domain-config>
    <domain includeSubdomains="true">your-project.supabase.co</domain>
    <pin-set expiration="2026-01-01">
        <pin digest="SHA-256">HASH_FROM_STEP_1</pin>
        <pin digest="SHA-256">BACKUP_HASH</pin> <!-- Backup pin -->
    </pin-set>
</domain-config>
```

3. **Implement iOS pinning** (if needed):
   - Use TrustKit or similar library
   - Configure in Info.plist
   - Test certificate validation

4. **Set up monitoring**:
   - Alert on certificate pinning failures
   - Monitor for certificate expiration
   - Plan for certificate rotation

**Acceptance Criteria**:
- ✅ Certificate pinning implemented
- ✅ Backup pins configured
- ✅ Expiration monitoring in place
- ✅ Documentation for certificate rotation

---

### 4.2 Add Security Headers (Web Deployment)

**Timeline**: 2 weeks
**Effort**: 2 hours
**Owner**: Web Development Team

**Implementation Steps** (if deploying to web):

1. **Configure CSP header**:
```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  connect-src 'self' https://your-project.supabase.co;
  font-src 'self' data:;
```

2. **Add other security headers**:
```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(self)
```

3. **Test in staging**:
   - Verify app functionality not broken
   - Check CSP violations in console
   - Adjust as needed

**Acceptance Criteria**:
- ✅ Security headers configured
- ✅ CSP violations monitored
- ✅ No functionality broken

---

### 4.3 Set Up Security Monitoring

**Timeline**: 2 weeks
**Effort**: 8 hours
**Owner**: DevOps/Security Team

**Implementation Steps**:

1. **Configure Supabase monitoring**:
   - Enable Supabase dashboard alerts
   - Monitor failed authentication attempts
   - Track unusual query patterns
   - Alert on rate limit violations

2. **Set up application monitoring**:
   - Integrate Sentry or similar for error tracking
   - Monitor authentication flows
   - Track user signup patterns
   - Alert on suspicious activity

3. **Create security dashboard**:
   - Failed login attempts
   - Rate limit hits
   - Unusual access patterns
   - Database query performance

4. **Define incident response procedures**:
   - Document escalation path
   - Create runbooks for common incidents
   - Set up on-call rotation (if applicable)

**Acceptance Criteria**:
- ✅ Monitoring tools configured
- ✅ Alerts set up and tested
- ✅ Incident response procedures documented
- ✅ Team trained on security monitoring

---

## Pre-Production Deployment Checklist

Before deploying to production, verify:

### Critical
- [ ] No hardcoded secrets in code
- [ ] Debug mode disabled in production builds
- [ ] Environment variables properly configured
- [ ] Email confirmations enabled
- [ ] Password requirements strengthened (8+ chars, complexity)
- [ ] HTTPS enforced on all platforms

### High Priority
- [ ] Network security config added (Android)
- [ ] OAuth nonce check enabled (production)
- [ ] Rate limiting configured and tested
- [ ] Input sanitization implemented
- [ ] All security tests passing

### Medium Priority
- [ ] Certificate pinning considered/implemented
- [ ] Security headers configured (web)
- [ ] Monitoring and alerting set up
- [ ] Incident response plan documented
- [ ] Security audit findings addressed

### Documentation
- [ ] Security documentation updated
- [ ] Deployment procedures documented
- [ ] Incident response runbook created
- [ ] Team trained on security practices

---

## Testing Plan

### Security Testing

1. **Manual Penetration Testing**:
   - Test authentication bypass attempts
   - Try SQL injection on all inputs
   - Attempt privilege escalation
   - Test rate limiting effectiveness

2. **Automated Security Scanning**:
   - Run SAST (Static Application Security Testing)
   - Run DAST (Dynamic Application Security Testing)
   - Dependency vulnerability scanning
   - Secret scanning in git history

3. **Code Review**:
   - Security-focused code review
   - RLS policy verification
   - Input validation review
   - Authentication flow review

### Regression Testing

After implementing fixes:
- [ ] All existing tests still pass
- [ ] Authentication flows work correctly
- [ ] OAuth providers functional
- [ ] Rate limiting doesn't affect legitimate users
- [ ] Input sanitization doesn't break functionality

---

## Timeline Summary

| Priority | Task | Effort | Deadline |
|----------|------|--------|----------|
| Critical | Remove hardcoded keys | 30 min | Immediate |
| High | Fix debug mode | 1 hour | 48 hours |
| High | Android network config | 2 hours | 48 hours |
| High | Password requirements | 1 hour | 48 hours |
| High | OAuth nonce check | 1 hour | 48 hours |
| Medium | Input sanitization | 4 hours | 1 week |
| Medium | Rate limiting | 2 hours | 1 week |
| Medium | Production env config | 3 hours | 1 week |
| Low | Certificate pinning | 6 hours | 2 weeks |
| Low | Security headers | 2 hours | 2 weeks |
| Low | Monitoring | 8 hours | 2 weeks |

**Total Estimated Effort**: ~30 hours over 2 weeks

---

## Success Metrics

Track these metrics to measure security improvement:

1. **Security Posture**:
   - Zero hardcoded secrets in repository
   - 100% HTTPS enforcement
   - Strong password policy compliance rate

2. **Incident Metrics**:
   - Time to detect security issues
   - Time to remediate vulnerabilities
   - Number of security incidents

3. **Compliance**:
   - OWASP Top 10 coverage
   - Security audit findings closed
   - Security testing pass rate

---

## Sign-Off

This remediation plan requires approval from:

- [ ] **Security Team Lead**: _________________ Date: _______
- [ ] **Engineering Manager**: _________________ Date: _______
- [ ] **Product Owner**: _________________ Date: _______

Once approved, create individual tickets for each task and track progress in your project management system.

---

## Appendix: Quick Reference Commands

### Check for Hardcoded Secrets
```bash
# Use git-secrets to scan repository
git secrets --scan

# Or use grep
grep -r "sk-\|AIza\|AKIA\|ghp_\|gho_" app/lib/
```

### Verify Debug Mode
```bash
# Check main.dart
grep -n "debug:" app/lib/main.dart

# Should use kDebugMode from Flutter framework
```

### Test Network Security
```bash
# Build release APK
flutter build apk --release

# Install and test
adb install build/app/outputs/flutter-apk/app-release.apk

# Monitor network traffic
adb shell setprop log.tag.NetworkSecurityConfig DEBUG
```

### Verify Password Policy
```bash
# Connect to local Supabase
psql postgresql://postgres:postgres@localhost:54322/postgres

# Check auth config
SELECT * FROM auth.config;
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-13
**Next Review**: Before production deployment

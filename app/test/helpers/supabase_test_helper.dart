import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test helper for integration tests with local Supabase instance.
///
/// Provides utilities for:
/// - Initializing Supabase client for tests
/// - Creating test users with authentication
/// - Cleaning up test data after tests
/// - Database utilities
class SupabaseTestHelper {
  static const String supabaseUrl = 'http://127.0.0.1:54321';
  static const String supabaseAnonKey =
      'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

  static SupabaseClient? _client;
  static bool _initialized = false;

  /// Get or create the Supabase client for tests.
  static SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'SupabaseTestHelper not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  /// Initialize Supabase for integration tests.
  ///
  /// Call this in setUpAll() for test groups that need Supabase.
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize SharedPreferences with mock values for testing
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
    _initialized = true;
  }

  /// Clean up all test data from the database.
  ///
  /// Call this in tearDown() to ensure tests don't interfere with each other.
  /// IMPORTANT: Only use on test databases!
  ///
  /// Note: This uses service role key to bypass RLS for cleanup.
  /// For local dev, you can delete all test data regardless of RLS policies.
  static Future<void> cleanupTestData() async {
    try {
      // Delete in order to respect foreign key constraints:
      // 1. likes (references points)
      // 2. points (references profile)
      // 3. profile (references auth.users)
      //
      // Use gte to delete all records (workaround for RLS in test environment)
      // In production, never expose these operations!

      await client.from('likes').delete().gte('created_at', '2000-01-01');
      await client.from('points').delete().gte('created_at', '2000-01-01');
      await client.from('profile').delete().gte('created_at', '2000-01-01');
    } catch (e) {
      // Ignore cleanup errors - they may be due to RLS or missing data
      print('Warning: Cleanup encountered error (this may be normal): $e');
    }

    // Sign out any authenticated user
    await client.auth.signOut();
  }

  /// Create a test user with authentication.
  ///
  /// Returns the user ID that can be used in repository tests.
  /// The user will be automatically signed in.
  ///
  /// **Important**: Test email addresses must be confirmed automatically
  /// in local Supabase. Check config.toml for `enable_confirmations = false`.
  static Future<String> createAuthenticatedTestUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign up the user
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create test user: user is null');
      }

      final userId = authResponse.user!.id;

      // In local development, users should be auto-confirmed
      // If not, you may need to manually confirm them in the database

      return userId;
    } catch (e) {
      // If user already exists, try to sign in instead
      try {
        final signInResponse = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (signInResponse.user == null) {
          throw Exception('Failed to sign in test user: user is null');
        }

        return signInResponse.user!.id;
      } catch (signInError) {
        throw Exception('Failed to create or sign in test user: $e, $signInError');
      }
    }
  }

  /// Sign out the current test user.
  static Future<void> signOutTestUser() async {
    await client.auth.signOut();
  }

  /// Get the currently authenticated user ID, or null if not authenticated.
  static String? get currentUserId => client.auth.currentUser?.id;

  /// Check if a user is currently authenticated.
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Execute raw SQL for test setup.
  ///
  /// Only use this for test data setup, not for testing repository behavior.
  static Future<void> executeSql(String sql) async {
    await client.rpc('exec_sql', params: {'sql': sql});
  }
}

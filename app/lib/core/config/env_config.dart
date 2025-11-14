import 'package:flutter/foundation.dart';

/// Environment configuration for Supabase
///
/// Loads configuration from .env file for local development.
/// For production, these values should be loaded from secure environment
/// variables or a configuration service.
class EnvConfig {
  /// Supabase project URL
  /// Local Docker: http://127.0.0.1:54321
  /// Production: https://your-project.supabase.co
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  /// Supabase anonymous/publishable key
  /// This is safe to expose in client-side code as it only provides
  /// public access controlled by Row Level Security (RLS) policies
  ///
  /// SECURITY: In release mode, this MUST be provided via environment variables.
  /// The default local key is only available in debug builds.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: kReleaseMode
        ? '' // Force explicit configuration in production
        : 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH', // Local dev key
  );

  /// Validates that all required environment variables are set
  static bool get isValid {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  /// Checks if running against local Supabase instance
  static bool get isLocalDevelopment =>
      supabaseUrl.contains('127.0.0.1') || supabaseUrl.contains('localhost');

  /// Checks if this is a production build with proper configuration
  static bool get isProduction => kReleaseMode && !isLocalDevelopment;

  /// Returns the current environment name for logging/debugging
  static String get environmentName {
    if (isProduction) return 'production';
    if (isLocalDevelopment) return 'local';
    return 'development';
  }
}

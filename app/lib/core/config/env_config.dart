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
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
  );

  /// Validates that all required environment variables are set
  static bool get isValid {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}

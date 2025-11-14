import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_gate_screen.dart';

/// tuPoint - Hyper-Local, Ephemeral Social Media
///
/// Main entry point for the tuPoint Flutter application.
///
/// Architecture:
/// - Clean Architecture (Presentation → Domain → Data layers)
/// - Riverpod for state management
/// - Supabase for backend (Auth, Database, RLS)
///
/// Key Features:
/// - Material 3 design with Location Blue (#3A9BFC) theme
/// - Inter typography for modern, readable UI
/// - Three main screens: Authentication → Main Feed → Point Creation
/// - PostGIS-powered geospatial features
/// - Client-side 5km radius filtering
///
/// Theme specifications: /project_standards/project-theme.md
/// UX specifications: /project_standards/UX_user_flow.md
/// Architecture: /project_standards/architecture_and_state_management.md
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration
  if (!EnvConfig.isValid) {
    throw Exception(
      'Missing required environment variables. '
      'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
    );
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    debug: kDebugMode, // Enable debug logging only in debug builds
  );

  // Run app wrapped in ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: TuPointApp(),
    ),
  );
}

/// Root application widget
class TuPointApp extends StatelessWidget {
  const TuPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App metadata
      title: 'tuPoint',
      debugShowCheckedModeBanner: false,

      // Theme configuration using Location Blue seed color
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respects device preference

      // Initial route - Authentication Gate
      home: const AuthGateScreen(),
    );
  }
}

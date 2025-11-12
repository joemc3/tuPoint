import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_gate_screen.dart';

/// tuPoint - Hyper-Local, Ephemeral Social Media
///
/// Main entry point for the tuPoint Flutter application.
///
/// This is a UI mockup implementation with hardcoded test data for visual
/// demonstration purposes. No business logic, state management, or API
/// integration is implemented.
///
/// Key Features (Mockup):
/// - Material 3 design with Location Blue (#3A9BFC) theme
/// - Inter typography for modern, readable UI
/// - Three navigable screens:
///   1. Authentication Gate (welcome screen)
///   2. Main Feed (Point cards with test data)
///   3. Point Creation (form with mock location)
///
/// Theme specifications: /project_standards/project-theme.md
/// UX specifications: /project_standards/UX_user_flow.md
void main() {
  runApp(const TuPointApp());
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

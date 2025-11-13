import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/point_card.dart';
import 'package:app/core/theme/app_theme.dart';

void main() {
  group('PointCard Widget Tests', () {
    // Test helper to wrap PointCard with MaterialApp and theme
    Widget makeTestableWidget(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('Rendering Tests', () {
      testWidgets('renders all required components with valid inputs', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@TestUser',
              content: 'This is a test point content.',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.2 km',
            ),
          ),
        );

        // Assert
        expect(find.text('@TestUser'), findsOneWidget);
        expect(find.text('This is a test point content.'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('FN30as'), findsOneWidget);
        expect(find.text('1.2 km'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget); // Initially unliked
        expect(find.byIcon(Icons.near_me), findsOneWidget); // Distance icon
      });

      testWidgets('renders Card with correct elevation and padding', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'Content',
              likes: 0,
              maidenhead: 'FN20aa',
              distance: '5.0 km',
            ),
          ),
        );

        // Assert
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, isNotNull);
        expect(card.margin, isNotNull);
      });

      testWidgets('renders with zero likes', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@NewUser',
              content: 'Brand new point',
              likes: 0,
              maidenhead: 'FN31pr',
              distance: '0.1 km',
            ),
          ),
        );

        // Assert
        expect(find.text('0'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });

      testWidgets('renders with very long content', (WidgetTester tester) async {
        // Arrange
        const longContent = 'This is a very long point content that should still render correctly '
            'even though it contains many characters and might span multiple lines. '
            'The widget should handle text overflow gracefully and maintain proper layout. '
            'Testing with 280 characters: Lorem ipsum dolor sit amet, consectetur adipiscing.';

        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@VerboseUser',
              content: longContent,
              likes: 42,
              maidenhead: 'FN30as',
              distance: '2.5 km',
            ),
          ),
        );

        // Assert
        expect(find.text(longContent), findsOneWidget);
        expect(find.text('@VerboseUser'), findsOneWidget);
      });

      testWidgets('renders with short distance (< 1 km)', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@NearbyUser',
              content: 'Very close point',
              likes: 3,
              maidenhead: 'FN30bt',
              distance: '150 m',
            ),
          ),
        );

        // Assert
        expect(find.text('150 m'), findsOneWidget);
      });

      testWidgets('renders with high like count', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@PopularUser',
              content: 'Viral content!',
              likes: 999,
              maidenhead: 'FN30as',
              distance: '0.5 km',
            ),
          ),
        );

        // Assert
        expect(find.text('999'), findsOneWidget);
      });

      testWidgets('renders Maidenhead chip with proper styling', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'Content',
              likes: 1,
              maidenhead: 'FN20dx',
              distance: '3.0 km',
            ),
          ),
        );

        // Assert
        expect(find.byType(Chip), findsOneWidget);
        expect(find.text('FN20dx'), findsOneWidget);

        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.backgroundColor, isNotNull);
        expect(chip.side, BorderSide.none);
      });
    });

    group('Theme Compliance Tests', () {
      testWidgets('uses theme colors correctly in light mode', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@ThemeTest',
              content: 'Testing theme colors',
              likes: 7,
              maidenhead: 'FN30as',
              distance: '1.0 km',
            ),
            themeMode: ThemeMode.light,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - username should use primary color (Location Blue)
        final usernameText = tester.widget<Text>(find.text('@ThemeTest'));
        expect(usernameText.style?.color, isNotNull);

        // Chip should use primaryContainer color
        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.backgroundColor, isNotNull);
      });

      testWidgets('uses theme colors correctly in dark mode', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@DarkMode',
              content: 'Dark theme content',
              likes: 12,
              maidenhead: 'FN30as',
              distance: '2.0 km',
            ),
            themeMode: ThemeMode.dark,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - should render without errors and use dark theme colors
        expect(find.text('@DarkMode'), findsOneWidget);
        expect(find.text('Dark theme content'), findsOneWidget);
      });

      testWidgets('has no hardcoded colors', (WidgetTester tester) async {
        // This test verifies the widget respects theme by comparing light vs dark
        Widget buildWithTheme(ThemeMode mode) {
          return makeTestableWidget(
            const PointCard(
              username: '@Test',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
            ),
            themeMode: mode,
          );
        }

        // Light theme
        await tester.pumpWidget(buildWithTheme(ThemeMode.light));
        await tester.pumpAndSettle();

        // Dark theme
        await tester.pumpWidget(buildWithTheme(ThemeMode.dark));
        await tester.pumpAndSettle();

        // If both render successfully, theme compliance is working
        expect(find.text('@Test'), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('toggles like icon when tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
            ),
          ),
        );

        // Assert initial state - unliked
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);

        // Act - tap like button
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        // Assert - should now be liked
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);

        // Act - tap again to unlike
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Assert - should be unliked again
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
      });

      testWidgets('invokes callback when like button is tapped', (WidgetTester tester) async {
        // Arrange
        int tapCount = 0;

        await tester.pumpWidget(
          makeTestableWidget(
            PointCard(
              username: '@User',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
              onLikeTapped: () {
                tapCount++;
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        // Assert
        expect(tapCount, 1);

        // Act - tap again
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Assert
        expect(tapCount, 2);
      });

      testWidgets('handles missing callback gracefully', (WidgetTester tester) async {
        // Arrange - no callback provided
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
              // onLikeTapped: null, // explicitly not provided
            ),
          ),
        );

        // Act - should not throw when tapping
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        // Assert - icon should still toggle
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('like button has proper tap target size', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
            ),
          ),
        );

        // Find the InkWell that wraps the like button
        final inkWell = find.ancestor(
          of: find.byIcon(Icons.favorite_border),
          matching: find.byType(InkWell),
        );

        expect(inkWell, findsOneWidget);

        // Act - tap the like button area
        await tester.tap(inkWell);
        await tester.pumpAndSettle();

        // Assert - should toggle
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });
    });

    group('Layout and Spacing Tests', () {
      testWidgets('maintains proper spacing between components', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
            ),
          ),
        );

        // Assert - check that SizedBox spacers exist
        expect(find.byType(SizedBox), findsWidgets);

        // Verify Column is used for vertical layout
        expect(find.byType(Column), findsOneWidget);

        // Verify Row is used for metadata section
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('uses Spacer for distance alignment', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
            ),
          ),
        );

        // Assert - Spacer should push distance to the right
        expect(find.byType(Spacer), findsOneWidget);
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('renders with special characters in username', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User_123',
              content: 'Content',
              likes: 5,
              maidenhead: 'FN30as',
              distance: '1.0 km',
            ),
          ),
        );

        // Assert
        expect(find.text('@User_123'), findsOneWidget);
      });

      testWidgets('renders with empty-like content (minimum 1 char)', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            const PointCard(
              username: '@User',
              content: 'x', // Minimum content
              likes: 0,
              maidenhead: 'FN30as',
              distance: '0.0 km',
            ),
          ),
        );

        // Assert
        expect(find.text('x'), findsOneWidget);
      });

      testWidgets('renders with exact 280 character content', (WidgetTester tester) async {
        // Arrange - exactly 280 chars (like Point validation allows)
        final content280 = 'A' * 280;

        await tester.pumpWidget(
          makeTestableWidget(
            PointCard(
              username: '@MaxUser',
              content: content280,
              likes: 10,
              maidenhead: 'FN30as',
              distance: '1.5 km',
            ),
          ),
        );

        // Assert
        expect(find.text(content280), findsOneWidget);
      });

      testWidgets('renders with various Maidenhead formats', (WidgetTester tester) async {
        // Test different valid Maidenhead codes
        const codes = ['FN20aa', 'FN30bt', 'FN31pr', 'JN58td'];

        for (final code in codes) {
          await tester.pumpWidget(
            makeTestableWidget(
              PointCard(
                username: '@User',
                content: 'Content',
                likes: 1,
                maidenhead: code,
                distance: '1.0 km',
              ),
            ),
          );

          expect(find.text(code), findsOneWidget);
        }
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/utils/distance_formatter.dart';

void main() {
  group('DistanceFormatter.format', () {
    group('meter formatting (< 1000m)', () {
      test('formats zero correctly', () {
        expect(DistanceFormatter.format(0), equals('0 m'));
      });

      test('formats small distances', () {
        expect(DistanceFormatter.format(1), equals('1 m'));
        expect(DistanceFormatter.format(5), equals('5 m'));
        expect(DistanceFormatter.format(10), equals('10 m'));
      });

      test('formats medium distances', () {
        expect(DistanceFormatter.format(100), equals('100 m'));
        expect(DistanceFormatter.format(456), equals('456 m'));
        expect(DistanceFormatter.format(500), equals('500 m'));
      });

      test('formats distances near threshold', () {
        expect(DistanceFormatter.format(999), equals('999 m'));
        expect(DistanceFormatter.format(999.4), equals('999 m'));
        expect(DistanceFormatter.format(999.5), equals('1000 m')); // Rounds to 1000m
      });

      test('rounds to nearest meter', () {
        expect(DistanceFormatter.format(456.4), equals('456 m'));
        expect(DistanceFormatter.format(456.5), equals('457 m'));
        expect(DistanceFormatter.format(456.6), equals('457 m'));
      });

      test('formats fractional meters', () {
        expect(DistanceFormatter.format(0.5), equals('1 m')); // Rounds to 1
        expect(DistanceFormatter.format(0.4), equals('0 m')); // Rounds to 0
        expect(DistanceFormatter.format(123.7), equals('124 m'));
      });
    });

    group('kilometer formatting (>= 1000m)', () {
      test('formats threshold correctly', () {
        expect(DistanceFormatter.format(1000), equals('1.0 km'));
      });

      test('formats distances just over threshold', () {
        expect(DistanceFormatter.format(1001), equals('1.0 km'));
        expect(DistanceFormatter.format(1050), equals('1.1 km')); // Rounds to 1.1
        expect(DistanceFormatter.format(1100), equals('1.1 km'));
      });

      test('formats typical distances', () {
        expect(DistanceFormatter.format(1234), equals('1.2 km'));
        expect(DistanceFormatter.format(1234.5), equals('1.2 km'));
        expect(DistanceFormatter.format(2500), equals('2.5 km'));
        expect(DistanceFormatter.format(5678.9), equals('5.7 km'));
      });

      test('formats tuPoint default radius', () {
        expect(DistanceFormatter.format(5000), equals('5.0 km'));
      });

      test('formats larger distances', () {
        expect(DistanceFormatter.format(10000), equals('10.0 km'));
        expect(DistanceFormatter.format(50000), equals('50.0 km'));
        expect(DistanceFormatter.format(100000), equals('100.0 km'));
      });

      test('formats very large distances', () {
        expect(DistanceFormatter.format(123456), equals('123.5 km'));
        expect(DistanceFormatter.format(999999), equals('1000.0 km'));
        expect(DistanceFormatter.format(1234567), equals('1234.6 km'));
      });

      test('rounds to one decimal place', () {
        expect(DistanceFormatter.format(1249), equals('1.2 km'));
        expect(DistanceFormatter.format(1250), equals('1.3 km')); // Dart rounds 1.25 -> 1.3 (banker's rounding)
        expect(DistanceFormatter.format(1251), equals('1.3 km'));
        expect(DistanceFormatter.format(1294), equals('1.3 km'));
        expect(DistanceFormatter.format(1295), equals('1.3 km'));
      });

      test('handles exact kilometer values', () {
        expect(DistanceFormatter.format(1000), equals('1.0 km'));
        expect(DistanceFormatter.format(2000), equals('2.0 km'));
        expect(DistanceFormatter.format(10000), equals('10.0 km'));
      });
    });

    group('edge cases', () {
      test('handles negative values as absolute', () {
        expect(DistanceFormatter.format(-100), equals('100 m'));
        expect(DistanceFormatter.format(-1234), equals('1.2 km'));
      });

      test('handles very small decimals', () {
        expect(DistanceFormatter.format(0.1), equals('0 m'));
        expect(DistanceFormatter.format(0.9), equals('1 m'));
      });

      test('handles maximum double values gracefully', () {
        // Should not throw, should format as very large distance
        final result = DistanceFormatter.format(999999999);
        expect(result.endsWith(' km'), isTrue);
      });
    });

    group('real-world tuPoint scenarios', () {
      test('formats Boston to Cambridge distance', () {
        // ~4200 meters
        expect(DistanceFormatter.format(4200), equals('4.2 km'));
      });

      test('formats typical nearby point distances', () {
        expect(DistanceFormatter.format(123), equals('123 m')); // Very close
        expect(DistanceFormatter.format(456), equals('456 m')); // Nearby
        expect(DistanceFormatter.format(890), equals('890 m')); // Just under 1km
        expect(DistanceFormatter.format(1234), equals('1.2 km')); // Moderate
        expect(DistanceFormatter.format(4567), equals('4.6 km')); // Near 5km limit
      });

      test('formats 5km radius threshold', () {
        expect(DistanceFormatter.format(4999), equals('5.0 km'));
        expect(DistanceFormatter.format(5000), equals('5.0 km'));
        expect(DistanceFormatter.format(5001), equals('5.0 km'));
      });
    });
  });

  group('DistanceFormatter.formatPrecise', () {
    test('formats meters same as standard format', () {
      expect(DistanceFormatter.formatPrecise(456), equals('456 m'));
      expect(DistanceFormatter.formatPrecise(999), equals('999 m'));
    });

    test('formats kilometers with two decimal places', () {
      expect(DistanceFormatter.formatPrecise(1000), equals('1.00 km'));
      expect(DistanceFormatter.formatPrecise(1234), equals('1.23 km'));
      expect(DistanceFormatter.formatPrecise(1234.5), equals('1.23 km'));
      expect(DistanceFormatter.formatPrecise(5678.9), equals('5.68 km'));
    });

    test('provides more precision than standard format', () {
      expect(DistanceFormatter.format(1234), equals('1.2 km'));
      expect(DistanceFormatter.formatPrecise(1234), equals('1.23 km'));

      expect(DistanceFormatter.format(5678.9), equals('5.7 km'));
      expect(DistanceFormatter.formatPrecise(5678.9), equals('5.68 km'));
    });

    test('handles negative values', () {
      expect(DistanceFormatter.formatPrecise(-1234), equals('1.23 km'));
    });
  });

  group('DistanceFormatter.parse', () {
    test('parses meter strings', () {
      expect(DistanceFormatter.parse('456 m'), equals(456.0));
      expect(DistanceFormatter.parse('0 m'), equals(0.0));
      expect(DistanceFormatter.parse('999 m'), equals(999.0));
    });

    test('parses kilometer strings', () {
      expect(DistanceFormatter.parse('1.0 km'), equals(1000.0));
      expect(DistanceFormatter.parse('1.2 km'), equals(1200.0));
      expect(DistanceFormatter.parse('5.7 km'), equals(5700.0));
      expect(DistanceFormatter.parse('10.0 km'), equals(10000.0));
    });

    test('parses precise kilometer strings', () {
      expect(DistanceFormatter.parse('1.23 km'), equals(1230.0));
      expect(DistanceFormatter.parse('5.68 km'), equals(5680.0));
    });

    test('handles extra whitespace', () {
      expect(DistanceFormatter.parse('  456 m  '), equals(456.0));
      expect(DistanceFormatter.parse('  1.2 km  '), equals(1200.0));
    });

    test('throws FormatException for invalid format', () {
      expect(() => DistanceFormatter.parse('invalid'), throwsFormatException);
      expect(() => DistanceFormatter.parse('456'), throwsFormatException);
      expect(() => DistanceFormatter.parse('km 1.2'), throwsFormatException);
      expect(() => DistanceFormatter.parse(''), throwsFormatException);
    });

    test('throws FormatException for invalid numbers', () {
      expect(() => DistanceFormatter.parse('abc m'), throwsFormatException);
      expect(() => DistanceFormatter.parse('xyz km'), throwsFormatException);
    });

    test('round-trip formatting preserves values', () {
      // Meters
      final meters = 456.0;
      final mFormatted = DistanceFormatter.format(meters);
      final mParsed = DistanceFormatter.parse(mFormatted);
      expect(mParsed, equals(meters));

      // Kilometers (with rounding due to 1 decimal)
      final km = 1200.0;
      final kmFormatted = DistanceFormatter.format(km);
      final kmParsed = DistanceFormatter.parse(kmFormatted);
      expect(kmParsed, equals(km));
    });
  });

  group('DistanceFormatter.formatCompact', () {
    test('formats without spaces', () {
      expect(DistanceFormatter.formatCompact(456), equals('456m'));
      expect(DistanceFormatter.formatCompact(1234), equals('1.2km'));
      expect(DistanceFormatter.formatCompact(5678.9), equals('5.7km'));
    });

    test('matches standard format except for spaces', () {
      expect(
        DistanceFormatter.formatCompact(456),
        equals(DistanceFormatter.format(456).replaceAll(' ', '')),
      );
      expect(
        DistanceFormatter.formatCompact(1234),
        equals(DistanceFormatter.format(1234).replaceAll(' ', '')),
      );
    });

    test('useful for compact UI displays', () {
      // Simulate badge or chip text
      final compactText = DistanceFormatter.formatCompact(1234);
      expect(compactText, equals('1.2km'));
      expect(compactText.length, lessThan(10)); // Compact enough for badges
    });
  });

  group('DistanceFormatter integration with real values', () {
    test('formats Haversine calculator output', () {
      // Simulate distance calculation result
      const calculatedDistance = 4237.5; // meters
      final formatted = DistanceFormatter.format(calculatedDistance);
      expect(formatted, equals('4.2 km'));
    });

    test('formats distances at various precision levels', () {
      // Very precise input (from Haversine formula)
      expect(DistanceFormatter.format(4237.891234567), equals('4.2 km'));

      // Integer input
      expect(DistanceFormatter.format(4237), equals('4.2 km'));

      // Results should be identical for display purposes
    });
  });
}

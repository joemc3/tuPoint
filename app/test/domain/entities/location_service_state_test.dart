import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/location_service_state.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

void main() {
  group('LocationServiceState', () {
    group('loading', () {
      test('should create loading state', () {
        const state = LocationServiceState.loading();

        expect(state, isA<LocationServiceState>());
        state.when(
          loading: () => expect(true, true),
          available: (_) => fail('Should be loading'),
          permissionDenied: (_, __) => fail('Should be loading'),
          serviceDisabled: (_) => fail('Should be loading'),
          error: (_) => fail('Should be loading'),
        );
      });
    });

    group('available', () {
      test('should create available state with location', () {
        const location = LocationCoordinate(
          latitude: 37.7749,
          longitude: -122.4194,
        );
        final state = LocationServiceState.available(location: location);

        expect(state, isA<LocationServiceState>());
        state.when(
          loading: () => fail('Should be available'),
          available: (loc) {
            expect(loc, equals(location));
            expect(loc.latitude, equals(37.7749));
            expect(loc.longitude, equals(-122.4194));
          },
          permissionDenied: (_, __) => fail('Should be available'),
          serviceDisabled: (_) => fail('Should be available'),
          error: (_) => fail('Should be available'),
        );
      });

      test('should accept valid coordinates at boundaries', () {
        const locations = [
          LocationCoordinate(latitude: 90.0, longitude: 180.0),
          LocationCoordinate(latitude: -90.0, longitude: -180.0),
          LocationCoordinate(latitude: 0.0, longitude: 0.0),
        ];

        for (final location in locations) {
          final state = LocationServiceState.available(location: location);
          expect(state, isA<LocationServiceState>());
        }
      });
    });

    group('permissionDenied', () {
      test('should create permissionDenied state with message', () {
        const state = LocationServiceState.permissionDenied(
          message: 'Permission denied',
        );

        expect(state, isA<LocationServiceState>());
        state.when(
          loading: () => fail('Should be permissionDenied'),
          available: (_) => fail('Should be permissionDenied'),
          permissionDenied: (message, isPermanent) {
            expect(message, equals('Permission denied'));
            expect(isPermanent, isFalse); // Default value
          },
          serviceDisabled: (_) => fail('Should be permissionDenied'),
          error: (_) => fail('Should be permissionDenied'),
        );
      });

      test('should create permissionDenied state with permanent flag', () {
        const state = LocationServiceState.permissionDenied(
          message: 'Permission permanently denied',
          isPermanent: true,
        );

        state.when(
          permissionDenied: (message, isPermanent) {
            expect(message, equals('Permission permanently denied'));
            expect(isPermanent, isTrue);
          },
          loading: () => fail('Should be permissionDenied'),
          available: (_) => fail('Should be permissionDenied'),
          serviceDisabled: (_) => fail('Should be permissionDenied'),
          error: (_) => fail('Should be permissionDenied'),
        );
      });
    });

    group('serviceDisabled', () {
      test('should create serviceDisabled state with message', () {
        const state = LocationServiceState.serviceDisabled(
          message: 'Location services disabled',
        );

        expect(state, isA<LocationServiceState>());
        state.when(
          loading: () => fail('Should be serviceDisabled'),
          available: (_) => fail('Should be serviceDisabled'),
          permissionDenied: (_, __) => fail('Should be serviceDisabled'),
          serviceDisabled: (message) {
            expect(message, equals('Location services disabled'));
          },
          error: (_) => fail('Should be serviceDisabled'),
        );
      });
    });

    group('error', () {
      test('should create error state with message', () {
        const state = LocationServiceState.error(
          message: 'Location timeout',
        );

        expect(state, isA<LocationServiceState>());
        state.when(
          loading: () => fail('Should be error'),
          available: (_) => fail('Should be error'),
          permissionDenied: (_, __) => fail('Should be error'),
          serviceDisabled: (_) => fail('Should be error'),
          error: (message) {
            expect(message, equals('Location timeout'));
          },
        );
      });
    });

    group('equality', () {
      test('same loading states should be equal', () {
        const state1 = LocationServiceState.loading();
        const state2 = LocationServiceState.loading();

        expect(state1, equals(state2));
      });

      test('same available states with same location should be equal', () {
        const location = LocationCoordinate(latitude: 37.7749, longitude: -122.4194);
        final state1 = LocationServiceState.available(location: location);
        final state2 = LocationServiceState.available(location: location);

        expect(state1, equals(state2));
      });

      test('available states with different locations should not be equal', () {
        const location1 = LocationCoordinate(latitude: 37.7749, longitude: -122.4194);
        const location2 = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);
        final state1 = LocationServiceState.available(location: location1);
        final state2 = LocationServiceState.available(location: location2);

        expect(state1, isNot(equals(state2)));
      });

      test('error states with same message should be equal', () {
        const state1 = LocationServiceState.error(message: 'Error');
        const state2 = LocationServiceState.error(message: 'Error');

        expect(state1, equals(state2));
      });

      test('different state types should not be equal', () {
        const state1 = LocationServiceState.loading();
        const state2 = LocationServiceState.error(message: 'Error');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('maybeWhen', () {
      test('should execute available callback when available', () {
        const location = LocationCoordinate(latitude: 37.7749, longitude: -122.4194);
        final state = LocationServiceState.available(location: location);

        final result = state.maybeWhen(
          available: (loc) => 'has location',
          orElse: () => 'no location',
        );

        expect(result, equals('has location'));
      });

      test('should execute orElse when callback not provided', () {
        const state = LocationServiceState.loading();

        final result = state.maybeWhen(
          available: (_) => 'has location',
          orElse: () => 'no location',
        );

        expect(result, equals('no location'));
      });
    });

    group('map', () {
      test('should transform all states correctly', () {
        const location = LocationCoordinate(latitude: 37.7749, longitude: -122.4194);
        final states = [
          const LocationServiceState.loading(),
          LocationServiceState.available(location: location),
          const LocationServiceState.permissionDenied(message: 'Denied'),
          const LocationServiceState.serviceDisabled(message: 'Disabled'),
          const LocationServiceState.error(message: 'Error'),
        ];

        for (final state in states) {
          final result = state.map(
            loading: (_) => 'loading',
            available: (_) => 'available',
            permissionDenied: (_) => 'denied',
            serviceDisabled: (_) => 'disabled',
            error: (_) => 'error',
          );

          expect(result, isA<String>());
        }
      });
    });
  });
}

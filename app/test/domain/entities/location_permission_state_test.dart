import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/location_permission_state.dart';

void main() {
  group('LocationPermissionState', () {
    group('notAsked', () {
      test('should create notAsked state', () {
        const state = LocationPermissionState.notAsked();

        expect(state, isA<LocationPermissionState>());
        state.when(
          notAsked: () => expect(true, true),
          granted: () => fail('Should be notAsked'),
          denied: () => fail('Should be notAsked'),
          deniedForever: () => fail('Should be notAsked'),
          serviceDisabled: () => fail('Should be notAsked'),
        );
      });
    });

    group('granted', () {
      test('should create granted state', () {
        const state = LocationPermissionState.granted();

        expect(state, isA<LocationPermissionState>());
        state.when(
          notAsked: () => fail('Should be granted'),
          granted: () => expect(true, true),
          denied: () => fail('Should be granted'),
          deniedForever: () => fail('Should be granted'),
          serviceDisabled: () => fail('Should be granted'),
        );
      });
    });

    group('denied', () {
      test('should create denied state', () {
        const state = LocationPermissionState.denied();

        expect(state, isA<LocationPermissionState>());
        state.when(
          notAsked: () => fail('Should be denied'),
          granted: () => fail('Should be denied'),
          denied: () => expect(true, true),
          deniedForever: () => fail('Should be denied'),
          serviceDisabled: () => fail('Should be denied'),
        );
      });
    });

    group('deniedForever', () {
      test('should create deniedForever state', () {
        const state = LocationPermissionState.deniedForever();

        expect(state, isA<LocationPermissionState>());
        state.when(
          notAsked: () => fail('Should be deniedForever'),
          granted: () => fail('Should be deniedForever'),
          denied: () => fail('Should be deniedForever'),
          deniedForever: () => expect(true, true),
          serviceDisabled: () => fail('Should be deniedForever'),
        );
      });
    });

    group('serviceDisabled', () {
      test('should create serviceDisabled state', () {
        const state = LocationPermissionState.serviceDisabled();

        expect(state, isA<LocationPermissionState>());
        state.when(
          notAsked: () => fail('Should be serviceDisabled'),
          granted: () => fail('Should be serviceDisabled'),
          denied: () => fail('Should be serviceDisabled'),
          deniedForever: () => fail('Should be serviceDisabled'),
          serviceDisabled: () => expect(true, true),
        );
      });
    });

    group('equality', () {
      test('same states should be equal', () {
        const state1 = LocationPermissionState.granted();
        const state2 = LocationPermissionState.granted();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('different states should not be equal', () {
        const state1 = LocationPermissionState.granted();
        const state2 = LocationPermissionState.denied();

        expect(state1, isNot(equals(state2)));
      });
    });

    group('maybeWhen', () {
      test('should execute granted callback when granted', () {
        const state = LocationPermissionState.granted();

        final result = state.maybeWhen(
          granted: () => 'granted',
          orElse: () => 'other',
        );

        expect(result, equals('granted'));
      });

      test('should execute orElse when callback not provided', () {
        const state = LocationPermissionState.denied();

        final result = state.maybeWhen(
          granted: () => 'granted',
          orElse: () => 'other',
        );

        expect(result, equals('other'));
      });
    });
  });
}

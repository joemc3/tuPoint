import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/entities/point.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_points_repository.dart';
import 'package:app/domain/use_cases/point_use_cases/drop_point_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

class MockPointsRepository extends Mock implements IPointsRepository {}

void main() {
  late MockPointsRepository mockRepository;
  late DropPointUseCase useCase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(LocationCoordinate(latitude: 0, longitude: 0));
  });

  setUp(() {
    mockRepository = MockPointsRepository();
    useCase = DropPointUseCase(pointsRepository: mockRepository);
  });

  group('DropPointUseCase', () {
    final validUserId = '123e4567-e89b-12d3-a456-426614174000';
    final validLocation = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);
    const validMaidenhead = 'FN20xr';
    final now = DateTime.now();

    group('happy path', () {
      test('creates point with valid inputs', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Hello, world!',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        final expectedPoint = Point(
          id: 'point-123',
          userId: validUserId,
          content: 'Hello, world!',
          location: validLocation,
          maidenhead6char: 'FN20XR',
          isActive: true,
          createdAt: now,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'Hello, world!',
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenAnswer((_) async => expectedPoint);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(expectedPoint));
        expect(result.content, equals('Hello, world!'));
        verify(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'Hello, world!',
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).called(1);
      });

      test('trims content before creating point', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: '  Spaces around me  ',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        final expectedPoint = Point(
          id: 'point-123',
          userId: validUserId,
          content: 'Spaces around me',
          location: validLocation,
          maidenhead6char: 'FN20XR',
          isActive: true,
          createdAt: now,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'Spaces around me',
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenAnswer((_) async => expectedPoint);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.content, equals('Spaces around me'));
      });

      test('uppercases Maidenhead locator', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: 'fn20xr', // lowercase
        );

        final expectedPoint = Point(
          id: 'point-123',
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: 'FN20XR',
          isActive: true,
          createdAt: now,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'Test content',
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenAnswer((_) async => expectedPoint);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.maidenhead6char, equals('FN20XR'));
      });

      test('accepts content at minimum length boundary (1 char)', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'A',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        final expectedPoint = Point(
          id: 'point-123',
          userId: validUserId,
          content: 'A',
          location: validLocation,
          maidenhead6char: 'FN20XR',
          isActive: true,
          createdAt: now,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'A',
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenAnswer((_) async => expectedPoint);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.content, equals('A'));
      });

      test('accepts content at maximum length boundary (280 chars)', () async {
        // Arrange
        final longContent = 'x' * 280;
        final request = DropPointRequest(
          userId: validUserId,
          content: longContent,
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        final expectedPoint = Point(
          id: 'point-123',
          userId: validUserId,
          content: longContent,
          location: validLocation,
          maidenhead6char: 'FN20XR',
          isActive: true,
          createdAt: now,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: longContent,
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenAnswer((_) async => expectedPoint);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.content.length, equals(280));
      });

      test('creates point with various Maidenhead formats', () async {
        // Test different valid Maidenhead locators
        final testCases = [
          'AA00aa',
          'RR99xx',
          'FN20xr',
          'JO01aa',
        ];

        for (final maidenhead in testCases) {
          // Arrange
          final request = DropPointRequest(
            userId: validUserId,
            content: 'Test at $maidenhead',
            location: validLocation,
            maidenhead6char: maidenhead,
          );

          final expectedPoint = Point(
            id: 'point-123',
            userId: validUserId,
            content: 'Test at $maidenhead',
            location: validLocation,
            maidenhead6char: maidenhead.toUpperCase(),
            isActive: true,
            createdAt: now,
          );

          when(() => mockRepository.createPoint(
                userId: validUserId,
                content: 'Test at $maidenhead',
                location: validLocation,
                maidenhead6char: maidenhead.toUpperCase(),
              )).thenAnswer((_) async => expectedPoint);

          // Act
          final result = await useCase(request);

          // Assert
          expect(result.maidenhead6char, equals(maidenhead.toUpperCase()));
        }
      });
    });

    group('validation - userId', () {
      test('throws ValidationException when userId is empty', () async {
        // Arrange
        final request = DropPointRequest(
          userId: '',
          content: 'Valid content',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('User ID cannot be empty'),
          )),
        );
        verifyNever(() => mockRepository.createPoint(
              userId: any(named: 'userId'),
              content: any(named: 'content'),
              location: any(named: 'location'),
              maidenhead6char: any(named: 'maidenhead6char'),
            ));
      });
    });

    group('validation - content', () {
      test('throws ValidationException when content is empty', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: '',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Point content cannot be empty'),
          )),
        );
      });

      test('throws ValidationException when content is only whitespace', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: '   ',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Point content cannot be empty'),
          )),
        );
      });

      test('throws ValidationException when content exceeds 280 characters', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'x' * 281,
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Point content exceeds 280 characters'),
          )),
        );
      });

      test('does not throw when content with whitespace trims to valid length', () async {
        // Arrange
        final contentWithSpaces = '  ${'x' * 280}  '; // 284 total, 280 after trim
        final request = DropPointRequest(
          userId: validUserId,
          content: contentWithSpaces,
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        final expectedPoint = Point(
          id: 'point-123',
          userId: validUserId,
          content: 'x' * 280,
          location: validLocation,
          maidenhead6char: 'FN20XR',
          isActive: true,
          createdAt: now,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'x' * 280,
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenAnswer((_) async => expectedPoint);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.content.length, equals(280));
      });
    });

    group('validation - Maidenhead locator', () {
      test('throws ValidationException when Maidenhead is not 6 characters', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: 'FN20', // only 4 chars
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Maidenhead locator must be exactly 6 characters'),
          )),
        );
      });

      test('throws ValidationException when Maidenhead is too long', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: 'FN20xr00', // 8 chars
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Maidenhead locator must be exactly 6 characters'),
          )),
        );
      });

      test('throws ValidationException when Maidenhead format is invalid (wrong pattern)', () async {
        // Arrange - digits where letters should be
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: '123456',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid Maidenhead locator format'),
          )),
        );
      });

      test('throws ValidationException when Maidenhead has letters out of range', () async {
        // Arrange - 'S' is out of range (should be A-R for first pair)
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: 'SN20xr',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid Maidenhead locator format'),
          )),
        );
      });

      test('throws ValidationException when Maidenhead has last pair out of range', () async {
        // Arrange - 'Y' is out of range (should be A-X for last pair)
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: 'FN20yr',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid Maidenhead locator format'),
          )),
        );
      });

      test('throws ValidationException when Maidenhead contains special characters', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: 'FN-0xr',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid Maidenhead locator format'),
          )),
        );
      });
    });

    group('repository exceptions', () {
      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'Test content',
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenThrow(UnauthorizedException('Not authorized'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('propagates RepositoryException from repository', () async {
        // Arrange
        final request = DropPointRequest(
          userId: validUserId,
          content: 'Test content',
          location: validLocation,
          maidenhead6char: validMaidenhead,
        );

        when(() => mockRepository.createPoint(
              userId: validUserId,
              content: 'Test content',
              location: validLocation,
              maidenhead6char: 'FN20XR',
            )).thenThrow(DatabaseException('Database error'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DatabaseException>()),
        );
      });
    });
  });
}

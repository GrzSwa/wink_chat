import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wink_chat/src/common/domain/models/auth_user.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/locations_provider.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/registration_screen.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';

import '../mocks.mocks.dart';

void main() {
  group('Location Selection on Registration', () {
    late MockAuthRepository mockAuthRepository;
    late MockFirebaseUserRepository mockFirebaseUserRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockFirebaseUserRepository = MockFirebaseUserRepository();
    });

    testWidgets('should call createUserProfile with selected location', (
      WidgetTester tester,
    ) async {
      // Arrange
      const selectedLocation = 'Warszawa';
      const locationType = 'województwo';

      when(
        mockAuthRepository.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => AuthUser(id: '123', email: 'test@test.com'));

      when(
        mockFirebaseUserRepository.createUserProfile(
          authUser: anyNamed('authUser'),
          pseudonim: anyNamed('pseudonim'),
          gender: anyNamed('gender'),
          location: anyNamed('location'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authFeatureRepositoryProvider.overrideWithValue(mockAuthRepository),
            locationsProvider.overrideWith(
              (ref) => Future.value([selectedLocation, 'Kraków']),
            ),
            locationTypeProvider(
              selectedLocation,
            ).overrideWith((ref) => Future.value(locationType)),
            authStateProvider.overrideWith(
              (ref) =>
                  Stream.value(AuthUser(id: '123', email: 'test@test.com')),
            ),
          ],
          child: MaterialApp(
            home: RegistrationScreen(
              userRepository: mockFirebaseUserRepository,
              onRegisterSuccess: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.enterText(find.byKey(const Key('nickname_field')), 'tester');

      await tester.ensureVisible(
        find.byKey(const Key('location_select_field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('location_select_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedLocation).last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Assert
      final captured =
          verify(
            mockFirebaseUserRepository.createUserProfile(
              authUser: anyNamed('authUser'),
              pseudonim: anyNamed('pseudonim'),
              gender: anyNamed('gender'),
              location: captureAnyNamed('location'),
            ),
          ).captured;

      expect(captured.first['value'], selectedLocation);
      expect(captured.first['type'], locationType);
    });
  });
}

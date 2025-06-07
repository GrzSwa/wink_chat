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
  group('Gender Selection Widget Test', () {
    late MockAuthRepository mockAuthRepository;
    late MockFirebaseUserRepository mockFirebaseUserRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockFirebaseUserRepository = MockFirebaseUserRepository();
    });

    testWidgets('should call createUserProfile with selected gender "F"', (
      WidgetTester tester,
    ) async {
      // Arrange
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
            locationsProvider.overrideWith((ref) => Future.value(['Warszawa'])),
            locationTypeProvider(
              'Warszawa',
            ).overrideWith((ref) => Future.value('województwo')),
            // This is the key: we provide a real user to the authStateProvider
            // so the `if (authUser != null)` check passes.
            // But we do NOT mock the navigator, so it won't navigate away.
            // In a test environment, Navigator.pushReplacement won't rip out
            // the widget under test if we don't pump new frames excessively.
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

      await tester.ensureVisible(find.byKey(const Key('gender_radio_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('F'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('location_select_field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('location_select_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warszawa').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('register_button')));
      // We need one pump to process the tap and another for the async signUp.
      await tester.pump();
      await tester.pump();

      // Assert
      final captured =
          verify(
            mockFirebaseUserRepository.createUserProfile(
              authUser: captureAnyNamed('authUser'),
              pseudonim: captureAnyNamed('pseudonim'),
              gender: captureAnyNamed('gender'),
              location: captureAnyNamed('location'),
            ),
          ).captured;

      expect(captured[2], 'F');
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wink_chat/src/common/domain/models/auth_user.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';

import '../mocks.mocks.dart';

void main() {
  group('AuthFeatureController Tests', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;
    late AuthFeatureController authController;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authFeatureRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      authController = container.read(authFeatureControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    const email = 'test@test.pl';
    const password = 'qwerty';

    test('signIn success', () async {
      // Arrange
      final states = <AsyncValue<void>>[];
      authController.addListener(states.add, fireImmediately: false);

      final authUser = AuthUser(
        id: 'u09N7mRRwZh6huV7pV7nJYU9P042',
        email: email,
      );
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer((_) async => authUser);

      // Act
      final result = await authController.signIn(
        email: email,
        password: password,
      );

      // Assert
      verify(
        mockAuthRepository.signIn(email: email, password: password),
      ).called(1);
      expect(states, [
        const AsyncValue<void>.loading(),
        const AsyncValue<void>.data(null),
      ]);
      expect(result, const AsyncValue<void>.data(null));
    });

    test('signIn failure', () async {
      // Arrange
      final states = <AsyncValue<void>>[];
      authController.addListener(states.add, fireImmediately: false);

      final exception = Exception('Nieprawidłowe hasło.');
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenThrow(exception);

      // Act
      final result = await authController.signIn(
        email: email,
        password: password,
      );

      // Assert
      verify(
        mockAuthRepository.signIn(email: email, password: password),
      ).called(1);
      expect(states.length, 2);
      expect(states[0], const AsyncValue<void>.loading());
      expect(states[1], isA<AsyncError<void>>());
      expect((states[1] as AsyncError).error, exception);

      expect(result, isA<AsyncError<void>>());
      expect((result as AsyncError).error, exception);
    });
  });
}

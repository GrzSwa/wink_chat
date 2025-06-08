import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wink_chat/src/common/domain/models/auth_user.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/account/domain/user.dart'
    as account_user;
import 'package:wink_chat/src/features/account/providers/user_provider.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';
import 'package:wink_chat/src/features/explore/presentation/providers/explore_provider.dart';

import '../mocks.mocks.dart';

void main() {
  group('exploreUsersProvider unit tests', () {
    late MockExploreRepository mockExploreRepository;

    // Test data
    const testLocation = 'TestLocation';
    final mockUsers = [
      ExploreUser(
        id: 'user1',
        pseudonim: 'tester1',
        gender: 'M',
        location: {'type': 'voivodeship', 'value': testLocation},
        lastSeen: DateTime.now(),
      ),
    ];
    final mockAuthUser = AuthUser(id: 'currentUserId', email: 'test@test.com');
    final mockAccountUserWithLocation = account_user.User(
      uid: 'currentUserId',
      pseudonim: 'CurrentUser',
      gender: 'F',
      location: const account_user.UserLocation(
        value: testLocation,
        type: 'voivodeship',
      ),
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final mockAccountUserWithoutLocation = account_user.User(
      uid: 'currentUserId',
      pseudonim: 'CurrentUser',
      gender: 'F',
      location: const account_user.UserLocation(value: '', type: ''),
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockExploreRepository = MockExploreRepository();
      when(
        mockExploreRepository.getUsersInLocation(any, any),
      ).thenAnswer((_) => Stream.value(mockUsers));
    });

    test(
      'should return users when user is logged in and has a location',
      () async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            exploreRepositoryProvider.overrideWithValue(mockExploreRepository),
            authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
            userStreamProvider.overrideWith(
              (ref) => Stream.value(mockAccountUserWithLocation),
            ),
          ],
        );
        final states = <AsyncValue<List<ExploreUser>>>[];
        container.listen(exploreUsersProvider, (previous, next) {
          states.add(next);
        }, fireImmediately: true);

        // Act
        await container.read(exploreUsersProvider.future);

        // Assert
        expect(states, [
          isA<AsyncLoading>(),
          isA<AsyncData<List<ExploreUser>>>().having(
            (d) => d.value,
            'value',
            mockUsers,
          ),
        ]);
        verify(
          mockExploreRepository.getUsersInLocation(
            testLocation,
            'currentUserId',
          ),
        ).called(1);
      },
    );

    test('should return empty list when user is not logged in', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(mockExploreRepository),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          userStreamProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      final states = <AsyncValue<List<ExploreUser>>>[];
      container.listen(exploreUsersProvider, (previous, next) {
        states.add(next);
      }, fireImmediately: true);

      // Act
      await container.read(exploreUsersProvider.future);

      // Assert
      expect(states, [
        isA<AsyncLoading>(),
        isA<AsyncData<List<ExploreUser>>>().having(
          (d) => d.value,
          'value',
          isEmpty,
        ),
      ]);
      verifyNever(mockExploreRepository.getUsersInLocation(any, any));
    });

    test('should return empty list when user has no location', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(mockExploreRepository),
          authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
          userStreamProvider.overrideWith(
            (ref) => Stream.value(mockAccountUserWithoutLocation),
          ),
        ],
      );
      final states = <AsyncValue<List<ExploreUser>>>[];
      container.listen(exploreUsersProvider, (previous, next) {
        states.add(next);
      }, fireImmediately: true);

      // Act
      await container.read(exploreUsersProvider.future);

      // Assert
      expect(states, [
        isA<AsyncLoading>(),
        isA<AsyncData<List<ExploreUser>>>().having(
          (d) => d.value,
          'value',
          isEmpty,
        ),
      ]);
      verifyNever(mockExploreRepository.getUsersInLocation(any, any));
    });
  });
}

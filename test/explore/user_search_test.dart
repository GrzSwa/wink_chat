import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wink_chat/src/common/domain/models/auth_user.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/account/domain/user.dart'
    as account_user;
import 'package:wink_chat/src/features/account/providers/user_provider.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';
import 'package:wink_chat/src/features/explore/presentation/providers/explore_provider.dart';
import 'package:wink_chat/src/features/explore/presentation/screens/explore_screen.dart';

import '../mocks.mocks.dart';

void main() {
  // Mocks for repositories
  late MockExploreRepository mockExploreRepository;
  late MockChatRepository mockChatRepository;

  // Test data
  const currentUserId = 'currentUserId';
  const testLocation = 'Warszawa';
  final mockUsers = [
    ExploreUser(
      id: 'user1',
      pseudonim: 'tester1',
      gender: 'M',
      location: {'type': 'voivodeship', 'value': testLocation},
      lastSeen: DateTime.now(),
    ),
  ];
  final mockAuthUser = AuthUser(id: currentUserId, email: 'test@test.com');
  final mockAccountUser = account_user.User(
    uid: currentUserId,
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

  setUp(() {
    mockExploreRepository = MockExploreRepository();
    mockChatRepository = MockChatRepository();

    // Stub for ExploreRepository
    when(
      mockExploreRepository.getUsersInLocation(any, any),
    ).thenAnswer((_) => Stream.value(mockUsers));

    // Stubs for ChatRepository
    when(
      mockChatRepository.getPendingChatRequests(any),
    ).thenAnswer((_) => Stream.value([]));
    when(
      mockChatRepository.getChatStatus(any, any),
    ).thenAnswer((_) => Stream.value(ChatStatus.none));
    when(
      mockChatRepository.sendChatRequest(
        initiatorId: anyNamed('initiatorId'),
        recipientId: anyNamed('recipientId'),
      ),
    ).thenAnswer((_) async {});
  });

  testWidgets('ExploreScreen should display users and handle chat requests', (
    tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override repositories with mocks
          exploreRepositoryProvider.overrideWithValue(mockExploreRepository),
          chatRepositoryProvider.overrideWithValue(mockChatRepository),
          // Provide auth and user state
          authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
          userStreamProvider.overrideWith(
            (ref) => Stream.value(mockAccountUser),
          ),
        ],
        child: const MaterialApp(home: ExploreScreen()),
      ),
    );

    // Act
    await tester.pumpAndSettle();
    await tester.pump(Duration.zero);

    // Assert: Verify UI elements
    expect(
      find.text('Osoby w $testLocation'),
      findsOneWidget,
      reason: 'App bar title should show the correct location',
    );
    expect(
      find.text('tester1'),
      findsOneWidget,
      reason: 'User "tester1" should be displayed on the list',
    );

    // Act: Tap chat request button
    await tester.tap(find.text('Rozmowa'));
    await tester.pumpAndSettle();

    // Assert: Verify repository method was called
    final captured =
        verify(
          mockChatRepository.sendChatRequest(
            initiatorId: captureAnyNamed('initiatorId'),
            recipientId: captureAnyNamed('recipientId'),
          ),
        ).captured;

    expect(
      captured[0],
      currentUserId,
      reason: 'Initiator ID should be the current user',
    );
    expect(
      captured[1],
      mockUsers.first.id,
      reason: 'Recipient ID should be the tapped user',
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';
import 'package:wink_chat/src/features/explore/presentation/widgets/user_list_tile.dart';

void main() {
  group('UserListTile Widget Tests for sending chat request', () {
    late ExploreUser testUser;
    late Function(ExploreUser) onChatRequest;
    bool onChatRequestCalled = false;

    setUp(() {
      testUser = ExploreUser(
        id: 'user1',
        pseudonim: 'Tester',
        gender: 'M',
        location: {'type': 'voivodeship', 'value': 'TestLocation'},
        lastSeen: DateTime.now(),
      );
      onChatRequest = (user) {
        onChatRequestCalled = true;
      };
      onChatRequestCalled = false;
    });

    Widget createTestWidget({required ChatStatus status}) {
      return MaterialApp(
        home: Scaffold(
          body: UserListTile(
            user: testUser,
            status: status,
            lastSeenFormatted: 'teraz',
            onChatRequest: onChatRequest,
          ),
        ),
      );
    }

    testWidgets(
      'should display "Rozmowa" button and call onChatRequest when status is none',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(status: ChatStatus.none));

        // Act
        final button = find.widgetWithText(ElevatedButton, 'Rozmowa');
        expect(button, findsOneWidget);
        await tester.tap(button);
        await tester.pumpAndSettle(); // For SnackBar animation

        // Assert
        expect(onChatRequestCalled, isTrue);
        expect(find.text('Wysłano prośbę o rozmowę'), findsOneWidget);
      },
    );

    testWidgets('should NOT display "Rozmowa" button when status is pending', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(status: ChatStatus.pending));

      // Act
      final button = find.widgetWithText(ElevatedButton, 'Rozmowa');

      // Assert
      expect(button, findsNothing);
    });

    testWidgets('should NOT display "Rozmowa" button when status is active', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(status: ChatStatus.active));

      // Act
      final button = find.widgetWithText(ElevatedButton, 'Rozmowa');

      // Assert
      expect(button, findsNothing);
    });

    testWidgets('should NOT display "Rozmowa" button when status is rejected', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(status: ChatStatus.rejected));

      // Act
      final button = find.widgetWithText(ElevatedButton, 'Rozmowa');

      // Assert
      expect(button, findsNothing);
    });

    testWidgets('should NOT display "Rozmowa" button when status is ended', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(status: ChatStatus.ended));

      // Act
      final button = find.widgetWithText(ElevatedButton, 'Rozmowa');

      // Assert
      expect(button, findsNothing);
    });

    testWidgets('should display user information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(status: ChatStatus.none));

      // Assert
      expect(find.text('Tester'), findsOneWidget);
      expect(find.text('Ostatnio aktywny: teraz'), findsOneWidget);
      expect(find.byIcon(Icons.male), findsOneWidget);
    });
  });
}

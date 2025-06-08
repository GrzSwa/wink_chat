import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';

void main() {
  group('ChatRepository for sending chat request', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ChatRepository chatRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      chatRepository = ChatRepository(firestore: fakeFirestore);
    });

    test('sendChatRequest creates pending status for both users', () async {
      // Arrange
      const initiatorId = 'userA';
      const recipientId = 'userB';

      // Act
      await chatRepository.sendChatRequest(
        initiatorId: initiatorId,
        recipientId: recipientId,
      );

      // Assert
      final initiatorDoc =
          await fakeFirestore.collection('chats').doc(initiatorId).get();
      final recipientDoc =
          await fakeFirestore.collection('chats').doc(recipientId).get();

      // Check initiator's document
      expect(initiatorDoc.exists, isTrue);
      final initiatorData = initiatorDoc.data();
      expect(initiatorData, isNotNull);
      expect(initiatorData!.containsKey(recipientId), isTrue);
      final initiatorChatData =
          initiatorData[recipientId] as Map<String, dynamic>;
      expect(initiatorChatData['status'], ChatStatus.pending.name);
      expect(initiatorChatData['initiatorId'], initiatorId);
      expect(initiatorChatData['messageID'], isA<String>());

      // Check recipient's document
      expect(recipientDoc.exists, isTrue);
      final recipientData = recipientDoc.data();
      expect(recipientData, isNotNull);
      expect(recipientData!.containsKey(initiatorId), isTrue);
      final recipientChatData =
          recipientData[initiatorId] as Map<String, dynamic>;
      expect(recipientChatData['status'], ChatStatus.pending.name);
      expect(recipientChatData['initiatorId'], initiatorId);
      expect(recipientChatData['messageID'], isA<String>());

      // Check if messageIDs are the same
      expect(initiatorChatData['messageID'], recipientChatData['messageID']);
    });
  });
}

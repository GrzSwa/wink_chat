import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/user_chats/domain/models/active_chat.dart';
import 'package:wink_chat/src/features/user_chats/domain/models/chat_message.dart';

class UserChatsRepository {
  final FirebaseFirestore _firestore;

  UserChatsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ActiveChat>> getActiveChats(String userId) {
    return _firestore.collection('chats').doc(userId).snapshots().asyncMap((
      snapshot,
    ) async {
      if (!snapshot.exists) {
        return [];
      }

      final chatsData = snapshot.data() as Map<String, dynamic>;
      final List<ActiveChat> activeChats = [];

      for (final entry in chatsData.entries) {
        final participantId = entry.key;
        final chatData = entry.value as Map<String, dynamic>;

        if (chatData['status'] == 'active') {
          // Fetch participant's pseudonym
          final participantDoc =
              await _firestore.collection('users').doc(participantId).get();

          if (participantDoc.exists) {
            final participantData =
                participantDoc.data() as Map<String, dynamic>;
            final pseudonim = participantData['pseudonim'] as String;

            activeChats.add(
              ActiveChat.fromFirestore(participantId, chatData, pseudonim),
            );
          }
        }
      }

      return activeChats;
    });
  }

  Stream<List<ChatMessage>> getChatMessages(String messageId) {
    return _firestore
        .collection('messages')
        .doc(messageId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> sendMessage({
    required String messageId,
    required String from,
    required String to,
    required String message,
  }) async {
    await _firestore
        .collection('messages')
        .doc(messageId)
        .collection('messages')
        .add(
          ChatMessage(
            id: '',
            from: from,
            to: to,
            message: message,
            time: DateTime.now(),
          ).toMap(),
        );
  }
}

final userChatsRepositoryProvider = Provider<UserChatsRepository>((ref) {
  return UserChatsRepository();
});

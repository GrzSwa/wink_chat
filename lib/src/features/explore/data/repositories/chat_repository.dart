import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';

enum ChatStatus { none, pending, active, rejected, ended }

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createChatRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final now = DateTime.now();
    final messageId = _firestore.collection('messages').doc().id;

    // Create chat document for current user
    await _firestore.collection('chats').doc(currentUserId).set({
      targetUserId: {
        'messageID': messageId,
        'status': ChatStatus.pending.name,
        'initiatorId': currentUserId,
        'createdAt': now,
        'updatedAt': now,
      },
    }, SetOptions(merge: true));

    // Create chat document for target user
    await _firestore.collection('chats').doc(targetUserId).set({
      currentUserId: {
        'messageID': messageId,
        'status': ChatStatus.pending.name,
        'initiatorId': currentUserId,
        'createdAt': now,
        'updatedAt': now,
      },
    }, SetOptions(merge: true));
  }

  Future<void> respondToChatRequest({
    required String currentUserId,
    required String initiatorId,
    required bool accepted,
  }) async {
    final now = DateTime.now();
    final status = accepted ? ChatStatus.active.name : ChatStatus.rejected.name;

    // Get the chat data to retrieve messageId
    final currentUserDoc =
        await _firestore.collection('chats').doc(currentUserId).get();
    final chatData =
        (currentUserDoc.data() ?? {})[initiatorId] as Map<String, dynamic>?;

    if (chatData == null) {
      throw Exception('Chat data not found');
    }

    final messageId = chatData['messageID'] as String;

    // Update chat document for current user
    await _firestore.collection('chats').doc(currentUserId).set({
      initiatorId: {
        'messageID': messageId,
        'status': status,
        'initiatorId': initiatorId,
        'updatedAt': now,
      },
    }, SetOptions(merge: true));

    // Update chat document for initiator
    await _firestore.collection('chats').doc(initiatorId).set({
      currentUserId: {
        'messageID': messageId,
        'status': status,
        'initiatorId': initiatorId,
        'updatedAt': now,
      },
    }, SetOptions(merge: true));

    // If accepted, create the messages document
    if (accepted) {
      await _firestore.collection('messages').doc(messageId).set({
        'participants': [currentUserId, initiatorId],
        'createdAt': now,
        'updatedAt': now,
      });

      // Create messages subcollection
      await _firestore
          .collection('messages')
          .doc(messageId)
          .collection('messages')
          .add({
            'from': currentUserId,
            'to': initiatorId,
            'message': 'Rozmowa rozpoczęta!',
            'time': now,
          });
    }
  }

  Stream<List<Map<String, dynamic>>> getPendingChatRequests(String userId) {
    return _firestore.collection('chats').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data();
      if (data == null) return [];

      final pendingRequests = <Map<String, dynamic>>[];
      data.forEach((participantId, chatData) {
        if (chatData is Map<String, dynamic> &&
            chatData['status'] == ChatStatus.pending.name &&
            chatData['initiatorId'] != userId) {
          pendingRequests.add({'participantId': participantId, ...chatData});
        }
      });

      // Sort by createdAt in descending order (newest first)
      pendingRequests.sort(
        (a, b) => (b['createdAt'] as Timestamp).compareTo(
          a['createdAt'] as Timestamp,
        ),
      );

      return pendingRequests;
    });
  }

  Stream<ChatStatus> getChatStatus(String currentUserId, String targetUserId) {
    try {
      return _firestore.collection('chats').doc(currentUserId).snapshots().map((
        doc,
      ) {
        if (!doc.exists) return ChatStatus.none;
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return ChatStatus.none;

        final chatData = data[targetUserId] as Map<String, dynamic>?;
        if (chatData == null) return ChatStatus.none;

        return ChatStatus.values.firstWhere(
          (status) => status.name == chatData['status'],
          orElse: () => ChatStatus.none,
        );
      });
    } catch (e) {
      // If there's any error (like collection doesn't exist), return none
      return Stream.value(ChatStatus.none);
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatStatusProvider = StreamProvider.family<ChatStatus, String>((
  ref,
  targetUserId,
) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(ChatStatus.none);

  return ref
      .read(chatRepositoryProvider)
      .getChatStatus(authUser.id, targetUserId);
});

final pendingChatRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value([]);

  return ref.read(chatRepositoryProvider).getPendingChatRequests(authUser.id);
});

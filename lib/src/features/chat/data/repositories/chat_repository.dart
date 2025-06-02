import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';

enum ChatStatus { pending, active, rejected, ended }

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createChatRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final now = DateTime.now();

    // Create chat document for current user
    await _firestore.collection('chats').doc(currentUserId).set({
      targetUserId: {
        'status': ChatStatus.pending.name,
        'initiatorId': currentUserId,
        'createdAt': now,
        'updatedAt': now,
      },
    }, SetOptions(merge: true));

    // Create chat document for target user
    await _firestore.collection('chats').doc(targetUserId).set({
      currentUserId: {
        'status': ChatStatus.pending.name,
        'initiatorId': currentUserId,
        'createdAt': now,
        'updatedAt': now,
      },
    }, SetOptions(merge: true));
  }

  Stream<ChatStatus> getChatStatus(String currentUserId, String targetUserId) {
    return _firestore.collection('chats').doc(currentUserId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return ChatStatus.pending;
      final data = doc.data() as Map<String, dynamic>;
      final chatData = data[targetUserId] as Map<String, dynamic>?;
      if (chatData == null) return ChatStatus.pending;

      return ChatStatus.values.firstWhere(
        (status) => status.name == chatData['status'],
        orElse: () => ChatStatus.pending,
      );
    });
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
  if (authUser == null) return Stream.value(ChatStatus.pending);

  return ref
      .read(chatRepositoryProvider)
      .getChatStatus(authUser.id, targetUserId);
});

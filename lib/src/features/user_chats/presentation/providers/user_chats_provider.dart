import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/user_chats/data/repositories/user_chats_repository.dart';
import 'package:wink_chat/src/features/user_chats/domain/models/active_chat.dart';
import 'package:wink_chat/src/features/user_chats/domain/models/chat_message.dart';

final activeChatsProvider = StreamProvider<List<ActiveChat>>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value([]);

  return ref.read(userChatsRepositoryProvider).getActiveChats(authUser.id);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  messageId,
) {
  return ref.read(userChatsRepositoryProvider).getChatMessages(messageId);
});

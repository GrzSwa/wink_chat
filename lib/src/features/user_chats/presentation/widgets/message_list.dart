import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/user_chats/presentation/providers/user_chats_provider.dart';
import 'package:wink_chat/src/features/user_chats/presentation/widgets/message_bubble.dart';

class MessageList extends ConsumerWidget {
  final String messageId;
  final String? currentUserId;
  final ScrollController scrollController;

  const MessageList({
    super.key,
    required this.messageId,
    required this.currentUserId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider(messageId));

    return messages.when(
      data: (messagesList) {
        if (messagesList.isEmpty) {
          return const Center(
            child: Text('Brak wiadomości. Rozpocznij rozmowę!'),
          );
        }

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          itemCount: messagesList.length,
          itemBuilder: (context, index) {
            final message = messagesList[index];
            final isMe = message.from == currentUserId;

            return MessageBubble(message: message.message, isMe: isMe);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Wystąpił błąd: $error')),
    );
  }
}

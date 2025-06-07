import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/user_chats/domain/models/active_chat.dart';
import 'package:wink_chat/src/features/user_chats/presentation/providers/user_chats_provider.dart';
import 'package:wink_chat/src/features/user_chats/presentation/screens/chat_messages_screen.dart';

class ChatListItem extends ConsumerWidget {
  final ActiveChat chat;

  const ChatListItem({super.key, required this.chat});

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Wczoraj';
    } else if (difference.inDays < 7) {
      final weekdays = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Niedz'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastMessage = ref.watch(chatMessagesProvider(chat.messageId));
    final currentUser = ref.watch(authStateProvider).value;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          chat.participantPseudonim[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    chat.participantPseudonim,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                lastMessage.when(
                  data: (messages) {
                    if (messages.isEmpty ||
                        messages.first.from == currentUser?.id) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          lastMessage.when(
            data: (messages) {
              if (messages.isEmpty) return const SizedBox.shrink();
              return Text(
                _formatDateTime(messages.first.time),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      subtitle: lastMessage.when(
        data: (messages) {
          if (messages.isEmpty) {
            return const Text('Brak wiadomości');
          }
          final isFromOther = messages.first.from != currentUser?.id;
          return Text(
            messages.first.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isFromOther ? Colors.black87 : Colors.grey,
              fontWeight: isFromOther ? FontWeight.w500 : FontWeight.normal,
            ),
          );
        },
        loading: () => const Text('Ładowanie...'),
        error: (error, _) => Text('Błąd: $error'),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatMessagesScreen(chat: chat),
          ),
        );
      },
    );
  }
}

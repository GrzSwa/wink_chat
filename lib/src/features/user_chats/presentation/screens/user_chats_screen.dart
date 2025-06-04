import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/user_chats/presentation/providers/user_chats_provider.dart';
import 'package:wink_chat/src/features/user_chats/presentation/screens/chat_messages_screen.dart';

class UserChatsScreen extends ConsumerWidget {
  const UserChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChats = ref.watch(activeChatsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Twoje Czaty'),
        backgroundColor: Colors.white,
      ),
      body: activeChats.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('Brak aktywnych rozmów'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final lastMessage = ref.watch(
                chatMessagesProvider(chat.messageId),
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    chat.participantPseudonim[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chat.participantPseudonim,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                    return Text(
                      messages.first.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
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
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Wystąpił błąd: $error')),
      ),
    );
  }

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
}

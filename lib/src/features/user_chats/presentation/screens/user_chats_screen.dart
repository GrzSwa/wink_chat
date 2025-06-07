import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/user_chats/presentation/providers/user_chats_provider.dart';
import 'package:wink_chat/src/features/user_chats/presentation/widgets/chat_list_item.dart';

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
              return ChatListItem(chat: chat);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Wystąpił błąd: $error')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/user_chats/domain/models/active_chat.dart';
import 'package:wink_chat/src/features/user_chats/presentation/widgets/message_input.dart';
import 'package:wink_chat/src/features/user_chats/presentation/widgets/message_list.dart';

class ChatMessagesScreen extends ConsumerStatefulWidget {
  final ActiveChat chat;

  const ChatMessagesScreen({super.key, required this.chat});

  @override
  ConsumerState<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends ConsumerState<ChatMessagesScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.participantPseudonim),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messageId: widget.chat.messageId,
              currentUserId: currentUser?.id,
              scrollController: _scrollController,
            ),
          ),
          MessageInput(
            messageId: widget.chat.messageId,
            participantId: widget.chat.participantId,
            scrollController: _scrollController,
          ),
        ],
      ),
    );
  }
}

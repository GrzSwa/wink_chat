import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';
import 'package:wink_chat/src/features/explore/presentation/providers/explore_provider.dart';
import 'package:wink_chat/src/features/explore/presentation/widgets/pending_chat_requests.dart';
import 'package:wink_chat/src/features/explore/presentation/widgets/user_list.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreUsersAsync = ref.watch(exploreUsersProvider);
    final location = ref.watch(userLocationProvider);
    final pendingRequests = ref.watch(pendingChatRequestsProvider);
    final currentUser = ref.watch(authStateProvider).value;

    Future<void> handleChatRequest(ExploreUser user) async {
      if (currentUser?.id == null) return;

      try {
        await ref
            .read(chatRepositoryProvider)
            .sendChatRequest(
              initiatorId: currentUser!.id,
              recipientId: user.id,
            );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Osoby w $location'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          pendingRequests.when(
            data:
                (requests) => PendingChatRequests(
                  requests: requests,
                  currentUserId: currentUser?.id ?? '',
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Wystąpił błąd: $error')),
          ),
          Expanded(
            child: exploreUsersAsync.when(
              data: (users) {
                final pendingUserIds = pendingRequests.when(
                  data:
                      (requests) =>
                          requests
                              .map((r) => r['initiatorId'] as String)
                              .toSet(),
                  loading: () => <String>{},
                  error: (_, __) => <String>{},
                );

                return UserList(
                  users: users,
                  pendingUserIds: pendingUserIds,
                  currentUserId: currentUser?.id,
                  onChatRequest: handleChatRequest,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) =>
                      Center(child: Text('Wystąpił błąd: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

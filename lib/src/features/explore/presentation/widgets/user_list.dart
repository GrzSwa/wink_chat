import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';
import 'package:wink_chat/src/features/explore/presentation/providers/explore_provider.dart';
import 'package:wink_chat/src/features/explore/presentation/widgets/user_list_tile.dart';

class UserList extends ConsumerWidget {
  final List<ExploreUser> users;
  final Set<String> pendingUserIds;
  final String? currentUserId;

  const UserList({
    super.key,
    required this.users,
    required this.pendingUserIds,
    required this.currentUserId,
  });

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Teraz';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min temu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} godz temu';
    } else {
      return '${difference.inDays} dni temu';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter out current user and users with pending requests
    final filteredUsers =
        users
            .where(
              (user) =>
                  user.id != currentUserId && !pendingUserIds.contains(user.id),
            )
            .toList();

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text('Brak aktywnych użytkowników w Twojej lokalizacji'),
      );
    }

    // Create a map to store user statuses to avoid multiple reads
    final userStatuses = Map.fromEntries(
      filteredUsers.map((user) {
        final status =
            ref.read(chatStatusProvider(user.id)).value ?? ChatStatus.none;
        return MapEntry(user.id, status);
      }),
    );

    // Sort users based on their status
    filteredUsers.sort((a, b) {
      final statusA = userStatuses[a.id] ?? ChatStatus.none;
      final statusB = userStatuses[b.id] ?? ChatStatus.none;

      // Helper function to get priority (lower number = higher priority)
      int getPriority(ChatStatus status) {
        switch (status) {
          case ChatStatus.none:
            return 0;
          case ChatStatus.pending:
            return 1;
          case ChatStatus.active:
            return 2;
          case ChatStatus.rejected:
            return 3;
          case ChatStatus.ended:
            return 4;
        }
      }

      return getPriority(statusA).compareTo(getPriority(statusB));
    });

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(exploreUsersProvider);
      },
      child: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          final chatStatus = ref.watch(chatStatusProvider(user.id));

          return chatStatus.when(
            data: (status) {
              // Check if we need to add a separator
              if (index > 0) {
                final previousStatus =
                    userStatuses[filteredUsers[index - 1].id];
                final currentHasStatus = status != ChatStatus.none;
                final previousHasStatus = previousStatus != ChatStatus.none;

                if (currentHasStatus && !previousHasStatus) {
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Divider(thickness: 1),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          'Ostatnie prośby o rozmowę',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      UserListTile(
                        user: user,
                        status: status,
                        lastSeenFormatted: _formatLastSeen(user.lastSeen),
                      ),
                    ],
                  );
                }
              }

              return UserListTile(
                user: user,
                status: status,
                lastSeenFormatted: _formatLastSeen(user.lastSeen),
              );
            },
            loading:
                () => const ListTile(
                  leading: CircleAvatar(),
                  title: Text('Ładowanie...'),
                ),
            error:
                (_, __) => UserListTile(
                  user: user,
                  status: ChatStatus.none,
                  lastSeenFormatted: _formatLastSeen(user.lastSeen),
                ),
          );
        },
      ),
    );
  }
}

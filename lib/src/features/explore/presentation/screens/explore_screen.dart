import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wink_chat/src/features/explore/presentation/providers/explore_provider.dart';
import 'package:wink_chat/src/features/chat/presentation/screens/chat_request_screen.dart';
import 'package:wink_chat/src/features/chat/data/repositories/chat_repository.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreUsersAsync = ref.watch(exploreUsersProvider);
    final location = ref.watch(userLocationProvider);
    final pendingRequests = ref.watch(pendingChatRequestsProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Osoby w $location'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Pending chat requests section
          pendingRequests.when(
            data: (requests) {
              if (requests.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Otrzymane prośby o rozmowę',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ...requests.map((request) {
                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(request['initiatorId'])
                                .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(),
                                title: Text('Ładowanie...'),
                              ),
                            );
                          }

                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          final pseudonim =
                              userData?['pseudonim'] ?? 'Nieznany użytkownik';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(pseudonim[0].toUpperCase()),
                              ),
                              title: Text(pseudonim),
                              subtitle: Text(
                                'Wysłano: ${_formatLastSeen((request['createdAt'] as Timestamp).toDate())}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async {
                                      if (currentUser == null) return;

                                      try {
                                        await ref
                                            .read(chatRepositoryProvider)
                                            .respondToChatRequest(
                                              currentUserId: currentUser.id,
                                              initiatorId:
                                                  request['initiatorId'],
                                              accepted: true,
                                            );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Wystąpił błąd: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      if (currentUser == null) return;

                                      try {
                                        await ref
                                            .read(chatRepositoryProvider)
                                            .respondToChatRequest(
                                              currentUserId: currentUser.id,
                                              initiatorId:
                                                  request['initiatorId'],
                                              accepted: false,
                                            );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Wystąpił błąd: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Wystąpił błąd: $error')),
          ),
          // Existing users list
          Expanded(
            child: exploreUsersAsync.when(
              data: (users) {
                // Get list of users with pending requests
                final pendingUserIds = pendingRequests.when(
                  data:
                      (requests) =>
                          requests
                              .map((r) => r['initiatorId'] as String)
                              .toSet(),
                  loading: () => <String>{},
                  error: (_, __) => <String>{},
                );

                // Filter out current user and users with pending requests
                final filteredUsers =
                    users
                        .where(
                          (user) =>
                              user.id != currentUser?.id &&
                              !pendingUserIds.contains(user.id),
                        )
                        .toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      'Brak aktywnych użytkowników w Twojej lokalizacji',
                    ),
                  );
                }

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
                        data:
                            (status) => ListTile(
                              leading: CircleAvatar(
                                child: Text(user.pseudonim[0].toUpperCase()),
                              ),
                              title: Text(user.pseudonim),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ostatnio aktywny: ${_formatLastSeen(user.lastSeen)}',
                                  ),
                                  Text(
                                    _getStatusText(status),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                user.gender == 'M' ? Icons.male : Icons.female,
                                color:
                                    user.gender == 'M'
                                        ? Colors.blue
                                        : Colors.pink,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ChatRequestScreen(user: user),
                                  ),
                                );
                              },
                            ),
                        loading:
                            () => const ListTile(
                              leading: CircleAvatar(),
                              title: Text('Ładowanie...'),
                            ),
                        error:
                            (_, __) => ListTile(
                              leading: CircleAvatar(
                                child: Text(user.pseudonim[0].toUpperCase()),
                              ),
                              title: Text(user.pseudonim),
                              subtitle: Text(
                                'Ostatnio aktywny: ${_formatLastSeen(user.lastSeen)}',
                              ),
                              trailing: Icon(
                                user.gender == 'M' ? Icons.male : Icons.female,
                                color:
                                    user.gender == 'M'
                                        ? Colors.blue
                                        : Colors.pink,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ChatRequestScreen(user: user),
                                  ),
                                );
                              },
                            ),
                      );
                    },
                  ),
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

  String _getStatusText(ChatStatus status) {
    switch (status) {
      case ChatStatus.none:
        return '';
      case ChatStatus.pending:
        return 'Wysłano prośbę o rozmowę.';
      case ChatStatus.active:
        return 'Rozmowa została zaakceptowana!';
      case ChatStatus.rejected:
        return 'Rozmowa została odrzucona!';
      case ChatStatus.ended:
        return 'Ta rozmowa została zakończona.';
    }
  }

  Color _getStatusColor(ChatStatus status) {
    switch (status) {
      case ChatStatus.none:
        return Colors.black;
      case ChatStatus.pending:
        return Colors.blue;
      case ChatStatus.active:
        return Colors.green;
      case ChatStatus.rejected:
        return Colors.red;
      case ChatStatus.ended:
        return Colors.grey;
    }
  }

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
}

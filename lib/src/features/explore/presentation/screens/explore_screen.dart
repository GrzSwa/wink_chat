import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/explore/presentation/providers/explore_provider.dart';
import 'package:wink_chat/src/features/chat/presentation/screens/chat_request_screen.dart';
import 'package:wink_chat/src/features/chat/data/repositories/chat_repository.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreUsersAsync = ref.watch(exploreUsersProvider);
    final location = ref.watch(userLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Osoby w $location'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: exploreUsersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text('Brak aktywnych użytkowników w Twojej lokalizacji'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(exploreUsersProvider);
            },
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
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
                          color: user.gender == 'M' ? Colors.blue : Colors.pink,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatRequestScreen(user: user),
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
                          color: user.gender == 'M' ? Colors.blue : Colors.pink,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatRequestScreen(user: user),
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
            (error, stackTrace) => Center(child: Text('Wystąpił błąd: $error')),
      ),
    );
  }

  String _getStatusText(ChatStatus status) {
    switch (status) {
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

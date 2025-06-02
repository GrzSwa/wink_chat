import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/explore/presentation/providers/explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreUsersAsync = ref.watch(exploreUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Osoby w pobliżu')),
      body: exploreUsersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text('Brak aktywnych użytkowników w Twojej lokalizacji'),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
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
                  // TODO: Navigate to chat with selected user
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(child: Text('Wystąpił błąd: $error')),
      ),
    );
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

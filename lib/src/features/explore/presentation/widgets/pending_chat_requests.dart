import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';

class PendingChatRequests extends ConsumerWidget {
  final List<Map<String, dynamic>> requests;
  final String currentUserId;

  const PendingChatRequests({
    super.key,
    required this.requests,
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
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Otrzymane prośby o rozmowę',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

                final userData = snapshot.data!.data() as Map<String, dynamic>?;
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
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(chatRepositoryProvider)
                                  .respondToChatRequest(
                                    currentUserId: currentUserId,
                                    initiatorId: request['initiatorId'],
                                    accepted: true,
                                  );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Wystąpił błąd: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(chatRepositoryProvider)
                                  .respondToChatRequest(
                                    currentUserId: currentUserId,
                                    initiatorId: request['initiatorId'],
                                    accepted: false,
                                  );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Wystąpił błąd: $e'),
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
  }
}

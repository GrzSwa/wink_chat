import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';

class ChatRequestScreen extends ConsumerWidget {
  final ExploreUser user;

  const ChatRequestScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStatus = ref.watch(chatStatusProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(user.pseudonim),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: chatStatus.when(
        data:
            (status) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getStatusMessage(status),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (status == ChatStatus.active) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to chat screen
                        Navigator.pop(context);
                      },
                      child: const Text('Przejdź do rozmowy'),
                    ),
                  ],
                  if (status == ChatStatus.none) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final authUser = ref.read(authStateProvider).value;
                        if (authUser == null) return;

                        try {
                          await ref
                              .read(chatRepositoryProvider)
                              .createChatRequest(
                                currentUserId: authUser.id,
                                targetUserId: user.id,
                              );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Prośba o rozmowę została wysłana',
                                ),
                              ),
                            );
                          }
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
                      child: const Text('Wyślij'),
                    ),
                  ],
                  if (status == ChatStatus.pending) ...[
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Wystąpił błąd: $error')),
      ),
    );
  }

  String _getStatusMessage(ChatStatus status) {
    switch (status) {
      case ChatStatus.none:
        return 'Wyślij prośbę o nawiązanie rozmowy';
      case ChatStatus.pending:
        return 'Wysłano prośbę o rozmowę.\nCzekaj na odpowiedź użytkownika.';
      case ChatStatus.active:
        return 'Rozmowa została zaakceptowana!\nPrzejdź do czatu, aby rozpocząć rozmowę.';
      case ChatStatus.rejected:
        return 'Użytkownik odrzucił Twoją prośbę o rozmowę.';
      case ChatStatus.ended:
        return 'Ta rozmowa została zakończona.';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/welcome_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ekran Konto'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed:
                  authState.isLoading ? null : () => _logout(context, ref),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Wyloguj'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/account/providers/user_provider.dart';
import 'package:wink_chat/src/features/account/presentation/widgets/account_avatar.dart';
import 'package:wink_chat/src/features/account/presentation/widgets/user_info_badges.dart';
import 'package:wink_chat/src/features/account/presentation/widgets/privacy_info_card.dart';
import 'package:wink_chat/src/features/account/presentation/widgets/location_settings_tile.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/welcome_screen.dart';

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
    final userAsyncValue = ref.watch(userStreamProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konto'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: authState.isLoading ? null : () => _logout(context, ref),
            child:
                authState.isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text(
                      'Wyloguj',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: userAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Błąd: $error')),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Nie znaleziono danych użytkownika'),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  AccountAvatar(pseudonym: user.pseudonim),
                  const SizedBox(height: 16),
                  Text(
                    user.pseudonim,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  UserInfoBadges(gender: user.gender, location: user.location),
                  const SizedBox(height: 24),
                  const PrivacyInfoCard(),
                  const SizedBox(height: 24),
                  LocationSettingsTile(currentLocation: user.location.value),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

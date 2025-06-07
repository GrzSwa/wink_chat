import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/welcome_screen.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/account/providers/user_provider.dart';
import 'package:wink_chat/src/features/account/domain/user.dart';
import 'package:wink_chat/src/features/account/providers/locations_provider.dart';

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

  String _getGenderDisplay(String gender) {
    return gender == 'M' ? 'Mężczyzna' : 'Kobieta';
  }

  Future<void> _showLocationChangeDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLocation,
  ) async {
    String? selectedLocation;

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zmień lokalizację'),
          content: Consumer(
            builder: (context, ref, child) {
              final locationsAsync = ref.watch(availableLocationsProvider);

              return locationsAsync.when(
                data:
                    (locations) => DropdownButton<String>(
                      value: selectedLocation ?? currentLocation,
                      isExpanded: true,
                      items:
                          locations.map((String location) {
                            return DropdownMenuItem<String>(
                              value: location,
                              child: Text(location),
                            );
                          }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          selectedLocation = value;
                          Navigator.of(context).pop(value);
                        }
                      },
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (_, __) => const Text(
                      'Nie udało się załadować lokalizacji',
                      style: TextStyle(color: Colors.red),
                    ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
          ],
        );
      },
    );

    if (result != null && context.mounted) {
      final locationType = ref.read(locationTypeProvider(result));
      await ref
          .read(userRepositoryProvider)
          .updateUserLocation(
            ref.read(authStateProvider).value!.id,
            UserLocation(type: locationType, value: result),
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userAsyncValue = ref.watch(userStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
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
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user.pseudonim[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username
                  Text(
                    user.pseudonim,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gender Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(_getGenderDisplay(user.gender)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Location Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(user.location.value),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Privacy Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Twój pseudonim i płeć są widoczne dla innych. Twoje prawdziwe dane są chronione.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Location Settings
                  ListTile(
                    leading: const Icon(Icons.edit_location),
                    title: const Text('Zmień lokalizację'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap:
                        () => _showLocationChangeDialog(
                          context,
                          ref,
                          user.location.value,
                        ),
                  ),
                  const Divider(),
                  const SizedBox(height: 32),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          authState.isLoading
                              ? null
                              : () => _logout(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          authState.isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                'Wyloguj',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

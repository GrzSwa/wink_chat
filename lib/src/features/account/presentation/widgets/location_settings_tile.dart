import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/account/providers/locations_provider.dart';
import 'package:wink_chat/src/features/account/domain/user.dart';
import 'package:wink_chat/src/features/account/providers/user_provider.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/common/widgets/field.dart';

class LocationSettingsTile extends ConsumerWidget {
  final String currentLocation;

  const LocationSettingsTile({super.key, required this.currentLocation});

  Future<void> _updateLocation(
    BuildContext context,
    WidgetRef ref,
    String newLocation,
  ) async {
    try {
      final locationsListAsync = ref.read(locationsListProvider);
      final userId = ref.read(authStateProvider).value?.id;

      if (userId == null) return;

      final locationsList = locationsListAsync.value;
      if (locationsList == null) {
        throw Exception('Nie udało się załadować konfiguracji lokalizacji');
      }

      final locationType = locationsList.getLocationType(newLocation);

      // Pokazujemy loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Aktualizacja lokalizacji...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      await ref
          .read(userRepositoryProvider)
          .updateUserLocation(
            userId,
            UserLocation(type: locationType, value: newLocation),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokalizacja została zaktualizowana'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nie udało się zaktualizować lokalizacji'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(availableLocationsProvider);

    return locationsAsync.when(
      data:
          (locations) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Field.select(
              label: 'Lokalizacja',
              options: locations,
              selectedValue: currentLocation,
              onChanged: (value) => _updateLocation(context, ref, value),
            ),
          ),
      loading:
          () => const ListTile(
            leading: Icon(Icons.edit_location),
            title: Text('Ładowanie lokalizacji...'),
            trailing: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      error:
          (_, __) => ListTile(
            leading: const Icon(Icons.error),
            title: const Text('Nie udało się załadować lokalizacji'),
            textColor: Colors.red,
          ),
    );
  }
}

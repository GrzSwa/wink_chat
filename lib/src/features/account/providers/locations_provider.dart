import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/account/data/locations_repository.dart';
import 'package:wink_chat/src/features/account/domain/location.dart';

final locationsRepositoryProvider = Provider<LocationsRepository>((ref) {
  return LocationsRepository();
});

final locationsListProvider = FutureProvider<LocationsList>((ref) async {
  final repository = ref.watch(locationsRepositoryProvider);
  return repository.getLocations();
});

final availableLocationsProvider = FutureProvider<List<String>>((ref) async {
  final locationsList = await ref.watch(locationsListProvider.future);
  return locationsList.getAllLocations();
});

final locationTypeProvider = Provider.family<String, String>((
  ref,
  locationValue,
) {
  final locationsList = ref.watch(locationsListProvider).value;
  if (locationsList == null)
    throw Exception('Lokalizacje nie zostały załadowane');
  return locationsList.getLocationType(locationValue);
});

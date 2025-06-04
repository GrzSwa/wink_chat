import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/auth/data/repositories/locations_repository.dart';

final locationsRepositoryProvider = Provider<LocationsRepository>((ref) {
  return LocationsRepository();
});

final locationsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(locationsRepositoryProvider);
  return repository.getAllLocations();
});

final locationTypeProvider = FutureProvider.family<String, String>((
  ref,
  locationValue,
) async {
  final repository = ref.watch(locationsRepositoryProvider);
  return repository.getLocationType(locationValue);
});

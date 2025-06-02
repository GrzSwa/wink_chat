import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:wink_chat/src/features/explore/data/repositories/explore_repository.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository();
});

final userLocationProvider = StateProvider<String>((ref) {
  // TODO: Get user's location from their profile
  // For now, we'll use a default location
  return 'Polska';
});

final exploreUsersProvider = StreamProvider<List<ExploreUser>>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value([]);

  final exploreRepository = ref.watch(exploreRepositoryProvider);
  final locationValue = ref.watch(userLocationProvider);

  return exploreRepository.getUsersInLocation(locationValue, authUser.id);
});

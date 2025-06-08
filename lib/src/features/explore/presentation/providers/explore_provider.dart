import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/explore/data/repositories/explore_repository.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';
import 'package:wink_chat/src/features/account/providers/user_provider.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository();
});

final userLocationProvider = StateProvider<String>((ref) {
  final userLocation = ref.watch(userStreamProvider).value?.location;
  return userLocation?.value ?? '';
});

final exploreUsersProvider = StreamProvider<List<ExploreUser>>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) {
    return Stream.value([]);
  }

  final user = ref.watch(userStreamProvider).value;
  final locationValue = user?.location.value;

  if (locationValue == null || locationValue.isEmpty) {
    return Stream.value([]);
  }

  final exploreRepository = ref.watch(exploreRepositoryProvider);
  return exploreRepository.getUsersInLocation(locationValue, authUser.id);
});

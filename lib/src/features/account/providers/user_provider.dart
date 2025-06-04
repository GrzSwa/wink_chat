import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/account/data/user_repository.dart';
import 'package:wink_chat/src/features/account/domain/user.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userStreamProvider = StreamProvider.autoDispose<User?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  final repository = ref.watch(userRepositoryProvider);

  if (authUser == null) return Stream.value(null);

  return repository.getUserStream(authUser.id);
});

final userLocationProvider = Provider.autoDispose<UserLocation?>((ref) {
  return ref.watch(userStreamProvider).whenData((user) => user?.location).value;
});

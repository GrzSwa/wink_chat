import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/domain/repositories/auth_repository.dart';
import 'package:wink_chat/src/common/data/repositories/firebase_auth_repository.dart';

/// Provider repozytorium autoryzacji specyficzny dla feature auth
final authFeatureRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Provider kontrolera autoryzacji dla feature auth
final authFeatureControllerProvider =
    StateNotifierProvider<AuthFeatureController, AsyncValue<void>>((ref) {
      final authRepository = ref.watch(authFeatureRepositoryProvider);
      return AuthFeatureController(authRepository);
    });

/// Kontroler specyficzny dla feature auth - zawiera tylko operacje potrzebne w tym feature
class AuthFeatureController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthFeatureController(this._authRepository)
    : super(const AsyncValue.data(null));

  Future<AsyncValue<void>> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signUp(email: email, password: password);
    });
    return state;
  }

  Future<AsyncValue<void>> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signIn(email: email, password: password);
    });
    return state;
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
    });
  }
}

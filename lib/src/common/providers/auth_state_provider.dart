import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/services/auth_service.dart';
import 'package:wink_chat/src/common/domain/models/auth_user.dart';

/// Globalny provider stanu autoryzacji dostępny dla wszystkich feature'ów
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider kontrolera autoryzacji dla operacji współdzielonych
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final authService = ref.watch(authServiceProvider);
      return AuthController(authService);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AsyncValue.data(null));

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signOut();
    });
  }
}

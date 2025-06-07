import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/data/repositories/firebase_auth_repository.dart';
import 'package:wink_chat/src/common/domain/models/auth_user.dart';
import 'package:wink_chat/src/common/domain/repositories/auth_repository.dart';

/// Provider serwisu autoryzacji
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuthRepository());
});

/// Serwis autoryzacji dostępny dla wszystkich feature'ów
class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  /// Stream zmian stanu autoryzacji
  Stream<AuthUser?> get authStateChanges => _authRepository.authStateChanges;

  /// Wylogowanie użytkownika
  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  /// Pobranie aktualnego użytkownika
  AuthUser? get currentUser => _authRepository.currentUser;
}

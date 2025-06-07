import 'package:wink_chat/src/common/domain/models/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> signUp({required String email, required String password});

  Future<AuthUser> signIn({required String email, required String password});

  Future<void> signOut();

  AuthUser? get currentUser;
}

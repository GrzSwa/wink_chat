import 'package:firebase_auth/firebase_auth.dart';
import 'package:wink_chat/src/features/auth/domain/models/auth_user.dart';
import 'package:wink_chat/src/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUser.fromFirebase(user);
    });
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthUser.fromFirebase(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthUser.fromFirebase(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('Ten adres email jest już używany');
      case 'invalid-email':
        return Exception('Nieprawidłowy adres email');
      case 'operation-not-allowed':
        return Exception('Operacja niedozwolona');
      case 'weak-password':
        return Exception('Hasło jest zbyt słabe');
      case 'user-disabled':
        return Exception('Konto zostało wyłączone');
      case 'user-not-found':
        return Exception('Nie znaleziono użytkownika');
      case 'wrong-password':
        return Exception('Nieprawidłowe hasło');
      default:
        return Exception('Wystąpił nieznany błąd');
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String id;
  final String email;

  AuthUser({required this.id, required this.email});

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(id: user.uid, email: user.email ?? '');
  }
}

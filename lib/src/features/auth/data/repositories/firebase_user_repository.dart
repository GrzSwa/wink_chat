import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wink_chat/src/features/auth/domain/models/auth_user.dart';

class FirebaseUserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required AuthUser authUser,
    required String pseudonim,
    required String gender,
    required Map<String, String> location,
  }) async {
    final now = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(authUser.id).set({
      'uid': authUser.id,
      'pseudonim': pseudonim,
      'gender': gender,
      'location': location,
      'lastSeen': now,
      'createdAt': now,
      'updatedAt': now,
    });
  }
}

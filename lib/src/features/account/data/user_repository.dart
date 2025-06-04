import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wink_chat/src/features/account/domain/user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc) : null);
  }

  Future<void> updateUserLocation(String uid, UserLocation location) async {
    await _firestore.collection('users').doc(uid).update({
      'location': location.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

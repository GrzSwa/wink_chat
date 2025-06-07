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
    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      transaction.update(userRef, {
        'location': location.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

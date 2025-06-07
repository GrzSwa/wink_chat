import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wink_chat/src/common/domain/models/auth_user.dart';

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

    // Create user profile in users collection
    await _firestore.collection('users').doc(authUser.id).set({
      'uid': authUser.id,
      'pseudonim': pseudonim,
      'gender': gender,
      'location': location,
      'lastSeen': now,
      'createdAt': now,
      'updatedAt': now,
    });

    // Add user to explore collection based on their location
    final locationDoc = _firestore.collection('explore').doc(location['value']);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(locationDoc);

      if (docSnapshot.exists) {
        // Update existing document
        final currentActiveUsers = List<String>.from(
          docSnapshot.data()?['activeUsers'] ?? [],
        );
        if (!currentActiveUsers.contains(authUser.id)) {
          currentActiveUsers.add(authUser.id);
          transaction.update(locationDoc, {'activeUsers': currentActiveUsers});
        }
      } else {
        // Create new document
        transaction.set(locationDoc, {
          'type': location['type'],
          'activeUsers': [authUser.id],
        });
      }
    });
  }
}

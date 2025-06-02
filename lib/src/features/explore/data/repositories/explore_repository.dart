import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';

class ExploreRepository {
  final FirebaseFirestore _firestore;

  ExploreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ExploreUser>> getUsersInLocation(
    String locationValue,
    String currentUserId,
  ) {
    return _firestore
        .collection('explore')
        .doc(locationValue)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) return [];

          final activeUsers = List<String>.from(
            doc.data()?['activeUsers'] ?? [],
          );
          // Remove current user from the list
          activeUsers.remove(currentUserId);

          if (activeUsers.isEmpty) return [];

          final usersSnapshot =
              await _firestore
                  .collection('users')
                  .where('uid', whereIn: activeUsers)
                  .get();

          return usersSnapshot.docs
              .map((doc) => ExploreUser.fromFirestore(doc))
              .toList();
        });
  }
}

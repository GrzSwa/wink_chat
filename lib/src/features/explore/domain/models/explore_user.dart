import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreUser {
  final String id;
  final String pseudonim;
  final String gender;
  final Map<String, String> location;
  final DateTime lastSeen;

  const ExploreUser({
    required this.id,
    required this.pseudonim,
    required this.gender,
    required this.location,
    required this.lastSeen,
  });

  factory ExploreUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExploreUser(
      id: doc.id,
      pseudonim: data['pseudonim'] as String,
      gender: data['gender'] as String,
      location: Map<String, String>.from(data['location'] as Map),
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
    );
  }
}

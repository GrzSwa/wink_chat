import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserLocation {
  final String type;
  final String value;

  const UserLocation({required this.type, required this.value});

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      type: map['type'] as String,
      value: map['value'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'type': type, 'value': value};
  }
}

class User extends Equatable {
  final String uid;
  final String pseudonim;
  final String gender;
  final UserLocation location;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.uid,
    required this.pseudonim,
    required this.gender,
    required this.location,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Bezpieczna konwersja timestampów
    DateTime safeTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) return timestamp.toDate();
      return DateTime.now();
    }

    return User(
      uid: doc.id,
      pseudonim: data['pseudonim'] as String,
      gender: data['gender'] as String,
      location: UserLocation.fromMap(data['location'] as Map<String, dynamic>),
      lastSeen: safeTimestamp(data['lastSeen']),
      createdAt: safeTimestamp(data['createdAt']),
      updatedAt: safeTimestamp(data['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
    uid,
    pseudonim,
    gender,
    location,
    lastSeen,
    createdAt,
    updatedAt,
  ];
}

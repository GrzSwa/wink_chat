import 'package:cloud_firestore/cloud_firestore.dart';

class LocationsRepository {
  final FirebaseFirestore _firestore;

  LocationsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<String>> getAllLocations() async {
    final querySnapshot =
        await _firestore.collection('locations').limit(1).get();
    if (querySnapshot.docs.isEmpty) return [];

    final data = querySnapshot.docs.first.data();
    final List<String> allLocations = [];

    // Add cities
    allLocations.addAll(List<String>.from(data['city'] ?? []));
    // Add voivodeships
    allLocations.addAll(List<String>.from(data['voivodeship'] ?? []));
    // Add countries
    allLocations.addAll(List<String>.from(data['country'] ?? []));

    return allLocations;
  }

  Future<String> getLocationType(String locationValue) async {
    final querySnapshot =
        await _firestore.collection('locations').limit(1).get();
    if (querySnapshot.docs.isEmpty) return 'country'; // Default fallback

    final data = querySnapshot.docs.first.data();

    if (List<String>.from(data['city'] ?? []).contains(locationValue)) {
      return 'city';
    }
    if (List<String>.from(data['voivodeship'] ?? []).contains(locationValue)) {
      return 'voivodeship';
    }
    if (List<String>.from(data['country'] ?? []).contains(locationValue)) {
      return 'country';
    }

    return 'country'; // Default fallback
  }
}

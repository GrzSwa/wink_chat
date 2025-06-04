import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wink_chat/src/features/account/domain/location.dart';

class LocationsRepository {
  final FirebaseFirestore _firestore;

  LocationsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<LocationsList> getLocations() async {
    final querySnapshot =
        await _firestore.collection('locations').limit(1).get();
    if (querySnapshot.docs.isEmpty) {
      throw Exception('Nie znaleziono konfiguracji lokalizacji');
    }
    return LocationsList.fromFirestore(querySnapshot.docs.first);
  }
}

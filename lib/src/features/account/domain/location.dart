import 'package:cloud_firestore/cloud_firestore.dart';

class LocationsList {
  final List<String> city;
  final List<String> voivodeship;
  final List<String> country;

  const LocationsList({
    required this.city,
    required this.voivodeship,
    required this.country,
  });

  factory LocationsList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LocationsList(
      city: List<String>.from(data['city'] as List),
      voivodeship: List<String>.from(data['voivodeship'] as List),
      country: List<String>.from(data['country'] as List),
    );
  }

  List<String> getAllLocations() {
    return [...country, ...voivodeship, ...city];
  }

  String getLocationType(String locationValue) {
    if (country.contains(locationValue)) return 'country';
    if (voivodeship.contains(locationValue)) return 'voivodeship';
    if (city.contains(locationValue)) return 'city';
    throw Exception('Nieprawidłowa lokalizacja');
  }
}

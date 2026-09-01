import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryLocation {
  const DeliveryLocation(
      {required this.id,
      required this.city,
      required this.district,
      required this.state,
      required this.country,
      required this.isActive});
  final String id;
  final String city;
  final String district;
  final String state;
  final String country;
  final bool isActive;
  String get displayName => '$city, $state';
  factory DeliveryLocation.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return DeliveryLocation(
        id: document.id,
        city: data['city'] as String? ?? '',
        district: data['district'] as String? ?? '',
        state: data['state'] as String? ?? '',
        country: data['country'] as String? ?? 'India',
        isActive: data['active'] as bool? ?? false);
  }
}

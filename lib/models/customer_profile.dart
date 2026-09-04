import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfile {
  const CustomerProfile({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.phoneVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String name;
  final String phoneNumber;
  final bool phoneVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CustomerProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    return CustomerProfile(
      uid: document.id,
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

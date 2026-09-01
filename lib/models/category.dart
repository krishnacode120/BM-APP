import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  const Category(
      {required this.id,
      required this.name,
      required this.nameTamil,
      required this.description,
      required this.descriptionTamil,
      required this.imageUrl,
      required this.sortOrder,
      required this.isActive,
      this.createdAt,
      this.updatedAt});
  final String id;
  final String name;
  final String nameTamil;
  final String description;
  final String descriptionTamil;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  String localizedName(String languageCode) =>
      languageCode == 'ta' && nameTamil.isNotEmpty ? nameTamil : name;
  String localizedDescription(String languageCode) =>
      languageCode == 'ta' && descriptionTamil.isNotEmpty
          ? descriptionTamil
          : description;
  factory Category.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Category(
        id: document.id,
        name: data['name'] as String? ?? '',
        nameTamil: data['nameTamil'] as String? ?? '',
        description: data['description'] as String? ?? '',
        descriptionTamil: data['descriptionTamil'] as String? ?? '',
        imageUrl: data['imageUrl'] as String?,
        sortOrder: (data['sortOrder'] as num? ?? 0).toInt(),
        isActive: data['isActive'] as bool? ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate());
  }
}

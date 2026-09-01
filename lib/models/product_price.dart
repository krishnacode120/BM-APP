import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPrice {
  const ProductPrice(
      {required this.id,
      required this.productId,
      required this.locationId,
      required this.price,
      required this.effectiveFrom,
      this.effectiveTo,
      this.updatedAt,
      this.updatedBy});
  final String id;
  final String productId;
  final String locationId;
  final num price;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime? updatedAt;
  final String? updatedBy;
  bool appliesAt(DateTime time) =>
      !effectiveFrom.isAfter(time) &&
      (effectiveTo == null || effectiveTo!.isAfter(time));
  factory ProductPrice.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ProductPrice(
        id: document.id,
        productId: data['productId'] as String? ?? '',
        locationId: data['locationId'] as String? ?? '',
        price: data['price'] as num? ?? 0,
        effectiveFrom: ((data['effectiveFrom'] as Timestamp?)?.toDate()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        effectiveTo: (data['effectiveTo'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        updatedBy: data['updatedBy'] as String?);
  }
}

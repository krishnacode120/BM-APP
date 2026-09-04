import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart';

enum OrderStatus {
  pending,
  verified,
  confirmed,
  processing,
  ready,
  completed,
  cancelled
}

enum PaymentStatus { unpaid, partial, paid }

OrderStatus orderStatusFromValue(String? value) {
  final normalized = switch (value) {
    'delivered' || 'outForDelivery' => 'completed',
    _ => value,
  };
  return OrderStatus.values.firstWhere((status) => status.name == normalized,
      orElse: () => OrderStatus.pending);
}

PaymentStatus paymentStatusFromValue(String? value) {
  final normalized = switch (value) {
    'verified' => 'paid',
    'pending' ||
    'verificationRequired' ||
    'failed' ||
    'refunded' ||
    'notRequired' =>
      'unpaid',
    _ => value,
  };
  return PaymentStatus.values.firstWhere((status) => status.name == normalized,
      orElse: () => PaymentStatus.unpaid);
}

class OrderItemSnapshot {
  const OrderItemSnapshot(
      {required this.productId,
      required this.productName,
      required this.productNameTamil,
      required this.unit,
      required this.quantity,
      required this.priceAtOrder,
      required this.subtotal,
      required this.locationId,
      this.imageUrl});
  final String productId;
  final String productName;
  final String productNameTamil;
  final ProductUnit unit;
  final int quantity;
  final num priceAtOrder;
  final num subtotal;
  final String locationId;
  final String? imageUrl;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'productId': productId,
        'productName': productName,
        'productNameTamil': productNameTamil,
        'unit': unit.name,
        'quantity': quantity,
        'priceAtOrder': priceAtOrder,
        'subtotal': subtotal,
        'locationId': locationId,
        'imageUrl': imageUrl,
      };
  factory OrderItemSnapshot.fromJson(Map<String, dynamic> json) =>
      OrderItemSnapshot(
        productId: json['productId'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        productNameTamil: json['productNameTamil'] as String? ?? '',
        unit: productUnitFromValue(json['unit'] as String?),
        quantity: (json['quantity'] as num? ?? 0).toInt(),
        priceAtOrder: json['priceAtOrder'] as num? ?? 0,
        subtotal: json['subtotal'] as num? ?? 0,
        locationId: json['locationId'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
      );
}

class BmOrder {
  const BmOrder(
      {required this.id,
      required this.orderNumber,
      required this.userId,
      required this.customerName,
      required this.phoneNumber,
      required this.deliveryAddress,
      required this.locationId,
      required this.locationName,
      required this.items,
      required this.estimatedSubtotal,
      required this.orderStatus,
      required this.paymentStatus,
      required this.createdAt,
      required this.updatedAt,
      this.customerNote,
      this.adminNote,
      this.confirmedSubtotal,
      this.deliveryCharge = 0,
      this.finalTotal,
      this.verifiedAt,
      this.verifiedBy,
      this.paymentUpdatedAt,
      this.paymentUpdatedBy});
  final String id;
  final String orderNumber;
  final String userId;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final String locationId;
  final String locationName;
  final List<OrderItemSnapshot> items;
  final num estimatedSubtotal;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? customerNote;
  final String? adminNote;
  final num? confirmedSubtotal;
  final num deliveryCharge;
  final num? finalTotal;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final DateTime? paymentUpdatedAt;
  final String? paymentUpdatedBy;
  num get displayTotal => finalTotal ?? estimatedSubtotal;
  num get recognizedRevenue => paymentStatus == PaymentStatus.paid &&
          orderStatus != OrderStatus.cancelled
      ? displayTotal
      : 0;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'orderNumber': orderNumber,
        'userId': userId,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'deliveryAddress': deliveryAddress,
        'locationId': locationId,
        'locationName': locationName,
        'items': items.map((item) => item.toJson()).toList(),
        'estimatedSubtotal': estimatedSubtotal,
        'orderStatus': orderStatus.name,
        'paymentStatus': paymentStatus.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'customerNote': customerNote,
        'adminNote': adminNote,
        'confirmedSubtotal': confirmedSubtotal,
        'deliveryCharge': deliveryCharge,
        'finalTotal': finalTotal,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'verifiedBy': verifiedBy,
        'paymentUpdatedAt': paymentUpdatedAt?.toIso8601String(),
        'paymentUpdatedBy': paymentUpdatedBy,
      };
  factory BmOrder.fromJson(Map<String, dynamic> json, {String? id}) => BmOrder(
        id: id ?? json['id'] as String? ?? '',
        orderNumber: json['orderNumber'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        deliveryAddress: json['deliveryAddress'] as String? ?? '',
        locationId: json['locationId'] as String? ?? '',
        locationName: json['locationName'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(OrderItemSnapshot.fromJson)
            .toList(),
        estimatedSubtotal: json['estimatedSubtotal'] as num? ?? 0,
        orderStatus: orderStatusFromValue(json['orderStatus'] as String?),
        paymentStatus: paymentStatusFromValue(json['paymentStatus'] as String?),
        createdAt: _readDate(json['createdAt']),
        updatedAt: _readDate(json['updatedAt']),
        customerNote: json['customerNote'] as String?,
        adminNote: json['adminNote'] as String?,
        confirmedSubtotal: json['confirmedSubtotal'] as num?,
        deliveryCharge: json['deliveryCharge'] as num? ?? 0,
        finalTotal: json['finalTotal'] as num?,
        verifiedAt:
            json['verifiedAt'] == null ? null : _readDate(json['verifiedAt']),
        verifiedBy: json['verifiedBy'] as String?,
        paymentUpdatedAt: json['paymentUpdatedAt'] == null
            ? null
            : _readDate(json['paymentUpdatedAt']),
        paymentUpdatedBy: json['paymentUpdatedBy'] as String?,
      );
}

DateTime _readDate(Object? value) {
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is Map<String, dynamic>) {
    final seconds = value['seconds'] ?? value['_seconds'];
    if (seconds is num) {
      return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
    }
  }
  return DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

class CreateOrderRequest {
  const CreateOrderRequest({
    required this.idempotencyKey,
    required this.locationId,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.items,
    this.customerNote,
  });
  final String idempotencyKey;
  final String locationId;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final List<CreateOrderRequestItem> items;
  final String? customerNote;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'idempotencyKey': idempotencyKey,
        'locationId': locationId,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'deliveryAddress': deliveryAddress,
        'customerNote': customerNote,
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class CreateOrderRequestItem {
  const CreateOrderRequestItem(
      {required this.productId, required this.quantity});
  final String productId;
  final int quantity;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'productId': productId, 'quantity': quantity};
}

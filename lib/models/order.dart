import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  ready,
  outForDelivery,
  delivered,
  cancelled
}

enum PaymentStatus {
  pending,
  verificationRequired,
  verified,
  failed,
  refunded,
  notRequired
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
      this.customerNote});
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
}

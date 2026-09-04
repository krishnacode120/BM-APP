import 'package:bm/models/order.dart';
import 'package:bm/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final item = OrderItemSnapshot(
    productId: 'red-clay-brick',
    productName: 'Red Clay Brick',
    productNameTamil: 'செங்கல்',
    unit: ProductUnit.piece,
    quantity: 1000,
    priceAtOrder: 8,
    subtotal: 8000,
    locationId: 'karaikudi',
    imageUrl: 'https://example.com/brick.jpg',
  );
  final order = BmOrder(
    id: 'order-1',
    orderNumber: 'BM10001',
    userId: 'user-1',
    customerName: 'Krishna',
    phoneNumber: '+919999999999',
    deliveryAddress: 'Karaikudi',
    locationId: 'karaikudi',
    locationName: 'Karaikudi, Tamil Nadu',
    items: [item],
    estimatedSubtotal: 8000,
    orderStatus: OrderStatus.pending,
    paymentStatus: PaymentStatus.unpaid,
    createdAt: DateTime(2026, 9, 1),
    updatedAt: DateTime(2026, 9, 1),
    customerNote: 'Deliver before 10 AM',
  );

  test('order item serialization preserves historical price snapshot', () {
    final decoded = OrderItemSnapshot.fromJson(item.toJson());
    expect(decoded.priceAtOrder, 8);
    expect(decoded.subtotal, 8000);
    expect(decoded.productName, 'Red Clay Brick');
  });

  test('order serialization preserves customer and location snapshot', () {
    final decoded = BmOrder.fromJson(order.toJson());
    expect(decoded.customerName, 'Krishna');
    expect(decoded.phoneNumber, '+919999999999');
    expect(decoded.locationName, 'Karaikudi, Tamil Nadu');
    expect(decoded.items.single.priceAtOrder, 8);
  });

  test('create order request excludes authoritative totals and prices', () {
    final request = CreateOrderRequest(
      idempotencyKey: 'abc123abc123abc123',
      locationId: 'karaikudi',
      customerName: 'Krishna',
      phoneNumber: '+919999999999',
      deliveryAddress: 'Karaikudi',
      customerNote: 'Call before delivery',
      items: const [
        CreateOrderRequestItem(productId: 'red-clay-brick', quantity: 1000)
      ],
    ).toJson();
    expect(request.containsKey('estimatedSubtotal'), isFalse);
    expect(request.containsKey('userId'), isFalse);
    expect(
        (request['items'] as List).single.containsKey('priceAtOrder'), isFalse);
  });

  test('legacy order states map to the narrowed business states', () {
    expect(orderStatusFromValue('delivered'), OrderStatus.completed);
    expect(orderStatusFromValue('outForDelivery'), OrderStatus.completed);
    expect(paymentStatusFromValue('verified'), PaymentStatus.paid);
    expect(paymentStatusFromValue('pending'), PaymentStatus.unpaid);
  });

  test('revenue is recognized only for paid, non-cancelled orders', () {
    final paid = BmOrder.fromJson(<String, dynamic>{
      ...order.toJson(),
      'paymentStatus': 'paid',
      'finalTotal': 8200,
    });
    final cancelled = BmOrder.fromJson(<String, dynamic>{
      ...paid.toJson(),
      'orderStatus': 'cancelled',
    });
    expect(paid.recognizedRevenue, 8200);
    expect(cancelled.recognizedRevenue, 0);
  });
}

import 'package:bm/models/order.dart';
import 'package:bm/models/product.dart';
import 'package:bm/repositories/admin_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('report range excludes cancelled revenue and aggregates materials', () {
    final day = DateTime(2026, 9, 4);
    final paid = _order(
      id: 'paid',
      createdAt: day,
      paymentStatus: PaymentStatus.paid,
      orderStatus: OrderStatus.completed,
      total: 100,
    );
    final cancelled = _order(
      id: 'cancelled',
      createdAt: day,
      paymentStatus: PaymentStatus.paid,
      orderStatus: OrderStatus.cancelled,
      total: 200,
    );
    final summary = AdminReportingSummary(
      totalOrders: 2,
      synced: 0,
      pending: 0,
      failed: 0,
      recentJobs: const [],
      sourceOrders: <BmOrder>[paid, cancelled],
    ).forRange(day, day);

    expect(summary.totalOrders, 2);
    expect(summary.completedOrders, 1);
    expect(summary.cancelledOrders, 1);
    expect(summary.recognizedRevenue, 100);
    expect(summary.topMaterials.single.quantity, 10);
    expect(summary.topMaterials.single.orderCount, 1);
  });
}

BmOrder _order({
  required String id,
  required DateTime createdAt,
  required PaymentStatus paymentStatus,
  required OrderStatus orderStatus,
  required num total,
}) =>
    BmOrder(
      id: id,
      orderNumber: id,
      userId: 'user',
      customerName: 'Customer',
      phoneNumber: '+919876543210',
      deliveryAddress: '',
      locationId: 'karaikudi',
      locationName: 'Karaikudi',
      items: const <OrderItemSnapshot>[
        OrderItemSnapshot(
          productId: 'brick',
          productName: 'Brick',
          productNameTamil: 'செங்கல்',
          unit: ProductUnit.piece,
          quantity: 10,
          priceAtOrder: 10,
          subtotal: 100,
          locationId: 'karaikudi',
        ),
      ],
      estimatedSubtotal: total,
      finalTotal: total,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

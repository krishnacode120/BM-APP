import 'dart:async';
import 'dart:convert';

import 'package:bm/features/admin/admin_providers.dart';
import 'package:bm/features/auth/auth_providers.dart';
import 'package:bm/features/cart/cart_notifier.dart';
import 'package:bm/features/orders/order_providers.dart';
import 'package:bm/models/cart.dart';
import 'package:bm/models/product.dart';
import 'package:bm/repositories/admin_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionUser extends Fake implements User {
  SessionUser(this.uid);
  @override
  final String uid;
}

class SessionAdminRepository extends Fake implements AdminRepository {
  bool allowed = false;
  int checks = 0;
  int reads = 0;
  @override
  Future<bool> isCurrentUserAdmin() async {
    checks++;
    return allowed;
  }

  @override
  Future<List<AdminUserSummary>> users() async {
    reads++;
    return const [
      AdminUserSummary(
          id: 'private', phoneNumber: '', role: 'customer', isActive: true)
    ];
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  test(
      'admin access and private data refresh after sign-in, sign-out and account change',
      () async {
    final sessions = StreamController<User?>();
    final repository = SessionAdminRepository();
    final container = ProviderContainer(overrides: [
      firebaseAuthStateProvider.overrideWith((_) => sessions.stream),
      adminRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    addTearDown(sessions.close);
    container.listen(adminAccessProvider, (_, __) {});
    sessions.add(null);
    expect(await container.read(adminAccessProvider.future), isFalse);
    expect(repository.checks, 0);
    repository.allowed = true;
    sessions.add(SessionUser('admin'));
    await flush();
    expect(await container.read(adminAccessProvider.future), isTrue);
    expect(
        (await container.read(adminUsersProvider.future)).single.id, 'private');
    sessions.add(null);
    await flush();
    expect(await container.read(adminAccessProvider.future), isFalse);
    await expectLater(container.read(adminUsersProvider.future),
        throwsA(isA<AdminFailure>()));
    repository.allowed = false;
    sessions.add(SessionUser('customer'));
    await flush();
    expect(await container.read(adminAccessProvider.future), isFalse);
    expect(repository.reads, 1);
  });

  test('cart persistence and checkout details stay scoped to their account',
      () async {
    final item = CartItem(
        productId: 'p',
        productName: 'Brick',
        productNameTamil: '',
        imageUrl: null,
        unit: ProductUnit.piece,
        quantity: 500,
        minimumOrderQuantity: 500,
        selectedLocationId: 'k',
        displayedUnitPrice: 8,
        inventoryStatus: InventoryStatus.available,
        addedAt: DateTime(2026));
    SharedPreferences.setMockInitialValues({
      'cart_a': jsonEncode([item.toJson()]),
      'cart_b': '[]',
    });
    final sessions = StreamController<User?>();
    final container = ProviderContainer(overrides: [
      firebaseAuthStateProvider.overrideWith((_) => sessions.stream),
    ]);
    addTearDown(container.dispose);
    addTearDown(sessions.close);
    container.listen(cartProvider, (_, __) {});
    container.listen(checkoutProvider, (_, __) {});
    sessions.add(SessionUser('a'));
    await flush();
    await flush();
    expect(container.read(cartProvider).items.single.productId, 'p');
    container.read(checkoutProvider.notifier).updateCustomerName('Account A');
    sessions.add(SessionUser('b'));
    await flush();
    expect(container.read(cartProvider).items, isEmpty);
    expect(container.read(checkoutProvider).customerName, isEmpty);
    container.read(cartProvider.notifier).clear();
    await flush();
    sessions.add(SessionUser('a'));
    await flush();
    await flush();
    expect(container.read(cartProvider).items.single.productId, 'p');
  });
}

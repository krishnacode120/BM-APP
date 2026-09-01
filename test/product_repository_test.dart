import 'package:flutter_test/flutter_test.dart';
import 'package:bm/repositories/product_repository.dart';

void main() {
  test('sample catalog exposes products with valid minimum orders', () async {
    final products = await SampleProductRepository().popularProducts();
    expect(products, isNotEmpty);
    expect(
        products
            .every((product) => product.minimumOrder > 0 && product.price > 0),
        isTrue);
  });
}

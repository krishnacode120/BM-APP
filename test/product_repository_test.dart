import 'package:bm/repositories/catalog_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('development catalog has products and active locations', () async {
    final repository = DemoCatalogRepository();
    expect(await repository.popularProducts(), isNotEmpty);
    expect(await repository.activeLocations(), isNotEmpty);
  });
}

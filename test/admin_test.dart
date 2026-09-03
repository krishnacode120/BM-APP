import 'package:bm/features/admin/admin_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin gate denies access without an admin claim',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: AdminGatePage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('You are not authorized to access BM Admin.'),
        findsOneWidget);
  });
}

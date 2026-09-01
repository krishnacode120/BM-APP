import 'package:bm/core/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders BM splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const BmApp());
    expect(find.text('BM'), findsOneWidget);
  });
}

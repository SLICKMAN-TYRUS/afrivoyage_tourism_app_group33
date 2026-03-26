import 'package:flutter_test/flutter_test.dart';
import 'package:afrivoyage/main.dart';

void main() {
  testWidgets('App loads with AfriVoyage title', (WidgetTester tester) async {
    await tester.pumpWidget(const AfriVoyageApp());
    expect(find.text('AfriVoyage'), findsOneWidget);
  });
}

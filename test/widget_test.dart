import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/app.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const SportsEcoApp());
    expect(find.byType(SportsEcoApp), findsOneWidget);
  });
}

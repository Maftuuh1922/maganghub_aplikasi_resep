import 'package:flutter_test/flutter_test.dart';
import 'package:pantom_meals/main.dart';

void main() {
  testWidgets('app renders Pantom Meals title', (tester) async {
    await tester.pumpWidget(const PantomMealsApp());
    expect(find.text('Pantom'), findsOneWidget);
  });
}

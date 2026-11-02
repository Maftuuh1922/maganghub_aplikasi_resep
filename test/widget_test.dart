import 'package:flutter_test/flutter_test.dart';
import 'package:pantom_meals/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('first launch shows onboarding', (tester) async {
    await tester.pumpWidget(const PantomMealsApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });
}

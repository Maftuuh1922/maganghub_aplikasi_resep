import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantom_meals/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NavigationHarness extends StatefulWidget {
  const _NavigationHarness();

  @override
  State<_NavigationHarness> createState() => _NavigationHarnessState();
}

class _NavigationHarnessState extends State<_NavigationHarness> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('page $selected')),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: FloatingNav(
              selected: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      );
}

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
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/onboarding/onboarding_1.png',
      ),
      findsOneWidget,
    );
  });

  testWidgets('swiping the floating navigation selects the next page',
      (tester) async {
    await tester.pumpWidget(const _NavigationHarness());
    final nav = find.byType(FloatingNav);
    final bounds = tester.getRect(nav);
    await tester.flingFrom(bounds.center, const Offset(-300, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('page 1'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
  });

  testWidgets('floating navigation stays compact and pill-shaped',
      (tester) async {
    await tester.pumpWidget(const _NavigationHarness());
    final bounds = tester.getRect(find.byKey(const Key('floating-nav-pill')));
    expect(bounds.height, 68);
    expect(bounds.width, lessThanOrEqualTo(320));
  });

  testWidgets('notification control opens its panel', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Header())));
    await tester.tap(find.byIcon(CupertinoIcons.bell));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text("You're all caught up"), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pantom_meals/main.dart';
import 'package:pantom_meals/presentation/widgets/favorite_toast.dart';

class _UiRepository extends MealRepository {
  _UiRepository() : super(MealApiService());

  @override
  Future<List<MealCategory>> getCategories() async => [];

  @override
  Future<List<Meal>> getMeals(String category, {String? query}) async => [];

  @override
  Future<Meal> getMealDetail(String id) async =>
      throw const MealApiException('not found');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  testWidgets('segmented top pill switches to Saved', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Header(
            selectedTab: selected,
            onTabChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('top-nav-home')), findsOneWidget);
    expect(find.byKey(const Key('top-nav-saved')), findsOneWidget);
    await tester.tap(find.byKey(const Key('top-nav-saved')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(selected, 1);
  });

  testWidgets('top action pill opens notifications', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Header(selectedTab: 0, onTabChanged: (_) {}),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('top-notification-button')));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text("You're all caught up"), findsOneWidget);
  });

  testWidgets('bottom dock exposes search only', (tester) async {
    final state = AppState(_UiRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomDock(
            controller: TextEditingController(),
            state: state,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('bottom-search-field')), findsOneWidget);
    expect(find.byKey(const Key('bottom-notification-button')), findsNothing);
  });

  testWidgets('favorite action shows a replaceable toast', (tester) async {
    final state = AppState(_UiRepository());
    const meal = Meal(id: '1', name: 'Toast Soup', thumb: '');
    await state.toggleFavorite(meal);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: Scaffold(body: Stack(children: [FavoriteToastOverlay()])),
        ),
      ),
    );
    expect(find.text('Toast Soup ditambahkan ke Saved'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2700));
    expect(find.text('Toast Soup ditambahkan ke Saved'), findsNothing);
  });

  testWidgets('old chat-node navigation is not rendered', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Header(selectedTab: 0, onTabChanged: (_) {}),
        ),
      ),
    );
    expect(find.byKey(const Key('top-left-network-nav')), findsOneWidget);
    expect(find.byKey(const Key('top-nav-home')), findsOneWidget);
    expect(find.byKey(const Key('top-nav-saved')), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pantom_meals/data/models/category.dart';
import 'package:pantom_meals/data/models/ingredient.dart';
import 'package:pantom_meals/data/models/meal.dart';
import 'package:pantom_meals/data/repositories/meal_repository.dart';
import 'package:pantom_meals/data/services/meal_api_service.dart';
import 'package:pantom_meals/logic/app_state.dart';
import 'package:pantom_meals/presentation/widgets/app_network_image.dart';
import 'package:pantom_meals/presentation/widgets/header.dart';
import 'package:pantom_meals/presentation/widgets/ingredient_list.dart';
import 'package:pantom_meals/presentation/widgets/list_controls.dart';
import 'package:pantom_meals/presentation/widgets/meal_card.dart';
import 'package:pantom_meals/presentation/widgets/recipe_detail_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UiRepository extends MealRepository {
  _UiRepository() : super(MealApiService());

  @override
  Future<List<MealCategory>> getCategories() async => const [];

  @override
  Future<List<Meal>> getMeals(String category, {String? query}) async =>
      const [];

  @override
  Future<Meal> getMealDetail(String id) async => const Meal(
        id: '33',
        name: 'Sharp Detail',
        thumb: 'https://example.test/detail.jpg',
      );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('category artwork is fully visible inside a compact tile',
      (tester) async {
    final state = AppState(_UiRepository());
    await state.initialized;
    state.categories = const [
      MealCategory(name: 'Beef', image: 'https://example.test/beef.png'),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: CategoryStrip(state: state))),
    );

    final tile = find.byKey(const Key('category-tile-Beef'));
    expect(tester.getSize(tile).width, lessThanOrEqualTo(90));
    expect(tester.getSize(tile).height, lessThanOrEqualTo(90));
    final image = tester.widget<AppNetworkImage>(
      find.byKey(const Key('category-image-Beef')),
    );
    expect(image.fit, BoxFit.contain);
  });

  testWidgets('meal card loads a 350px thumbnail instead of 150px small',
      (tester) async {
    final state = AppState(_UiRepository());
    const meal = Meal(
      id: '21',
      name: 'Sharp Soup',
      thumb: 'https://example.test/soup.jpg',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: state,
            child: const SizedBox(
              width: 180,
              height: 240,
              child: MealCard(meal: meal),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<AppNetworkImage>(
      find.byKey(const Key('meal-image-21')),
    );
    expect(image.imageUrl, 'https://example.test/soup.jpg/medium');
  });

  testWidgets('detail title backdrop has rounded upper corners',
      (tester) async {
    final state = AppState(_UiRepository());
    const meal = Meal(id: '33', name: 'Sharp Detail', thumb: '');
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showRecipeDetailSheet(
                context: context,
                meal: meal,
                repository: state.repository,
              ),
              child: const Text('Show detail'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Show detail'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    final titlePanel = tester.widget<ClipRRect>(
      find.byKey(const Key('detail-title-backdrop')),
    );
    expect(
        titlePanel.borderRadius,
        const BorderRadius.vertical(
          top: Radius.circular(22),
        ));
    final cover = tester.widget<AppNetworkImage>(
      find.byKey(const Key('detail-cover-image')),
    );
    expect(cover.imageUrl, 'https://example.test/detail.jpg');
  });

  testWidgets('ingredient card groups readable names and measures',
      (tester) async {
    const ingredients = [
      Ingredient('Chicken breast', '2 pcs'),
      Ingredient('Coconut milk', '400 ml'),
      Ingredient('Fresh coriander', '1 small bunch'),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IngredientList(ingredients: ingredients),
          ),
        ),
      ),
    );

    final card = tester.widget<Container>(
      find.byKey(const Key('ingredients-card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(18));
    expect(find.text('Chicken breast'), findsOneWidget);
    expect(find.text('2 pcs'), findsOneWidget);
  });

  testWidgets('dummy notifications can be dismissed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Header(selectedTab: 0, onTabChanged: (_) {}),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('top-notification-button')));
    await tester.pumpAndSettle();
    expect(find.text('Resep baru untuk dicoba'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification-delete-0')));
    await tester.pumpAndSettle();
    expect(find.text('Resep baru untuk dicoba'), findsNothing);
    expect(find.text('Inspirasi hari ini'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification-delete-0')));
    await tester.pumpAndSettle();
    expect(find.text('Semua notifikasi sudah dibersihkan'), findsOneWidget);
  });

  test('favorite persistence error is caught and rolled back in app state',
      () async {
    var preferencesCalls = 0;
    final state = AppState(
      _UiRepository(),
      preferencesProvider: () async {
        preferencesCalls++;
        if (preferencesCalls > 1) {
          throw StateError('preferences unavailable');
        }
        return SharedPreferences.getInstance();
      },
    );
    await state.initialized;

    await expectLater(
      state.toggleFavorite(
        const Meal(id: '44', name: 'No Crash Meal', thumb: ''),
      ),
      completes,
    );

    expect(state.isFavorite('44'), isFalse);
    expect(state.toast?.isError, isTrue);
    expect(state.toast?.message.toLowerCase(), contains('gagal'));
  });
}

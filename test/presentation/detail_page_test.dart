import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pantom_meals/data/models/category.dart';
import 'package:pantom_meals/data/models/meal.dart';
import 'package:pantom_meals/data/repositories/meal_repository.dart';
import 'package:pantom_meals/data/services/meal_api_service.dart';
import 'package:pantom_meals/logic/app_state.dart';
import 'package:pantom_meals/presentation/pages/detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RetryRepository extends MealRepository {
  _RetryRepository() : super(MealApiService());
  int detailCalls = 0;

  @override
  Future<List<MealCategory>> getCategories() async => [];
  @override
  Future<List<Meal>> getMeals(String category, {String? query}) async => [];
  @override
  Future<Meal> getMealDetail(String id) async {
    detailCalls++;
    if (detailCalls == 1) throw const MealApiException('offline');
    return const Meal(
        id: '42',
        name: 'Retry Soup',
        thumb: 'https://example.test/soup.jpg',
        ingredients: []);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('detail error exposes a working retry action', (tester) async {
    final repository = _RetryRepository();
    const meal = Meal(id: '42', name: 'Retry Soup', thumb: '');
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(repository),
        child:
            MaterialApp(home: DetailPage(meal: meal, repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load recipe details. Check your connection.'),
        findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.detailCalls, 2);
    expect(find.text('Retry Soup'), findsWidgets);
    expect(find.text('Instructions'), findsOneWidget);
  });
}

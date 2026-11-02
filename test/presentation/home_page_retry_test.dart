import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pantom_meals/data/models/category.dart';
import 'package:pantom_meals/data/models/meal.dart';
import 'package:pantom_meals/data/repositories/meal_repository.dart';
import 'package:pantom_meals/data/services/meal_api_service.dart';
import 'package:pantom_meals/logic/app_state.dart';

class _RecoveringRepository extends MealRepository {
  _RecoveringRepository() : super(MealApiService());
  int categoryCalls = 0;

  @override
  Future<List<MealCategory>> getCategories() async {
    categoryCalls++;
    if (categoryCalls == 1) throw const MealApiException('offline');
    return const [MealCategory(name: 'Beef', image: '')];
  }

  @override
  Future<List<Meal>> getMeals(String category, {String? query}) async {
    return const [Meal(id: '7', name: 'Recovered Meal', thumb: '')];
  }

  @override
  Future<Meal> getMealDetail(String id) async =>
      const Meal(id: '7', name: 'Recovered Meal', thumb: '');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('catalog retry reloads categories after initial category failure',
      () async {
    final repository = _RecoveringRepository();
    final state = AppState(repository);
    await state.initialized;

    expect(repository.categoryCalls, 1);
    expect(state.errorMessage, 'offline');

    await state.retry();

    expect(repository.categoryCalls, 2);
    expect(state.errorMessage, isNull);
    expect(state.meals.single.name, 'Recovered Meal');
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pantom_meals/data/models/meal.dart';
import 'package:pantom_meals/data/services/meal_api_service.dart';

void main() {
  test('categories endpoint returns named categories', () async {
    Uri? requested;
    final service = MealApiService(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode({
            'categories': [
              {
                'strCategory': 'Seafood',
                'strCategoryThumb': 'https://example.test/cat.jpg'
              }
            ],
          }),
          200,
        );
      }),
    );
    final categories = await service.fetchCategories();
    expect(requested!.path, endsWith('/categories.php'));
    expect(categories.single.name, 'Seafood');
  });

  test('filter endpoint returns list fields and null meals is empty', () async {
    Uri? requested;
    final service = MealApiService(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode({
            'meals': [
              {
                'idMeal': '52772',
                'strMeal': 'Teriyaki Chicken',
                'strMealThumb': 'https://example.test/meal.jpg'
              }
            ],
          }),
          200,
        );
      }),
    );
    final meals = await service.fetchMeals('Seafood');
    expect(requested!.path, endsWith('/filter.php'));
    expect(requested!.queryParameters['c'], 'Seafood');
    expect(meals.single.name, 'Teriyaki Chicken');

    final emptyService = MealApiService(
      client: MockClient((_) async => http.Response('{"meals":null}', 200)),
    );
    expect(await emptyService.fetchMeals('Seafood'), isEmpty);
  });

  test('detail endpoint looks up the meal by id', () async {
    Uri? requested;
    final service = MealApiService(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode({
            'meals': [
              {
                'idMeal': '52772',
                'strMeal': 'Teriyaki Chicken',
                'strMealThumb': 'https://example.test/meal.jpg',
                'strIngredient1': 'Chicken',
                'strMeasure1': '200 g',
                'strInstructions': 'Cook it.',
              }
            ],
          }),
          200,
        );
      }),
    );
    final meal = await service.fetchMealDetail('52772');
    expect(requested!.path, endsWith('/lookup.php'));
    expect(requested!.queryParameters['i'], '52772');
    expect(meal.ingredients.single.name, 'Chicken');
    expect(meal.instructions, 'Cook it.');
  });

  test('search uses the public search endpoint and returns meal list',
      () async {
    Uri? requested;
    final service = MealApiService(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode({
            'meals': [
              {
                'idMeal': '52772',
                'strMeal': 'Teriyaki Chicken',
                'strMealThumb': 'https://example.test/meal.jpg',
              }
            ],
          }),
          200,
        );
      }),
    );

    final meals = await service.fetchMeals('Beef', query: 'Teriyaki Chicken');

    expect(requested!.path, endsWith('/search.php'));
    expect(requested!.queryParameters['s'], 'Teriyaki Chicken');
    expect(meals.single.id, '52772');
  });

  test('meal parser joins ingredient and measure and skips blank ingredients',
      () {
    final meal = Meal.fromJson({
      'idMeal': '1',
      'strMeal': 'Sample',
      'strIngredient1': 'Chicken',
      'strMeasure1': '200 g',
      'strIngredient2': '  ',
      'strMeasure2': 'ignored',
      'strIngredient20': 'Salt',
      'strMeasure20': 'to taste',
    });

    expect(meal.ingredients.map((item) => item.name), ['Chicken', 'Salt']);
    expect(meal.ingredients.map((item) => item.measure), ['200 g', 'to taste']);
  });
}

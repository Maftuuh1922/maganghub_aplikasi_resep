import '../models/category.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';

class MealRepository {
  final MealApiService api;
  const MealRepository(this.api);

  Future<List<MealCategory>> getCategories() => api.fetchCategories();
  Future<List<Meal>> getMeals(String category, {String? query}) =>
      api.fetchMeals(category, query: query);
  Future<Meal> getMealDetail(String id) => api.fetchMealDetail(id);
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/category.dart';
import '../data/models/meal.dart';
import '../data/repositories/meal_repository.dart';

class AppState extends ChangeNotifier {
  final MealRepository repository;
  late final Future<void> initialized;
  AppState(this.repository) {
    initialized = _initialize();
  }

  List<MealCategory> categories = [];
  List<Meal> meals = [];
  final Map<String, Meal> favoriteMeals = {};
  Set<String> favoriteIds = {};
  String selectedCategory = 'Beef';
  String searchQuery = '';
  bool isLoading = true;
  bool categoriesLoaded = false;
  String? errorMessage;

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteIds = (prefs.getStringList('favorites') ?? []).toSet();
    for (final encoded in prefs.getStringList('favorite_meals') ?? <String>[]) {
      try {
        final meal = Meal.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
        favoriteMeals[meal.id] = meal;
      } catch (_) {
        // Ignore corrupt cache entries and continue with valid favorites.
      }
    }
    await _hydrateFavorites();
    await loadCategories();
  }

  Future<void> _hydrateFavorites() async {
    final fetched = await Future.wait(favoriteIds.map((id) async {
      try {
        return await repository.getMealDetail(id);
      } catch (_) {
        return null;
      }
    }));
    for (final meal in fetched) {
      if (meal != null) favoriteMeals[meal.id] = meal;
    }
  }

  Future<void> loadCategories() async {
    _setLoading();
    try {
      categories = await repository.getCategories();
      categoriesLoaded = true;
      if (categories.isNotEmpty &&
          !categories.any((item) => item.name == selectedCategory)) {
        selectedCategory = categories.first.name;
      }
      await loadMeals();
    } catch (_) {
      _setError('Unable to connect. Check your internet and try again.');
    }
  }

  Future<void> loadMeals() async {
    _setLoading();
    try {
      meals = await repository.getMeals(selectedCategory, query: searchQuery);
      _setReady();
    } catch (_) {
      _setError('Something went wrong while loading recipes.');
    }
  }

  void selectCategory(String category) {
    selectedCategory = category;
    searchQuery = '';
    loadMeals();
  }

  void updateSearch(String value) {
    searchQuery = value;
    if (value.trim().isEmpty) {
      loadMeals();
    } else {
      _searchLater(value);
    }
  }

  Future<void> _searchLater(String value) async {
    await Future.delayed(const Duration(milliseconds: 450));
    if (value == searchQuery) await loadMeals();
  }

  Future<void> toggleFavorite(Meal meal) async {
    if (favoriteIds.contains(meal.id)) {
      favoriteIds.remove(meal.id);
      favoriteMeals.remove(meal.id);
    } else {
      favoriteIds.add(meal.id);
      favoriteMeals[meal.id] = meal;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favoriteIds.toList());
    await prefs.setStringList(
      'favorite_meals',
      favoriteMeals.values.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  Future<void> retry() => categoriesLoaded ? loadMeals() : loadCategories();

  List<Meal> get savedMeals =>
      favoriteIds.map((id) => favoriteMeals[id]).whereType<Meal>().toList();

  void _setLoading() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void _setReady() {
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    isLoading = false;
    errorMessage = message;
    notifyListeners();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/category.dart';
import '../data/models/meal.dart';
import '../data/repositories/meal_repository.dart';
import '../data/services/meal_api_service.dart';

class AppState extends ChangeNotifier {
  final MealRepository repository;
  final Future<SharedPreferences> Function() _preferencesProvider;
  late final Future<void> initialized;

  AppState(
    this.repository, {
    Future<SharedPreferences> Function()? preferencesProvider,
  }) : _preferencesProvider =
            preferencesProvider ?? SharedPreferences.getInstance {
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
  ToastNotice? toast;
  bool hasNewFavoriteNotification = false;
  int _toastId = 0;
  int _favoriteMutationId = 0;

  Future<void> _initialize() async {
    try {
      final prefs = await _preferencesProvider();
      favoriteIds = (prefs.getStringList('favorites') ?? []).toSet();
      for (final encoded
          in prefs.getStringList('favorite_meals') ?? <String>[]) {
        try {
          final meal =
              Meal.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
          favoriteMeals[meal.id] = meal;
        } catch (_) {
          // Ignore corrupt cache entries and continue with valid favorites.
        }
      }
    } catch (_) {
      // Local-storage failure must not block the catalog UI.
      favoriteIds = {};
      favoriteMeals.clear();
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
      if (categories.isNotEmpty) selectedCategory = categories.first.name;
      await loadMeals();
    } catch (error) {
      _setError(_readableError(error, 'Could not load recipe categories.'));
    }
  }

  Future<void> loadMeals() async {
    _setLoading();
    try {
      meals = await repository.getMeals(selectedCategory, query: searchQuery);
      _setReady();
    } catch (error) {
      _setError(_readableError(error, 'Could not load recipes.'));
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
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (value == searchQuery) await loadMeals();
  }

  Future<void> toggleFavorite(Meal meal) async {
    final added = !favoriteIds.contains(meal.id);
    final previousMeal = favoriteMeals[meal.id];
    final mutationId = ++_favoriteMutationId;
    if (added) {
      favoriteIds.add(meal.id);
      favoriteMeals[meal.id] = meal;
    } else {
      favoriteIds.remove(meal.id);
      favoriteMeals.remove(meal.id);
    }

    final notice = ToastNotice(
      id: ++_toastId,
      added: added,
      message: added
          ? '${meal.name} ditambahkan ke Saved'
          : '${meal.name} dihapus dari Saved',
    );
    toast = notice;
    hasNewFavoriteNotification = true;
    notifyListeners();
    unawaited(_hideToastAfter(notice));

    try {
      final prefs = await _preferencesProvider();
      await prefs.setStringList('favorites', favoriteIds.toList());
      await prefs.setStringList(
        'favorite_meals',
        favoriteMeals.values.map((item) => jsonEncode(item.toJson())).toList(),
      );
    } catch (_) {
      if (_favoriteMutationId == mutationId) {
        if (added) {
          favoriteIds.remove(meal.id);
          favoriteMeals.remove(meal.id);
        } else {
          favoriteIds.add(meal.id);
          if (previousMeal != null) favoriteMeals[meal.id] = previousMeal;
        }
        toast = ToastNotice(
          id: ++_toastId,
          added: false,
          isError: true,
          message: 'Gagal menyimpan favorit. Coba lagi.',
        );
        notifyListeners();
      }
    }
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  void markNotificationsRead() {
    if (!hasNewFavoriteNotification) return;
    hasNewFavoriteNotification = false;
    notifyListeners();
  }

  Future<void> _hideToastAfter(ToastNotice notice) async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (toast?.id != notice.id) return;
    toast = null;
    notifyListeners();
  }

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

  String _readableError(Object error, String fallback) {
    if (error is MealApiException) return error.message;
    return fallback;
  }
}

class ToastNotice {
  final int id;
  final bool added;
  final bool isError;
  final String message;

  const ToastNotice({
    required this.id,
    required this.added,
    this.isError = false,
    required this.message,
  });
}

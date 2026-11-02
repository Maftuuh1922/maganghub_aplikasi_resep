import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal.dart';

class MealApiService {
  static const baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final http.Client client;

  MealApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<MealCategory>> fetchCategories() async {
    final json = await _getJson('categories.php');
    final data = json['categories'];
    if (data == null) return [];
    return (data as List)
        .whereType<Map<String, dynamic>>()
        .map(MealCategory.fromJson)
        .toList();
  }

  Future<List<Meal>> fetchMeals(String category, {String? query}) async {
    final endpoint = query != null && query.trim().isNotEmpty
        ? 'search.php?s=${Uri.encodeQueryComponent(query.trim())}'
        : 'filter.php?c=${Uri.encodeQueryComponent(category)}';
    final json = await _getJson(endpoint);
    final data = json['meals'];
    if (data == null) return [];
    return (data as List)
        .whereType<Map<String, dynamic>>()
        .map(Meal.fromJson)
        .toList();
  }

  Future<Meal> fetchMealDetail(String id) async {
    final json = await _getJson('lookup.php?i=${Uri.encodeQueryComponent(id)}');
    final data = json['meals'];
    if (data == null || data is! List || data.isEmpty) {
      throw const MealApiException('Recipe not found');
    }
    return Meal.fromJson(data.first as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _getJson(String endpoint) async {
    final response = await client
        .get(Uri.parse('$baseUrl/$endpoint'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw MealApiException('Request failed (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const MealApiException('Invalid API response');
    }
    return decoded;
  }
}

class MealApiException implements Exception {
  final String message;
  const MealApiException(this.message);
  @override
  String toString() => message;
}

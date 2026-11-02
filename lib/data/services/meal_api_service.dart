import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    if (data is! List) throw const MealApiException.parsing();
    return data
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
    if (data is! List) throw const MealApiException.parsing();
    return data.whereType<Map<String, dynamic>>().map(Meal.fromJson).toList();
  }

  Future<Meal> fetchMealDetail(String id) async {
    final json = await _getJson('lookup.php?i=${Uri.encodeQueryComponent(id)}');
    final data = json['meals'];
    if (data == null || (data is List && data.isEmpty)) {
      throw const MealApiException.notFound();
    }
    if (data is! List || data.first is! Map<String, dynamic>) {
      throw const MealApiException.parsing();
    }
    return Meal.fromJson(data.first as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _getJson(String endpoint) async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/$endpoint'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode >= 500) {
          throw MealApiException.server(response.statusCode);
        }
        throw MealApiException('Request rejected (${response.statusCode}).');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const MealApiException.parsing();
      }
      return decoded;
    } on TimeoutException {
      throw const MealApiException.timeout();
    } on SocketException {
      throw const MealApiException.offline();
    } on http.ClientException {
      throw const MealApiException.offline();
    } on FormatException {
      throw const MealApiException.parsing();
    }
  }
}

class MealApiException implements Exception {
  final String message;
  const MealApiException(this.message);

  const MealApiException.offline()
      : message = 'No internet connection. Connect and retry.';
  const MealApiException.timeout()
      : message = 'The request timed out. Check your connection and retry.';
  const MealApiException.parsing()
      : message = 'TheMealDB response could not be parsed. Please retry.';
  const MealApiException.notFound() : message = 'Recipe was not found.';
  const MealApiException.server(int statusCode)
      : message = 'TheMealDB server error ($statusCode). Please retry.';

  @override
  String toString() => message;
}

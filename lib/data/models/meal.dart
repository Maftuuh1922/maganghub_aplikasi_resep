import 'ingredient.dart';

class Meal {
  final String id;
  final String name;
  final String thumb;
  final String? category;
  final String? area;
  final String? instructions;
  final List<Ingredient> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.thumb,
    this.category,
    this.area,
    this.instructions,
    this.ingredients = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final items = <Ingredient>[];
    for (var index = 1; index <= 20; index++) {
      final name = (json['strIngredient$index'] ?? '').toString().trim();
      final measure = (json['strMeasure$index'] ?? '').toString().trim();
      if (name.isNotEmpty) items.add(Ingredient(name, measure));
    }
    return Meal(
      id: (json['idMeal'] ?? '').toString(),
      name: (json['strMeal'] ?? 'Untitled recipe').toString(),
      thumb: (json['strMealThumb'] ?? '').toString(),
      category: json['strCategory']?.toString(),
      area: json['strArea']?.toString(),
      instructions: json['strInstructions']?.toString(),
      ingredients: items,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumb,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
    };
    for (var index = 0; index < ingredients.length && index < 20; index++) {
      json['strIngredient${index + 1}'] = ingredients[index].name;
      json['strMeasure${index + 1}'] = ingredients[index].measure;
    }
    return json;
  }
}

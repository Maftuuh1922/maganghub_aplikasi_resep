class MealCategory {
  final String name;
  final String image;
  final String description;

  const MealCategory({
    required this.name,
    required this.image,
    this.description = '',
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) => MealCategory(
        name: (json['strCategory'] ?? 'Category').toString(),
        image: (json['strCategoryThumb'] ?? '').toString(),
        description: (json['strCategoryDescription'] ?? '').toString(),
      );
}

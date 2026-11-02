class MealCategory {
  final String name;
  final String image;

  const MealCategory({required this.name, required this.image});

  factory MealCategory.fromJson(Map<String, dynamic> json) => MealCategory(
        name: (json['strCategory'] ?? 'Category').toString(),
        image: (json['strCategoryThumb'] ?? '').toString(),
      );
}

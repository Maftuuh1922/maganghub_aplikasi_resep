import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/ingredient.dart';
import 'app_network_image.dart';

class IngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;
  const IngredientList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const Text(
        'Bahan tidak tersedia.',
        style: TextStyle(color: muted),
      );
    }
    return Container(
      key: const Key('ingredients-card'),
      decoration: BoxDecoration(
        color: readingSurface.withOpacity(.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var index = 0; index < ingredients.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    imageUrl: detailIngredientImage(ingredients[index].name),
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      ingredients[index].name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: readingText,
                      ),
                    ),
                  ),
                  if (ingredients[index].measure.trim().isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 124),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mint.withOpacity(.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ingredients[index].measure,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, color: mint),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (index < ingredients.length - 1)
              const Divider(
                height: 1,
                indent: 74,
                endIndent: 16,
                color: surface2,
              ),
          ],
        ],
      ),
    );
  }
}

String detailIngredientImage(String name) =>
    'https://www.themealdb.com/images/ingredients/${Uri.encodeComponent(name)}.png';

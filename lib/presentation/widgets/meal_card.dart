import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/meal.dart';
import '../../logic/app_state.dart';
import 'app_network_image.dart';
import 'recipe_detail_sheet.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GestureDetector(
      onTap: () => showRecipeDetailSheet(
        context: context,
        meal: meal,
        repository: state.repository,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'meal-${meal.id}',
              child: AppNetworkImage(
                key: Key('meal-image-${meal.id}'),
                imageUrl: meal.mediumThumbnail,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.48, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 48,
              bottom: 14,
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: bg.withOpacity(.78),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: state.isFavorite(meal.id)
                      ? 'Hapus dari Favorit'
                      : 'Tambah ke Favorit',
                  onPressed: () => state.toggleFavorite(meal),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: Icon(
                    state.isFavorite(meal.id)
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    size: 22,
                    color: state.isFavorite(meal.id) ? mint : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  const Tag({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: mint,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            imageUrl: meal.smallThumbnail,
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(24),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 36, 48, 14),
              decoration: BoxDecoration(
                color: bg.withOpacity(.78),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
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
                    ? 'Remove from Saved'
                    : 'Add to Saved',
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
            color: surface2, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: const TextStyle(
                color: mint, fontSize: 12, fontWeight: FontWeight.w700)),
      );
}

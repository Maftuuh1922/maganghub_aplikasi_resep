import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/meal.dart';
import '../../logic/app_state.dart';
import '../pages/detail_page.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(meal: meal, repository: state.repository),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
            color: surface, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(meal.thumb,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: surface2)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => state.toggleFavorite(meal),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: bg.withOpacity(.78), shape: BoxShape.circle),
                    child: Icon(
                        state.isFavorite(meal.id)
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: state.isFavorite(meal.id) ? mint : Colors.white),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 10, 14),
              child: Text(meal.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700))),
        ]),
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

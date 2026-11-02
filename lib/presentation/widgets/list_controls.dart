import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/category.dart';
import '../../logic/app_state.dart';
import 'app_network_image.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final AppState state;
  const SearchHeader(
      {super.key, required this.controller, required this.state});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Find your next',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const Text('favorite recipe.',
              style: TextStyle(
                  fontSize: 28, color: mint, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            onChanged: state.updateSearch,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(CupertinoIcons.search),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
            ),
          ),
        ]),
      );
}

class SectionHeader extends StatelessWidget {
  final AppState state;
  final bool favorites;
  const SectionHeader(
      {super.key, required this.state, required this.favorites});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(children: [
          Text(
            favorites
                ? 'Favorite recipes'
                : (state.searchQuery.isNotEmpty
                    ? 'Search results'
                    : '${state.selectedCategory} recipes'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          if (!state.isLoading)
            Text(
                '${favorites ? state.savedMeals.length : state.meals.length} meals',
                style: const TextStyle(color: muted, fontSize: 13)),
        ]),
      );
}

class CategoryStrip extends StatelessWidget {
  final AppState state;
  const CategoryStrip({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final category = state.categories[index];
              final active = category.name == state.selectedCategory;
              return _CategoryTile(
                category: category,
                active: active,
                onTap: () => state.selectCategory(category.name),
              );
            },
          ),
        ),
      );
}

class _CategoryTile extends StatelessWidget {
  final MealCategory category;
  final bool active;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.category, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
        message:
            category.description.isEmpty ? category.name : category.description,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 92,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: active ? mint : surface,
                borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              AppNetworkImage(
                imageUrl: category.image,
                width: 50,
                height: 50,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(height: 5),
              Text(category.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? bg : Colors.white)),
            ]),
          ),
        ),
      );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/meal.dart';
import '../../data/repositories/meal_repository.dart';
import '../widgets/meal_card.dart';
import '../widgets/status_views.dart';

class DetailPage extends StatefulWidget {
  final Meal meal;
  final MealRepository repository;
  const DetailPage({super.key, required this.meal, required this.repository});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Meal? detail;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final loaded = await widget.repository.getMealDetail(widget.meal.id);
      if (!mounted) return;
      setState(() {
        detail = loaded;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load recipe details. Check your connection.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = detail;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 330,
          pinned: true,
          backgroundColor: bg,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.chevron_back)),
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              widget.meal.thumb,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(color: surface2),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildBody(recipe),
          ),
        ),
      ]),
    );
  }

  Widget _buildBody(Meal? recipe) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(36),
        child: Center(child: CircularProgressIndicator(color: mint)),
      );
    }
    if (error != null) {
      return ErrorView(message: error!, retry: _loadDetail);
    }
    if (recipe == null) {
      return ErrorView(
          message: 'Recipe details are unavailable.', retry: _loadDetail);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(recipe.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      Wrap(spacing: 8, children: [
        if (recipe.category != null && recipe.category!.isNotEmpty)
          Tag(text: recipe.category!),
        if (recipe.area != null && recipe.area!.isNotEmpty)
          Tag(text: recipe.area!),
      ]),
      const SizedBox(height: 28),
      const Text('Ingredients',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      ...recipe.ingredients.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration:
                      const BoxDecoration(color: mint, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(item.name)),
              Text(item.measure, style: const TextStyle(color: muted)),
            ]),
          )),
      const SizedBox(height: 24),
      const Text('Instructions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Text(
          recipe.instructions?.trim().isNotEmpty == true
              ? recipe.instructions!
              : 'No instructions available.',
          style: const TextStyle(color: muted, height: 1.6)),
    ]);
  }
}

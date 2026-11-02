import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/meal.dart';
import '../../data/repositories/meal_repository.dart';
import '../../data/services/meal_api_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/meal_card.dart';
import '../widgets/recipe_detail_sheet.dart';
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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        this.error = error is MealApiException
            ? error.message
            : 'Could not load recipe details. Please retry.';
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
            background: AppNetworkImage(
              imageUrl: widget.meal.mediumThumbnail,
              fit: BoxFit.cover,
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
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      IngredientList(ingredients: recipe.ingredients),
      const SizedBox(height: 24),
      const Text('Instructions',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      InstructionList(text: recipe.instructions),
    ]);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/ingredient.dart';
import '../../data/models/meal.dart';
import '../../data/repositories/meal_repository.dart';
import '../../data/services/meal_api_service.dart';
import '../../logic/app_state.dart';
import 'app_network_image.dart';
import 'status_views.dart';

Future<void> showRecipeDetailSheet({
  required BuildContext context,
  required Meal meal,
  required MealRepository repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.72),
    builder: (_) => RecipeDetailSheet(meal: meal, repository: repository),
  );
}

class RecipeDetailSheet extends StatefulWidget {
  final Meal meal;
  final MealRepository repository;

  const RecipeDetailSheet({
    super.key,
    required this.meal,
    required this.repository,
  });

  @override
  State<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<RecipeDetailSheet> {
  Meal? detail;
  String? error;
  bool loading = true;

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
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception is MealApiException
            ? exception.message
            : 'Detail resep gagal dimuat. Silakan coba lagi.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        initialChildSize: .48,
        minChildSize: .40,
        maxChildSize: .94,
        expand: false,
        snap: true,
        snapSizes: const [.48, .94],
        builder: (context, scrollController) => DecoratedBox(
          decoration: const BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _SheetTop(meal: detail ?? widget.meal),
              _SheetBody(
                detail: detail,
                loading: loading,
                error: error,
                retry: _loadDetail,
              ),
            ],
          ),
        ),
      );
}

class _SheetTop extends StatelessWidget {
  final Meal meal;
  const _SheetTop({required this.meal});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isFavorite = state.isFavorite(meal.id);
    return SizedBox(
      height: 292,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            child: AppNetworkImage(
              imageUrl: meal.largeThumbnail,
              width: double.infinity,
              height: 292,
            ),
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.78),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg.withOpacity(.78),
                borderRadius: BorderRadius.circular(18),
              ),
              child: IconButton(
                key: const Key('sheet-favorite-button'),
                onPressed: () => state.toggleFavorite(meal),
                icon: Icon(
                  isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                ),
                color: isFavorite ? mint : Colors.white,
                tooltip: 'Favorite',
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: bg.withOpacity(.90),
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (meal.category?.trim().isNotEmpty == true ||
                      meal.area?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (meal.category?.trim().isNotEmpty == true)
                          _SheetTag(text: meal.category!),
                        if (meal.area?.trim().isNotEmpty == true)
                          _SheetTag(text: meal.area!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTag extends StatelessWidget {
  final String text;
  const _SheetTag({required this.text});

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

class _SheetBody extends StatelessWidget {
  final Meal? detail;
  final bool loading;
  final String? error;
  final Future<void> Function() retry;

  const _SheetBody({
    required this.detail,
    required this.loading,
    required this.error,
    required this.retry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const _DetailSkeleton();
    if (error != null) return ErrorView(message: error!, retry: retry);
    if (detail == null) {
      return ErrorView(message: 'Data resep tidak ditemukan.', retry: retry);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Ingredients'),
          const SizedBox(height: 12),
          IngredientList(ingredients: detail!.ingredients),
          const SizedBox(height: 24),
          const _SectionTitle('Instructions'),
          const SizedBox(height: 12),
          InstructionList(text: detail!.instructions),
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SkeletonLine(width: 150, height: 22),
            const SizedBox(height: 18),
            ...List.generate(
              4,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _SkeletonLine(width: double.infinity, height: 18),
              ),
            ),
            const SizedBox(height: 18),
            const _SkeletonLine(width: 180, height: 22),
            const SizedBox(height: 18),
            ...List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _SkeletonLine(width: double.infinity, height: 18),
              ),
            ),
          ],
        ),
      );
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
      );
}

class IngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;
  const IngredientList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const Text('Bahan tidak tersedia.',
          style: TextStyle(color: muted));
    }
    return DecoratedBox(
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
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 7, color: mint),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ingredients[index].name,
                      style: const TextStyle(fontSize: 15, color: readingText),
                    ),
                  ),
                  if (ingredients[index].measure.trim().isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        ingredients[index].measure,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, color: muted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (index < ingredients.length - 1)
              const Divider(
                  height: 1, indent: 30, endIndent: 14, color: surface2),
          ],
        ],
      ),
    );
  }
}

class InstructionList extends StatelessWidget {
  final String? text;
  const InstructionList({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final steps = parseInstructionSteps(text);
    if (steps.isEmpty) {
      return const Text('Instruksi tidak tersedia.', style: readingTextStyle);
    }
    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == steps.length - 1 ? 0 : 16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: mint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: bg,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[index],
                    textAlign: TextAlign.justify,
                    style: readingTextStyle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

List<String> parseInstructionSteps(String? raw) {
  final normalized = (raw ?? '').replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return [];
  final lines = normalized
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map(_removeStepPrefix)
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.length > 1) return lines;

  final sentences = lines.single
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((sentence) => sentence.trim().isNotEmpty)
      .toList();
  if (sentences.length <= 3) return lines;
  final chunks = <String>[];
  for (var index = 0; index < sentences.length; index += 3) {
    chunks.add(sentences.skip(index).take(3).join(' ').trim());
  }
  return chunks;
}

String _removeStepPrefix(String value) => value
    .replaceFirst(
      RegExp(r'^(?:step\s*)?\d+\s*[.):-]?\s*', caseSensitive: false),
      '',
    )
    .trim();

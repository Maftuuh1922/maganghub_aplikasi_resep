import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/meal_repository.dart';
import 'data/services/meal_api_service.dart';
import 'logic/app_state.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/widgets/favorite_toast.dart';

export 'data/models/category.dart';
export 'data/models/ingredient.dart';
export 'data/models/meal.dart';
export 'data/repositories/meal_repository.dart';
export 'data/services/meal_api_service.dart';
export 'core/theme/app_theme.dart';
export 'logic/app_state.dart';
export 'presentation/pages/detail_page.dart';
export 'presentation/pages/home_page.dart';
export 'presentation/pages/onboarding_page.dart';
export 'presentation/widgets/floating_nav.dart';
export 'presentation/widgets/bottom_dock.dart';
export 'presentation/widgets/header.dart';
export 'presentation/widgets/list_controls.dart';
export 'presentation/widgets/meal_card.dart';
export 'presentation/widgets/status_views.dart';

void main() {
  final repository = MealRepository(MealApiService());
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(repository),
      child: const PantomMealsApp(),
    ),
  );
}

class PantomMealsApp extends StatelessWidget {
  const PantomMealsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pantom Meals',
        theme: buildAppTheme(),
        builder: (context, child) => Stack(
          fit: StackFit.expand,
          children: [
            child ?? const SizedBox.shrink(),
            const FavoriteToastOverlay(),
          ],
        ),
        home: const OnboardingGate(),
      );
}

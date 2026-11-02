import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../logic/app_state.dart';
import '../widgets/floating_nav.dart';
import '../widgets/header.dart';
import '../widgets/list_controls.dart';
import '../widgets/meal_card.dart';
import '../widgets/status_views.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  int selectedTab = 0;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return FutureBuilder<void>(
      future: state.initialized,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: mint)),
          );
        }
        return _buildCatalog(state);
      },
    );
  }

  Widget _buildCatalog(AppState state) {
    final showingSaved = selectedTab == 1;
    final visibleMeals = showingSaved ? state.savedMeals : state.meals;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            RefreshIndicator(
              color: mint,
              onRefresh: state.loadMeals,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: Header()),
                  if (!showingSaved)
                    SliverToBoxAdapter(
                      child: SearchHeader(
                          controller: searchController, state: state),
                    ),
                  if (!showingSaved && state.searchQuery.isEmpty)
                    SliverToBoxAdapter(child: CategoryStrip(state: state)),
                  SliverToBoxAdapter(
                    child: SectionHeader(state: state, favorites: showingSaved),
                  ),
                  if (state.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                            child: CircularProgressIndicator(color: mint)),
                      ),
                    ),
                  if (!state.isLoading && state.errorMessage != null)
                    SliverToBoxAdapter(
                      child: ErrorView(
                        message: state.errorMessage!,
                        retry: state.retry,
                      ),
                    ),
                  if (!state.isLoading &&
                      state.errorMessage == null &&
                      visibleMeals.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyView(
                        message: showingSaved
                            ? 'Your favorite recipes will appear here'
                            : 'No recipes found',
                      ),
                    ),
                  if (!state.isLoading &&
                      state.errorMessage == null &&
                      visibleMeals.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => MealCard(meal: visibleMeals[index]),
                          childCount: visibleMeals.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                          childAspectRatio: .68,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 128)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: FloatingNav(
                selected: selectedTab,
                onChanged: (value) => setState(() => selectedTab = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

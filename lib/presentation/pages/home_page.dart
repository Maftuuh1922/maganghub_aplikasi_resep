import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../logic/app_state.dart';
import '../widgets/bottom_dock.dart';
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
  late final PageController pageController;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (index == selectedTab && pageController.hasClients) return;
    setState(() => selectedTab = index);
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
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

  Widget _buildCatalog(AppState state) => PopScope(
        canPop: selectedTab == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && selectedTab == 1) _selectPage(0);
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    // Header stays outside PageView and every scrollable list.
                    AnimatedBuilder(
                      animation: pageController,
                      builder: (context, _) {
                        final offset = pageController.hasClients
                            ? (pageController.page ?? selectedTab.toDouble())
                            : selectedTab.toDouble();
                        return Header(
                          pageOffset: offset,
                          onTabChanged: _selectPage,
                          hasNotification: state.hasNewFavoriteNotification,
                          onNotificationRead: state.markNotificationsRead,
                        );
                      },
                    ),
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (value) {
                          if (selectedTab != value) {
                            setState(() => selectedTab = value);
                          }
                        },
                        children: [
                          _RecipePage(
                            key: const PageStorageKey<String>('home-recipes'),
                            state: state,
                            showingSaved: false,
                          ),
                          _RecipePage(
                            key: const PageStorageKey<String>('saved-recipes'),
                            state: state,
                            showingSaved: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: BottomDock(
                    controller: searchController,
                    state: state,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _RecipePage extends StatefulWidget {
  final AppState state;
  final bool showingSaved;

  const _RecipePage({
    super.key,
    required this.state,
    required this.showingSaved,
  });

  @override
  State<_RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<_RecipePage>
    with AutomaticKeepAliveClientMixin<_RecipePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = widget.state;
    final visibleMeals = widget.showingSaved ? state.savedMeals : state.meals;

    return RefreshIndicator(
      color: mint,
      onRefresh: state.loadMeals,
      child: CustomScrollView(
        key: PageStorageKey<String>(
          widget.showingSaved ? 'saved-scroll' : 'home-scroll',
        ),
        slivers: [
          if (!widget.showingSaved && state.searchQuery.isEmpty)
            SliverToBoxAdapter(child: CategoryStrip(state: state)),
          SliverToBoxAdapter(
            child: SectionHeader(
              state: state,
              favorites: widget.showingSaved,
            ),
          ),
          if (state.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: mint)),
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
                message: widget.showingSaved
                    ? 'Belum ada menu favorit'
                    : 'Tidak ada menu',
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: .68,
                ),
              ),
            ),
          // Reserve space so the floating search never covers the last card.
          const SliverToBoxAdapter(child: SizedBox(height: 104)),
        ],
      ),
    );
  }
}

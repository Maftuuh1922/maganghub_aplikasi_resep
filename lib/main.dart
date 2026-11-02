import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bg = Color(0xFF07131F);
const surface = Color(0xFF102333);
const surface2 = Color(0xFF172D40);
const mint = Color(0xFFB7F397);
const muted = Color(0xFF8DA3B5);
const apiBase = 'https://www.themealdb.com/api/json/v1/1';

class Category {
  final String name;
  final String image;
  Category({required this.name, required this.image});
  factory Category.fromJson(Map<String, dynamic> j) => Category(name: j['strCategory'], image: j['strCategoryThumb']);
}

class Meal {
  final String id, name, thumb;
  final String? category, area, instructions, youtube;
  final List<Ingredient> ingredients;
  Meal({required this.id, required this.name, required this.thumb, this.category, this.area, this.instructions, this.youtube, this.ingredients = const []});
  factory Meal.fromJson(Map<String, dynamic> j) {
    final items = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = (j['strIngredient$i'] ?? '').toString().trim();
      final measure = (j['strMeasure$i'] ?? '').toString().trim();
      if (ingredient.isNotEmpty) items.add(Ingredient(ingredient, measure));
    }
    return Meal(id: j['idMeal'] ?? '', name: j['strMeal'] ?? 'Untitled recipe', thumb: j['strMealThumb'] ?? '', category: j['strCategory'], area: j['strArea'], instructions: j['strInstructions'], youtube: j['strYoutube'], ingredients: items);
  }
}
class Ingredient { final String name, measure; Ingredient(this.name, this.measure); }

class Api {
  Future<List<Category>> categories() async {
    final r = await http.get(Uri.parse('$apiBase/categories.php')).timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw Exception('Could not load categories');
    return ((jsonDecode(r.body)['categories'] ?? []) as List).map((e) => Category.fromJson(e)).toList();
  }
  Future<List<Meal>> meals(String category, {String? query}) async {
    final path = query != null && query.trim().isNotEmpty ? 'search.php?s=${Uri.encodeQueryComponent(query.trim())}' : 'filter.php?c=${Uri.encodeQueryComponent(category)}';
    final r = await http.get(Uri.parse('$apiBase/$path')).timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw Exception('Could not load recipes');
    final data = jsonDecode(r.body)['meals'];
    if (data == null) return [];
    return (data as List).map((e) => Meal.fromJson(e)).toList();
  }
  Future<Meal> detail(String id) async {
    final r = await http.get(Uri.parse('$apiBase/lookup.php?i=$id')).timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw Exception('Could not load recipe detail');
    final list = jsonDecode(r.body)['meals'];
    if (list == null || list.isEmpty) throw Exception('Recipe not found');
    return Meal.fromJson(list.first);
  }
}

class AppState extends ChangeNotifier {
  final api = Api();
  List<Category> categoriesList = [];
  List<Meal> mealsList = [];
  Set<String> favorites = {};
  String selected = 'Beef';
  bool loading = true;
  String? error;
  String search = '';
  AppState() { _init(); }
  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    favorites = (p.getStringList('favorites') ?? []).toSet();
    await loadCategories();
  }
  Future<void> loadCategories() async {
    loading = true; error = null; notifyListeners();
    try { categoriesList = await api.categories(); if (categoriesList.isNotEmpty && !categoriesList.any((c) => c.name == selected)) selected = categoriesList.first.name; await loadMeals(); }
    catch (_) { error = 'Unable to connect. Check your internet and try again.'; loading = false; notifyListeners(); }
  }
  Future<void> loadMeals() async {
    loading = true; error = null; notifyListeners();
    try { mealsList = await api.meals(selected, query: search); }
    catch (_) { error = 'Something went wrong while loading recipes.'; }
    loading = false; notifyListeners();
  }
  void choose(String value) { selected = value; search = ''; loadMeals(); }
  void setSearch(String value) { search = value; if (value.trim().isEmpty) loadMeals(); else _searchDebounced(value); }
  Future<void> _searchDebounced(String value) async { await Future.delayed(const Duration(milliseconds: 450)); if (value == search) await loadMeals(); }
  Future<void> toggleFavorite(String id) async { if (favorites.contains(id)) favorites.remove(id); else favorites.add(id); notifyListeners(); final p = await SharedPreferences.getInstance(); await p.setStringList('favorites', favorites.toList()); }
  bool isFavorite(String id) => favorites.contains(id);
}

void main() => runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const PantomMealsApp()));

class PantomMealsApp extends StatelessWidget { const PantomMealsApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, title: 'Pantom Meals', theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: bg, colorScheme: ColorScheme.fromSeed(seedColor: mint, brightness: Brightness.dark), fontFamily: 'sans'), home: const OnboardingGate());
}

class OnboardingGate extends StatefulWidget { const OnboardingGate({super.key}); @override State<OnboardingGate> createState() => _OnboardingGateState(); }
class _OnboardingGateState extends State<OnboardingGate> {
  bool? completed;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final prefs = await SharedPreferences.getInstance(); if (mounted) setState(() => completed = prefs.getBool('onboarding_complete') ?? false); }
  @override Widget build(BuildContext context) { if (completed == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: mint))); return completed! ? const HomePage() : OnboardingPage(onComplete: () => setState(() => completed = true)); }
}

class OnboardingPage extends StatefulWidget { final VoidCallback onComplete; const OnboardingPage({super.key, required this.onComplete}); @override State<OnboardingPage> createState() => _OnboardingPageState(); }
class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController(); int page = 0;
  final titles = const ['Discover something delicious', 'Cook with confidence', 'Your recipe space'];
  final descriptions = const ['Explore beautifully presented recipes from around the world.', 'See ingredients, measurements, and clear instructions in one place.', 'Save favorites and find your next meal whenever inspiration strikes.'];
  final icons = const [Icons.explore_rounded, Icons.menu_book_rounded, Icons.favorite_rounded];
  Future<void> finish() async { final prefs = await SharedPreferences.getInstance(); await prefs.setBool('onboarding_complete', true); widget.onComplete(); }
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 20), child: Column(children: [Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.restaurant_rounded, color: bg)), const SizedBox(width: 12), const Text('Pantom Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const Spacer(), Text('${page + 1}/3', style: const TextStyle(color: muted, fontWeight: FontWeight.w700))]), Expanded(child: PageView.builder(controller: controller, itemCount: titles.length, onPageChanged: (value) => setState(() => page = value), itemBuilder: (_, index) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 160, height: 160, decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(48)), child: Icon(icons[index], size: 76, color: mint)), const SizedBox(height: 44), Text(titles[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, height: 1.08, fontWeight: FontWeight.w800)), const SizedBox(height: 16), Text(descriptions[index], textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 16, height: 1.5))])), Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(titles.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 180), margin: const EdgeInsets.symmetric(horizontal: 4), width: index == page ? 28 : 8, height: 8, decoration: BoxDecoration(color: index == page ? mint : surface2, borderRadius: BorderRadius.circular(8))))), const SizedBox(height: 28), SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: page == titles.length - 1 ? finish : () => controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut), style: FilledButton.styleFrom(backgroundColor: mint, foregroundColor: bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(page == titles.length - 1 ? 'Get started' : 'Continue', style: const TextStyle(fontWeight: FontWeight.w800)))), const SizedBox(height: 12), TextButton(onPressed: finish, child: const Text('Skip', style: TextStyle(color: muted))) ])));
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  final search = TextEditingController();
  int tab = 0;
  @override void dispose() { search.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { final s = context.watch<AppState>(); final visibleMeals = tab == 0 ? s.mealsList : s.mealsList.where((m) => s.isFavorite(m.id)).toList(); return Scaffold(body: SafeArea(child: RefreshIndicator(color: mint, backgroundColor: surface, onRefresh: s.loadMeals, child: CustomScrollView(slivers: [
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 8), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.restaurant_rounded, color: bg, size: 24)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pantom', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), Text('MEALS', style: TextStyle(color: mint, fontSize: 11, letterSpacing: 2.4, fontWeight: FontWeight.bold))])), Container(decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)), child: IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)))]))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Find your next', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)), const Text('favorite recipe.', style: TextStyle(fontSize: 28, color: mint, fontWeight: FontWeight.w800)), const SizedBox(height: 20), TextField(controller: search, onChanged: s.setSearch, decoration: InputDecoration(hintText: 'Search recipes...', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: search.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close), onPressed: () { search.clear(); s.setSearch(''); setState(() {}); }) : null, filled: true, fillColor: surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 18))).also((_) => setState(() {}))]))),
    if (s.search.isEmpty && tab == 0) SliverToBoxAdapter(child: CategoryStrip(state: s)),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 14), child: Row(children: [Text(s.search.isNotEmpty ? 'Search results' : '${s.selected} recipes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const Spacer(), if (!s.loading) Text('${s.mealsList.length} meals', style: const TextStyle(color: muted, fontSize: 13))]))),
    if (s.loading) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: mint)))),
    if (!s.loading && s.error != null) SliverToBoxAdapter(child: ErrorView(message: s.error!, retry: s.loadMeals)),
    if (!s.loading && s.error == null && visibleMeals.isEmpty) SliverToBoxAdapter(child: EmptyView(message: tab == 1 ? 'Your favorite recipes will appear here' : 'No recipes found')),
    if (!s.loading && s.error == null && visibleMeals.isNotEmpty) SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 112), sliver: SliverGrid(delegate: SliverChildBuilderDelegate((_, i) => MealCard(meal: visibleMeals[i]), childCount: visibleMeals.length), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 16, childAspectRatio: .68)))
  ])))); }, bottomNavigationBar: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: _FloatingNav(selected: tab, onChanged: (value) => setState(() => tab = value))) ); }
}

class CategoryStrip extends StatelessWidget { final AppState state; const CategoryStrip({super.key, required this.state}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: SizedBox(height: 104, child: state.categoriesList.isEmpty ? const SizedBox() : ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal, itemCount: state.categoriesList.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) { final c = state.categoriesList[i]; final active = c.name == state.selected; return GestureDetector(onTap: () => state.choose(c.name), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 92, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: active ? mint : surface, borderRadius: BorderRadius.circular(20)), child: Column(children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(c.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: surface2))), const SizedBox(height: 5), Text(c.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? bg : Colors.white))]))); } })); }

class _FloatingNav extends StatelessWidget { final int selected; final ValueChanged<int> onChanged; const _FloatingNav({required this.selected, required this.onChanged}); @override Widget build(BuildContext context) => Container(height: 68, padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: surface2.withOpacity(.97), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.32), blurRadius: 24, offset: const Offset(0, 10))]), child: Row(children: [Expanded(child: _NavItem(icon: Icons.home_rounded, label: 'Home', active: selected == 0, onTap: () => onChanged(0))), Expanded(child: _NavItem(icon: Icons.favorite_rounded, label: 'Favorites', active: selected == 1, onTap: () => onChanged(1)))])); }
class _NavItem extends StatelessWidget { final IconData icon; final String label; final bool active; final VoidCallback onTap; const _NavItem({required this.icon, required this.label, required this.active, required this.onTap}); @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 180), decoration: BoxDecoration(color: active ? mint : Colors.transparent, borderRadius: BorderRadius.circular(19)), padding: const EdgeInsets.symmetric(vertical: 9), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 20, color: active ? bg : muted), if (active) ...[const SizedBox(width: 7), Text(label, style: const TextStyle(color: bg, fontWeight: FontWeight.w800, fontSize: 12))]])); }

class MealCard extends StatelessWidget { final Meal meal; const MealCard({super.key, required this.meal}); @override Widget build(BuildContext context) { final s = context.watch<AppState>(); return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(meal: meal))), child: Container(decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.network(meal.thumb, width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: surface2))), Positioned(top: 10, right: 10, child: GestureDetector(onTap: () => s.toggleFavorite(meal.id), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg.withOpacity(.78), shape: BoxShape.circle), child: Icon(s.isFavorite(meal.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18, color: s.isFavorite(meal.id) ? mint : Colors.white))))])), Padding(padding: const EdgeInsets.fromLTRB(13, 12, 10, 14), child: Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2))) ]))); } }

class DetailPage extends StatelessWidget { final Meal meal; const DetailPage({super.key, required this.meal}); @override Widget build(BuildContext context) { final s = context.watch<AppState>(); return Scaffold(body: CustomScrollView(slivers: [SliverAppBar(expandedHeight: 330, pinned: true, backgroundColor: bg, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)), actions: [IconButton(onPressed: () => s.toggleFavorite(meal.id), icon: Icon(s.isFavorite(meal.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: mint))], flexibleSpace: FlexibleSpaceBar(background: Image.network(meal.thumb, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: surface2)))), SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 40), child: FutureBuilder<Meal>(future: Api().detail(meal.id), builder: (context, snap) { if (!snap.hasData) return const Center(child: Padding(padding: EdgeInsets.all(35), child: CircularProgressIndicator(color: mint))); final m = snap.data!; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)), const SizedBox(height: 14), Wrap(spacing: 8, children: [if (m.category != null) Tag(text: m.category!), if (m.area != null) Tag(text: m.area!)]), const SizedBox(height: 30), const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 12), ...m.ingredients.map((x) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: [Container(width: 7, height: 7, decoration: const BoxDecoration(color: mint, shape: BoxShape.circle)), const SizedBox(width: 12), Expanded(child: Text(x.name, style: const TextStyle(fontSize: 15))), Text(x.measure, style: const TextStyle(color: muted, fontSize: 13))]))), const SizedBox(height: 24), const Text('Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Text(m.instructions ?? 'No instructions available.', style: const TextStyle(color: muted, fontSize: 15, height: 1.6))]); }))) ])); } }
class Tag extends StatelessWidget { final String text; const Tag({super.key, required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(color: mint, fontSize: 12, fontWeight: FontWeight.w700))); }
class ErrorView extends StatelessWidget { final String message; final VoidCallback retry; const ErrorView({super.key, required this.message, required this.retry}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(children: [const Icon(Icons.wifi_off_rounded, size: 44, color: muted), const SizedBox(height: 16), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: muted)), const SizedBox(height: 18), FilledButton(onPressed: retry, style: FilledButton.styleFrom(backgroundColor: mint, foregroundColor: bg), child: const Text('Retry'))]))); }
class EmptyView extends StatelessWidget { final String message; const EmptyView({super.key, this.message = 'No recipes found'}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(children: [const Icon(Icons.restaurant_menu_rounded, size: 42, color: muted), const SizedBox(height: 14), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: muted))]))); }
extension<T> on T { T also(void Function(T) action) { action(this); return this; } }

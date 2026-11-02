import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../pages/home_page.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});
  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? completed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted)
      setState(() => completed = prefs.getBool('onboarding_complete') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (completed == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: mint)));
    }
    return completed!
        ? const HomePage()
        : OnboardingPage(onComplete: () => setState(() => completed = true));
  }
}

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingPage({super.key, required this.onComplete});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final pageController = PageController();
  int page = 0;
  final titles = const [
    'Discover delicious recipes',
    'Cook with confidence',
    'Save your favorites'
  ];
  final descriptions = const [
    'Explore meals from around the world.',
    'Ingredients and instructions in one place.',
    'Keep your best recipes close at hand.'
  ];
  final art = const [
    'assets/onboarding/onboarding_1.png',
    'assets/onboarding/onboarding_2.png',
    'assets/onboarding/onboarding_3.png'
  ];

  Future<void> finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Row(children: [
                const Text('Pantom Meals',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${page + 1}/3', style: const TextStyle(color: muted)),
              ]),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: titles.length,
                  onPageChanged: (value) => setState(() => page = value),
                  itemBuilder: (_, index) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(48)),
                        child: Image.asset(art[index], fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 36),
                      Text(titles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Text(descriptions[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: muted, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  titles.length,
                  (index) => Container(
                    width: index == page ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: index == page ? mint : surface2,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: page == titles.length - 1
                      ? finish
                      : () => pageController.nextPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOut),
                  style: FilledButton.styleFrom(
                      backgroundColor: mint, foregroundColor: bg),
                  child: Text(
                      page == titles.length - 1 ? 'Get started' : 'Continue'),
                ),
              ),
              TextButton(
                  onPressed: finish,
                  child: const Text('Skip', style: TextStyle(color: muted))),
            ]),
          ),
        ),
      );
}

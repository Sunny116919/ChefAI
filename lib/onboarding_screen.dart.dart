import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:ai_recipe_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. ADD THIS IMPORT

// Model class (no changes)
class OnboardingItem {
  final String lottieAsset;
  final String title;
  final String description;

  OnboardingItem({
    required this.lottieAsset,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  bool _isLastPage = false;

  final List<OnboardingItem> _onboardingData = [
    OnboardingItem(
      lottieAsset: 'assets/food_search.json',
      title: "Discover Endless Recipes",
      description:
          "Let our AI inspire you with thousands of unique recipes from around the world.",
    ),
    OnboardingItem(
      lottieAsset: 'assets/options.json',
      title: "Tailored to Your Taste",
      description:
          "Tell us your preferences and available ingredients. We'll find the perfect meal for you.",
    ),
    OnboardingItem(
      lottieAsset: 'assets/cooking.json',
      title: "Cook with Confidence",
      description:
          "Get step-by-step instructions from your AI assistant. Let's make something amazing!",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToHome(),
                child: Text(
                  'Skip',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _isLastPage = index == _onboardingData.length - 1;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _onboardingData[index];
                  return OnboardingPage(item: item);
                },
              ),
            ),
            // Bottom navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingData.length,
                    effect: ScaleEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      activeDotColor: const Color(0xFF00796B),
                      dotColor: Colors.grey.shade300,
                    ),
                  ),
                  _isLastPage
                      ? ElevatedButton(
                          onPressed: () => _navigateToHome(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                            backgroundColor: const Color(0xFF00796B),
                          ),
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // <-- 2. THIS FUNCTION IS NOW UPDATED
  void _navigateToHome() async {
    // Get the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    
    // Set the flag to true so this screen won't show again
    await prefs.setBool('hasSeenOnboarding', true);

    // Navigate to your CheckAuthPage to handle login/admin logic
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CheckAuthPage()),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The Modern Shape background
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(150),
              ),
            ),
            child: Center(
              child: Lottie.asset(item.lottieAsset, width: 300),
            ),
          ),
        ),
        // The text content on the white background
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(),
                const SizedBox(height: 16),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
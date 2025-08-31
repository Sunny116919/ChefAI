import 'dart:ui';
import 'package:ai_recipe_app/user%20pages/add_recipe_page.dart';
import 'package:ai_recipe_app/user%20pages/ai_recipe_page.dart';
import 'package:ai_recipe_app/user%20pages/category_recipe.dart';
import 'package:ai_recipe_app/user%20pages/favorites_page.dart';
import 'package:ai_recipe_app/user%20pages/my_recipe_page.dart';
import 'package:ai_recipe_app/user%20pages/profile_page.dart';
import 'package:ai_recipe_app/user%20pages/recipe_display_page.dart';
import 'package:ai_recipe_app/user%20pages/todays_recipe_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && mounted) {
          setState(() {
            _userName = userDoc.data()?['name'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: AnimationLimiter(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              title: Row(
                children: [
                  Icon(Icons.restaurant_menu, color: Colors.pink.shade400),
                  const SizedBox(width: 8),
                  const Text(
                    "Chef AI",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: "Profile",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildHeader(),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.auto_awesome,
                      title: "AI Recipe Search",
                      subtitle: "Create recipes with AI.",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF696EFF), Color(0xFFF7ABFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // ✅ Corrected typo from AireciepePage to AiRecipePage
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiRecipePage()),
                      ),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.today,
                      title: "Today's Suggestions",
                      subtitle: "Daily random recipes for you.",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TodaysRecipesPage(),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.menu_book,
                      title: "Browse Recipes",
                      subtitle: "Explore our curated collection.",
                      gradient: const LinearGradient(
                        colors: [Color(0xFFffb347), Color(0xFFffcc33)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecipeDisplayPage(),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.category,
                      title: "Category Recipes",
                      subtitle: "Browse recipes by category.",
                      gradient: const LinearGradient(
                        colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoryRecipePage(),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.favorite,
                      title: "Favorite Recipes",
                      subtitle: "Access your saved recipes.",
                      gradient: const LinearGradient(
                        colors: [Color(0xFFff758c), Color(0xFFff7eb3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.kitchen,
                      title: "My Recipes",
                      subtitle: "View and manage your submissions.",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF654ea3), Color(0xFFeaafc8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyRecipesPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRecipePage()),
        ),
        child: Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.1),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: const CustomFabLocation(),
    );
  }

  Widget _buildHeader() {
    final String displayName = _userName ?? 'Foodie';
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, $displayName 👋",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "What would you like to cook today?",
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 16 / 8.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFabLocation extends FloatingActionButtonLocation {
  const CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    const double bottomMargin = 40.0;
    const double rightMargin = 20.0; // Adjusted for better alignment
    final double fabX =
        geometry.scaffoldSize.width -
        geometry.floatingActionButtonSize.width -
        rightMargin;
    final double fabY =
        geometry.scaffoldSize.height -
        geometry.floatingActionButtonSize.height -
        bottomMargin;
    return Offset(fabX, fabY);
  }
}

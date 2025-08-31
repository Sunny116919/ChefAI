// lib/todays_recipes_page.dart

import 'dart:math';
import 'package:ai_recipe_app/user%20pages/recipe_detail_page.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Import for caching

class TodaysRecipesPage extends StatefulWidget {
  const TodaysRecipesPage({super.key});

  @override
  State<TodaysRecipesPage> createState() => _TodaysRecipesPageState();
}

class _TodaysRecipesPageState extends State<TodaysRecipesPage> {
  final ScrollController _categoryScrollController = ScrollController();
  List<String>? _categories;
  String? _selectedCategory;
  Future<List<Recipe>>? _todaysRecipesFuture;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final snapshot = await FirebaseFirestore.instance.collection('recipe').get();
    final allDiets = <String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['dietary_preferences'] is List) {
        allDiets.addAll(List<String>.from(data['dietary_preferences']));
      }
    }
    
    final fetchedCategories = allDiets.toList()..sort();

    if (mounted) {
      setState(() {
        _categories = fetchedCategories;
        _isLoadingCategories = false;
      });

      const defaultCategory = "Vegetarian";
      if (_categories != null && _categories!.contains(defaultCategory)) {
        _onCategorySelected(defaultCategory, isInitialLoad: true);
      } else if (_categories != null && _categories!.isNotEmpty) {
        _onCategorySelected(_categories!.first, isInitialLoad: true);
      }
    }
  }
  
  void _onCategorySelected(String category, {bool isInitialLoad = false}) {
    if (_selectedCategory == category && !isInitialLoad) return;
    setState(() {
      _selectedCategory = category;
      _todaysRecipesFuture = _fetchAndProcessTodaysRecipes(category);
      if (_categories != null) {
        _categories!.remove(category);
        _categories!.insert(0, category);
      }
    });

    if (!isInitialLoad && _categoryScrollController.hasClients) {
      _categoryScrollController.animateTo(0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }
  
  Future<List<Recipe>> _fetchAndProcessTodaysRecipes(String category) async {
    final snapshot = await FirebaseFirestore.instance.collection('recipe').where('dietary_preferences', arrayContains: category).get();
    final matchingRecipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
    final String dateSeed = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final random = Random(dateSeed.hashCode);
    matchingRecipes.shuffle(random);
    return matchingRecipes.take(5).toList();
  }
  
  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Today's Suggestions 🧑‍🍳"),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade100,
        centerTitle: true,
      ),
      body: _isLoadingCategories ? _buildShimmerLoader() : _buildContentLoaded(),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(width: 120, height: 24, color: Colors.white),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    label: Container(width: 80, height: 20, color: Colors.white),
                    backgroundColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentLoaded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            "Categories",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories?.length ?? 0,
                itemBuilder: (context, index) {
                  final category = _categories![index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => _onCategorySelected(category),
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                },
              ),
        ),
        const Divider(height: 32),
        Expanded(
          child: _buildRecipeDisplay(),
        ),
      ],
    );
  }

  Widget _buildRecipeDisplay() {
    if (_selectedCategory == null) {
      return const Center(
        child: Text(
          "Please select a category above.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return FutureBuilder<List<Recipe>>(
      future: _todaysRecipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No recipes found for today. Try again later!"));
        }
        final recipes = snapshot.data!;
        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recipes.length,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildRecipeCard(recipes[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe))),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              // ✅ UPDATED: Switched to CachedNetworkImage for better performance
              child: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                recipe.recipeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 6.0, color: Colors.black54)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
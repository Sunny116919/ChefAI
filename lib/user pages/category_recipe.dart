// lib/category_recipe_page.dart

import 'package:ai_recipe_app/services/list%20pages/cuisine_list_page.dart';
import 'package:ai_recipe_app/services/list%20pages/difficulty_list_page.dart';
import 'package:ai_recipe_app/services/list%20pages/health_goal_list_page.dart';
import 'package:ai_recipe_app/user%20pages/recipe_detail_page.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Import for caching

enum CategoryType { cuisine, healthGoal, difficulty }

class CategoryRecipePage extends StatefulWidget {
  const CategoryRecipePage({super.key});

  @override
  _CategoryRecipePageState createState() => _CategoryRecipePageState();
}

class _CategoryRecipePageState extends State<CategoryRecipePage> {
  CategoryType _selectedCategory = CategoryType.cuisine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Recipe Categories 🍲",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2.0,
        shadowColor: Colors.grey.shade100,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: _buildCategoryToggle(),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('recipe').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading recipes."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No recipes found."));
          }

          final allRecipes = snapshot.data!.docs
              .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
              
          return _buildCategorizedList(allRecipes);
        },
      ),
    );
  }

  Widget _buildCategoryToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: ToggleButtons(
        isSelected: [
          _selectedCategory == CategoryType.cuisine,
          _selectedCategory == CategoryType.healthGoal,
          _selectedCategory == CategoryType.difficulty,
        ],
        onPressed: (index) {
          setState(() {
            _selectedCategory = CategoryType.values[index];
          });
        },
        borderRadius: BorderRadius.circular(8.0),
        selectedBorderColor: Colors.deepOrange,
        selectedColor: Colors.white,
        fillColor: Colors.deepOrange.shade300,
        color: Colors.deepOrange.shade300,
        constraints: BoxConstraints(
          minHeight: 40.0,
          minWidth: (MediaQuery.of(context).size.width - 48) / 3,
        ),
        children: const [
          Text('Cuisine'),
          Text('Health Goal'),
          Text('Difficulty'),
        ],
      ),
    );
  }

  Widget _buildCategorizedList(List<Recipe> allRecipes) {
    Map<String, List<Recipe>> groupedRecipes;
    List<String> keys;

    switch (_selectedCategory) {
      case CategoryType.healthGoal:
        final allPairs = allRecipes.expand((recipe) {
          return recipe.healthGoals.map((goal) => MapEntry(goal, recipe));
        }).toList();
        groupedRecipes = groupBy(allPairs, (MapEntry<String, Recipe> pair) => pair.key)
            .map((key, value) => MapEntry(key, value.map((e) => e.value).toList()));
        keys = groupedRecipes.keys.toList()..sort();
        break;
      case CategoryType.difficulty:
        groupedRecipes = groupBy(allRecipes, (Recipe r) => r.difficulty);
        keys = groupedRecipes.keys.toList()..sort();
        break;
      case CategoryType.cuisine:
      default:
        groupedRecipes = groupBy(allRecipes, (Recipe r) => r.cuisine);
        keys = groupedRecipes.keys.toList()..sort();
        break;
    }

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final recipes = groupedRecipes[key] ?? [];
        if (recipes.isEmpty) return const SizedBox.shrink();
        return _buildCategorySection(context, key, recipes);
      },
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<Recipe> recipes) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Widget page;
                    switch (_selectedCategory) {
                      case CategoryType.healthGoal:
                        page = HealthGoalListPage(healthGoal: title);
                        break;
                      case CategoryType.difficulty:
                        page = DifficultyListPage(difficulty: title);
                        break;
                      case CategoryType.cuisine:
                      default:
                        page = CuisineListPage(cuisine: title);
                        break;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                  },
                  child: const Row(
                    children: [
                      Text("More", style: TextStyle(fontSize: 16)),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16.0),
              itemCount: recipes.length > 5 ? 5 : recipes.length,
              itemBuilder: (context, index) => _buildHorizontalRecipeCard(context, recipes[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED this widget to use CachedNetworkImage
  Widget _buildHorizontalRecipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.recipeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              recipe.cookingTime,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
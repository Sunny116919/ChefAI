// import 'dart:convert';
// import 'dart:math';
// import 'package:ai_recipe_app/services/recipe.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';

// // You will also need to import your FilterOptions model from its correct path
// // import 'package:ai_recipe_app/models/filter_options.dart';

// class RecipeService {
//   List<Recipe> _allRecipes = [];
  
//   List<Recipe> get allRecipes => _allRecipes;
  
//   List<String> allCuisines = [];
//   List<String> allDifficulties = ["Easy", "Medium", "Hard"];
//   List<String> allDiets = [];
//   List<String> allHealthGoals = [];

//   int _parseTime(String time) {
//     try {
//       return int.parse(time.replaceAll(RegExp(r'[^0-9]'), ''));
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<void> loadRecipes() async {
//     if (_allRecipes.isNotEmpty) return;
//     final String response = await rootBundle.loadString('assets/recipee.json');
//     final List<dynamic> data = json.decode(response);
//     _allRecipes = data.map((json) => Recipe.fromJson(json)).toList();

//     allCuisines = _allRecipes.map((r) => r.cuisine).toSet().toList()..sort();
//     allDiets = _allRecipes.expand((r) => r.dietaryPreferences).toSet().toList()..sort();
//     allHealthGoals = _allRecipes.expand((r) => r.healthGoals).toSet().toList()..sort();
//   }

//   Future<List<Recipe>> fetchRecipes({
//     required int page,
//     int limit = 10,
//     FilterOptions? filters,
//   }) async {
//     await loadRecipes();

//     List<Recipe> filteredRecipes = _allRecipes;

//     if (filters != null) {
//       filteredRecipes = _allRecipes.where((recipe) {
//         final isCuisineMatch = filters.cuisine == null || recipe.cuisine == filters.cuisine;
//         final isDifficultyMatch = filters.difficulty == null || recipe.difficulty == filters.difficulty;
//         final isTimeMatch = filters.maxCookingTime == null || _parseTime(recipe.cookingTime) <= filters.maxCookingTime!;
//         final isDietaryMatch = filters.dietaryPreferences.isEmpty || filters.dietaryPreferences.any((diet) => recipe.dietaryPreferences.contains(diet));
//         final isHealthGoalMatch = filters.healthGoals.isEmpty || filters.healthGoals.any((goal) => recipe.healthGoals.contains(goal));

//         return isCuisineMatch && isDifficultyMatch && isTimeMatch && isDietaryMatch && isHealthGoalMatch;
//       }).toList();
//     }
    
//     int startIndex = (page - 1) * limit;
//     if (startIndex >= filteredRecipes.length) {
//       return [];
//     }
//     int endIndex = startIndex + limit;
//     return filteredRecipes.sublist(startIndex, endIndex > filteredRecipes.length ? filteredRecipes.length : endIndex);
//   }

//   Future<List<Recipe>> fetchRecipesByIds({required List<int> ids}) async {
//     await loadRecipes();
//     if (ids.isEmpty) {
//       return [];
//     }
//     return _allRecipes.where((recipe) => ids.contains(recipe.id)).toList();
//   }

//   Future<List<Recipe>> fetchRecipesByCuisine(String cuisine) async {
//     await loadRecipes();
//     return _allRecipes.where((recipe) => recipe.cuisine == cuisine).toList();
//   }

//   Future<List<Recipe>> fetchRecipesByHealthGoal(String goal) async {
//     await loadRecipes();
//     return _allRecipes.where((recipe) => recipe.healthGoals.contains(goal)).toList();
//   }

//   Future<List<Recipe>> fetchRecipesByDifficulty(String difficulty) async {
//     await loadRecipes();
//     return _allRecipes.where((recipe) => recipe.difficulty == difficulty).toList();
//   }
  
//   // ✅ --- CHANGE 1: THIS METHOD IS UPDATED ---
//   /// Returns a list of all unique dietary preferences.
//   Future<List<String>> getTodaysRecipeCategories() async {
//     await loadRecipes();
//     // Now it only returns the diets, not the health goals.
//     return allDiets;
//   }

//   // ✅ --- CHANGE 2: THIS METHOD IS UPDATED ---
//   /// Gets a list of 5 random recipes for a given dietary preference.
//   Future<List<Recipe>> getTodaysRecipes({required String category, int count = 5}) async {
//     await loadRecipes();

//     // Now it only filters by dietary preferences.
//     List<Recipe> matchingRecipes = _allRecipes
//         .where((recipe) => recipe.dietaryPreferences.contains(category))
//         .toList();

//     // The daily random logic remains the same.
//     final String dateSeed = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     final random = Random(dateSeed.hashCode);
    
//     matchingRecipes.shuffle(random);
    
//     return matchingRecipes.take(count).toList();
//   }
// }
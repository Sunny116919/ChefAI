// class Recipe {
//   final int id;
//   final String recipeName;
//   final String imageUrl;
//   final String cookingTime;
//   final String difficulty;
//   final Map<String, dynamic> nutritionalInfo;
//   final List<String> dietaryPreferences;
//   final List<String> healthGoals;
//   final String cuisine;
//   final List<String> ingredients;
//   final List<String> cookingSteps;

//   Recipe({
//     required this.id,
//     required this.recipeName,
//     required this.imageUrl,
//     required this.cookingTime,
//     required this.difficulty,
//     required this.nutritionalInfo,
//     required this.dietaryPreferences,
//     required this.healthGoals,
//     required this.cuisine,
//     required this.ingredients,
//     required this.cookingSteps,
//   });

//   factory Recipe.fromJson(Map<String, dynamic> json) {
//     return Recipe(
//       id: json['id'],
//       recipeName: json['recipe_name'],
//       imageUrl: json['image_url'],
//       cookingTime: json['cooking_time'],
//       difficulty: json['difficulty'],
//       nutritionalInfo: json['nutritional_info'],
//       dietaryPreferences: List<String>.from(json['dietary_preferences']),
//       healthGoals: List<String>.from(json['health_goals']),
//       cuisine: json['cuisine'],
//       ingredients: List<String>.from(json['ingredients']),
//       cookingSteps: List<String>.from(json['cooking_steps']),
//     );
//   }
// }

// // --- UPDATED FilterOptions CLASS ---
// class FilterOptions {
//   String? cuisine;
//   String? difficulty;
//   double? maxCookingTime;

//   // For multi-selection
//   Set<String> dietaryPreferences;
//   Set<String> healthGoals;

//   FilterOptions({
//     this.cuisine,
//     this.difficulty,
//     this.maxCookingTime,
//     // Initialize with empty sets
//     Set<String>? dietaryPreferences,
//     Set<String>? healthGoals,
//   })  : this.dietaryPreferences = dietaryPreferences ?? {},
//         this.healthGoals = healthGoals ?? {};
// }



// lib/services/recipe.dart

class Recipe {
  final int id;
  final String recipeName;
  final String imageUrl;
  final String cookingTime;
  final String difficulty;
  final Map<String, dynamic> nutritionalInfo;
  final List<String> dietaryPreferences;
  final List<String> healthGoals;
  final String cuisine;
  final List<String> ingredients;
  final List<String> cookingSteps;

  Recipe({
    required this.id,
    required this.recipeName,
    required this.imageUrl,
    required this.cookingTime,
    required this.difficulty,
    required this.nutritionalInfo,
    required this.dietaryPreferences,
    required this.healthGoals,
    required this.cuisine,
    required this.ingredients,
    required this.cookingSteps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      recipeName: json['recipe_name'],
      imageUrl: json['image_url'] ?? json['recipe_image'], 
      cookingTime: json['cooking_time'],
      difficulty: json['difficulty'],
      nutritionalInfo: json['nutritional_info'],
      dietaryPreferences: List<String>.from(json['dietary_preferences']),
      healthGoals: List<String>.from(json['health_goals']),
      cuisine: json['cuisine'],
      ingredients: List<String>.from(json['ingredients']),
      cookingSteps: List<String>.from(json['cooking_steps']),
    );
  }
}

// ✅ THIS IS THE CORRECT AND ONLY PLACE FOR THIS CLASS
class FilterOptions {
  String? cuisine;
  String? difficulty;
  double? maxCookingTime;
  Set<String> dietaryPreferences;
  Set<String> healthGoals;

  FilterOptions({
    this.cuisine,
    this.difficulty,
    this.maxCookingTime,
    Set<String>? dietaryPreferences,
    Set<String>? healthGoals,
  })  : this.dietaryPreferences = dietaryPreferences ?? {},
        this.healthGoals = healthGoals ?? {};
}
// import 'package:ai_recipe_app/recipe_detail_page.dart';
// import 'package:ai_recipe_app/services/recipe.dart';
// import 'package:ai_recipe_app/services/recipe_service.dart';
// import 'package:flutter/material.dart';

// class CuisineListPage extends StatelessWidget {
//   final String cuisine;
//   final RecipeService _recipeService = RecipeService();

//   CuisineListPage({super.key, required this.cuisine});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("$cuisine Recipes"),
//         backgroundColor: Colors.white,
//         elevation: 1.0,
//       ),
//       body: FutureBuilder<List<Recipe>>(
//         future: _recipeService.fetchRecipesByCuisine(cuisine),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No recipes found for this cuisine."));
//           }

//           final recipes = snapshot.data!;
//           return GridView.builder(
//             padding: const EdgeInsets.all(12),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.8,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//             ),
//             itemCount: recipes.length,
//             itemBuilder: (context, index) {
//               final recipe = recipes[index];
//               return _buildRecipeCard(context, recipe);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 4,
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe))),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.network(
//               recipe.imageUrl,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.black.withOpacity(0.7), Colors.transparent],
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.center,
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 12,
//               left: 12,
//               right: 12,
//               child: Text(
//                 recipe.recipeName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   shadows: [Shadow(blurRadius: 4.0, color: Colors.black)],
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// lib/cuisine_list_page.dart

import 'package:ai_recipe_app/user%20pages/recipe_detail_page.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Import Firestore
import 'package:flutter/material.dart';

class CuisineListPage extends StatelessWidget {
  final String cuisine;
  // ❌ RecipeService is no longer needed here.

  const CuisineListPage({super.key, required this.cuisine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$cuisine Recipes"),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      // ✅ Changed FutureBuilder to work with Firestore's QuerySnapshot
      body: FutureBuilder<QuerySnapshot>(
        // ✅ New Firestore query to fetch recipes by cuisine
        future: FirebaseFirestore.instance
            .collection('recipe')
            .where('cuisine', isEqualTo: cuisine)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No recipes found for this cuisine."));
          }

          // ✅ Updated logic to handle the list of documents from Firestore
          final recipeDocs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: recipeDocs.length,
            itemBuilder: (context, index) {
              final doc = recipeDocs[index];
              // ✅ Create a Recipe object from the Firestore document data
              final recipe = Recipe.fromJson(doc.data() as Map<String, dynamic>);
              return _buildRecipeCard(context, recipe);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    // This widget did not need any changes.
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe))),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ✅ Updated image_url key to match your Firestore data
            Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                recipe.recipeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4.0, color: Colors.black)],
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
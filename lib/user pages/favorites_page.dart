// lib/favorites_page.dart

import 'package:ai_recipe_app/user%20pages/recipe_detail_page.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Import for caching

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // The future will now hold a QuerySnapshot from Firestore.
  late Future<QuerySnapshot?> _favoriteRecipesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch the list of favorites whenever the provider notifies of a change
    _loadFavorites();
  }

  void _loadFavorites() {
    final favoriteIds = Provider.of<RecipeProvider>(context).favoriteRecipeIds.toList();

    setState(() {
      if (favoriteIds.isEmpty) {
        // If there are no favorites, create a completed future with a null value
        _favoriteRecipesFuture = Future.value(null);
      } else {
        _favoriteRecipesFuture = FirebaseFirestore.instance
            .collection('recipe')
            .where('id', whereIn: favoriteIds)
            .get();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("My Favorites ❤️"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            centerTitle: true,
            elevation: 2.0,
            shadowColor: Colors.grey.shade100,
          ),
          body: FutureBuilder<QuerySnapshot?>(
            future: _favoriteRecipesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading your favorites."));
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      "You haven't saved any favorite recipes yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                );
              }

              final favoriteDocs = snapshot.data!.docs;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: favoriteDocs.length,
                itemBuilder: (context, index) {
                  final recipe = Recipe.fromJson(favoriteDocs[index].data() as Map<String, dynamic>);
                  return _buildFavoriteCard(recipe, recipeProvider);
                },
              );
            },
          ),
        );
      },
    );
  }

  // ✅ UPDATED this widget to use CachedNetworkImage
  Widget _buildFavoriteCard(Recipe recipe, RecipeProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(recipe: recipe),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: recipe.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
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
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red.shade400),
                onPressed: () {
                  provider.toggleFavorite(recipe.id);
                },
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
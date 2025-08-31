// // lib/recipe_display_page.dart

// import 'dart:async';
// import 'package:ai_recipe_app/services/providers%20and%20filters/filter_bottom_sheet.dart';
// import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
// import 'package:ai_recipe_app/services/providers%20and%20filters/recipe_provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'recipe_detail_page.dart';

// class RecipeDisplayPage extends StatefulWidget {
//   const RecipeDisplayPage({super.key});

//   @override
//   _RecipeDisplayPageState createState() => _RecipeDisplayPageState();
// }

// class _RecipeDisplayPageState extends State<RecipeDisplayPage> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     final provider = Provider.of<RecipeProvider>(context, listen: false);

//     // Listener for infinite scroll
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         provider.fetchMoreRecipes();
//       }
//     });

//     // ✅ UPDATED: Listener for the search bar to filter the grid in real-time
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   // ✅ UPDATED: This now triggers a full search after the user stops typing
//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       final provider = Provider.of<RecipeProvider>(context, listen: false);
//       provider.applySearchQuery(_searchController.text);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F5),
//       appBar: AppBar(
//         title: const Text(
//           "Recipe Finder 🌶️",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 1.0,
//         centerTitle: true,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(70.0),
//           child: _buildSearchBar(),
//         ),
//       ),
//       // ✅ REMOVED: The Stack and suggestion overlay are no longer needed
//       body: Consumer<RecipeProvider>(
//         builder: (context, provider, child) {
//           if (provider.recipes.isEmpty && provider.isLoading) {
//             return _buildShimmerGrid();
//           }
//           if (provider.recipes.isEmpty && !provider.isLoading) {
//             return const Center(
//               child: Text("No recipes found. Try a different search!"),
//             );
//           }
//           return _buildRecipeGrid(provider);
//         },
//       ),
//     );
//   }
  
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       child: TextField(
//         controller: _searchController,
//         // The onChanged listener now handles everything
//         decoration: InputDecoration(
//           hintText: 'Search for recipes...',
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.filter_list, color: Colors.grey),
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 builder: (context) => const FilterBottomSheet(),
//               );
//             },
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(vertical: 0),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30.0),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30.0),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//         ),
//       ),
//     );
//   }

//   // The rest of your widgets are unchanged
//   Widget _buildShimmerGrid() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: MasonryGridView.count(
//         padding: const EdgeInsets.all(12.0),
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         itemCount: 6,
//         itemBuilder: (context, index) {
//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 5,
//             clipBehavior: Clip.antiAlias,
//             child: Container(
//               height: 200.0 + (index % 3 * 30.0),
//               color: Colors.white,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRecipeGrid(RecipeProvider provider) {
//     return MasonryGridView.count(
//       controller: _scrollController,
//       padding: const EdgeInsets.all(12.0),
//       crossAxisCount: 2,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       itemCount: provider.recipes.length + (provider.hasMore ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index == provider.recipes.length) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//         final recipe = provider.recipes[index];
//         final height = 200.0 + (recipe.recipeName.length % 5 * 10.0);
//         return _buildRecipeCard(recipe, height);
//       },
//     );
//   }

//   Widget _buildRecipeCard(Recipe recipe, double height) {
//     final difficulty = recipe.difficulty;
//     final difficultyColor = _getDifficultyColor(difficulty);
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 5,
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => RecipeDetailPage(recipe: recipe),
//             ),
//           );
//         },
//         child: Stack(
//           children: [
//             Hero(
//               tag: 'recipe_image_${recipe.id}',
//               child: CachedNetworkImage(
//                 imageUrl: recipe.imageUrl,
//                 height: height,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) =>
//                     Container(color: Colors.grey[200]),
//                 errorWidget: (context, url, error) => const Center(
//                   child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
//                 ),
//               ),
//             ),
//             Container(
//               height: height,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.black.withOpacity(0.9), Colors.transparent],
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 10,
//               left: 10,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: difficultyColor,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   difficulty,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 12,
//               left: 12,
//               right: 12,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     recipe.recipeName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       shadows: [Shadow(blurRadius: 2.0, color: Colors.black87)],
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.timer_outlined,
//                         color: Colors.white70,
//                         size: 14,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           recipe.cookingTime,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Icon(
//                         Icons.public_outlined,
//                         color: Colors.white70,
//                         size: 14,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           recipe.cuisine,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getDifficultyColor(String difficulty) {
//     switch (difficulty.toLowerCase()) {
//       case 'easy':
//         return Colors.green;
//       case 'medium':
//         return Colors.orange;
//       case 'hard':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }




// lib/recipe_display_page.dart

import 'dart:async';
import 'package:ai_recipe_app/services/providers%20and%20filters/filter_bottom_sheet.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'recipe_detail_page.dart';

class RecipeDisplayPage extends StatefulWidget {
  const RecipeDisplayPage({super.key});

  @override
  _RecipeDisplayPageState createState() => _RecipeDisplayPageState();
}

class _RecipeDisplayPageState extends State<RecipeDisplayPage> {
  // ✅ ScrollController is needed again for infinite scroll
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RecipeProvider>(context, listen: false);

    // ✅ Listener for infinite scroll is restored
    _scrollController.addListener(() {
      // Fetch more when user is 200 pixels from the bottom
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.fetchMoreRecipes();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      // This now triggers a new query on Firestore
      provider.applySearchQuery(_searchController.text);
    });
  }

  Future<void> _refreshRecipes() async {
    await Provider.of<RecipeProvider>(context, listen: false).refreshRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Recipe Finder 🌶️",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: _buildSearchBar(),
        ),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          Widget content;
          // Show shimmer only on the very first load
          if (provider.recipes.isEmpty && provider.isLoading) {
            content = _buildShimmerGrid();
          } else if (provider.recipes.isEmpty && !provider.isLoading) {
            content = Stack(
              children: [
                ListView(),
                const Center(
                  child: Text("No recipes found. Try a different search!"),
                ),
              ],
            );
          } else {
            content = _buildRecipeGrid(provider);
          }
          
          return RefreshIndicator(
            onRefresh: _refreshRecipes,
            child: content,
          );
        },
      ),
    );
  }

  Widget _buildRecipeGrid(RecipeProvider provider) {
    return MasonryGridView.count(
      // ✅ Controller is re-added
      controller: _scrollController,
      padding: const EdgeInsets.all(12.0),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      // ✅ Item count includes a spot for the loading indicator at the end
      itemCount: provider.recipes.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // ✅ Logic to show a loading spinner at the bottom of the list
        if (index == provider.recipes.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final recipe = provider.recipes[index];
        final height = 200.0 + (recipe.recipeName.length % 5 * 10.0);
        return _buildRecipeCard(recipe, height);
      },
    );
  }

  // --- All other widgets (_buildSearchBar, _buildShimmerGrid, _buildRecipeCard, etc.) ---
  // --- remain exactly the same. They are included below for completeness. ---

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for recipes...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(12.0),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: 200.0 + (index % 3 * 30.0),
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, double height) {
    final difficulty = recipe.difficulty;
    final difficultyColor = _getDifficultyColor(difficulty);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(recipe: recipe),
            ),
          );
        },
        child: Stack(
          children: [
            Hero(
              tag: 'recipe_image_${recipe.id}',
              child: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  difficulty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black87)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.cookingTime,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.public_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.cuisine,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
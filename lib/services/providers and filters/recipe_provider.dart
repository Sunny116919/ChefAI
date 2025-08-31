// import 'dart:async';
// import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// // Your FilterOptions class must be defined in another file and imported
// // For example: import 'package:ai_recipe_app/services/filter_options.dart';

// class RecipeProvider extends ChangeNotifier {
//   User? currentUser;
//   late StreamSubscription<User?> _authSubscription;
  
//   // ✅ NEW: A master list to hold ALL recipes from the database
//   List<Recipe> _allRecipes = [];

//   // This list will now hold the VISIBLE recipes (after search/filter)
//   List<Recipe> recipes = [];
  
//   bool isLoading = false;
//   FilterOptions currentFilters = FilterOptions();
//   Set<int> favoriteRecipeIds = {};
//   String _searchQuery = '';

//   // ❗ REMOVED: Pagination logic is no longer needed for this approach
//   DocumentSnapshot? _lastDocument;
//   final int _pageSize = 10;
//   bool hasMore = true;

//   RecipeProvider() {
//     currentFilters = FilterOptions();
//     _authSubscription = FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
//   }

//   Future<void> _onUserChanged(User? user) async {
//     currentUser = user;
//     if (user == null) {
//       favoriteRecipeIds.clear();
//     } else {
//       await fetchFavorites();
//     }
//     // Fetches all recipes once
//     await fetchAllRecipes();
//   }
  
//   @override
//   void dispose() {
//     _authSubscription.cancel();
//     super.dispose();
//   }

//   Future<void> refreshRecipes() async {
//     await fetchAllRecipes();
//   }

//   // ✅ NEW: Fetches ALL recipes from Firestore one time
//   Future<void> fetchAllRecipes() async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       // Build the query with filters first
//       Query query = _buildQueryForInitialFetch();
//       final snapshot = await query.get();
      
//       _allRecipes = snapshot.docs
//           .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
//           .toList();
      
//       // Initially, the visible recipes are all the fetched recipes
//       recipes = List.from(_allRecipes);
//     } catch (e) {
//       print("Error fetching all recipes: $e");
//     }

//     isLoading = false;
//     notifyListeners();
//   }

//   // ✅ NEW: This now performs a fast, in-app, case-insensitive search
//   void applySearchQuery(String query) {
//     _searchQuery = query.trim().toLowerCase();
//     _performClientSideFiltering();
//   }
  
//   // Your original applyFilters function, now updated
//   void applyFilters(FilterOptions filters) {
//     currentFilters = filters;
//     _performClientSideFiltering();
//   }

//   // ✅ NEW: A single function to handle all in-app filtering
//   void _performClientSideFiltering() {
//     List<Recipe> filteredList = List.from(_allRecipes);

//     // Apply search query (case-insensitive)
//     if (_searchQuery.isNotEmpty) {
//       filteredList = filteredList.where((recipe) {
//         return recipe.recipeName.toLowerCase().contains(_searchQuery);
//       }).toList();
//     }

//     // Apply your existing filters
//     if (currentFilters.cuisine != null) {
//       filteredList = filteredList.where((r) => r.cuisine == currentFilters.cuisine).toList();
//     }
//     if (currentFilters.difficulty != null) {
//       filteredList = filteredList.where((r) => r.difficulty == currentFilters.difficulty).toList();
//     }
//     if (currentFilters.dietaryPreferences.isNotEmpty) {
//       filteredList = filteredList.where((r) => currentFilters.dietaryPreferences.any((pref) => r.dietaryPreferences.contains(pref))).toList();
//     }
//     if (currentFilters.healthGoals.isNotEmpty) {
//       filteredList = filteredList.where((r) => currentFilters.healthGoals.any((goal) => r.healthGoals.contains(goal))).toList();
//     }
    
//     recipes = filteredList;
//     notifyListeners();
//   }

//   // ✅ RENAMED & SIMPLIFIED: This helps build the initial query
//   Query _buildQueryForInitialFetch() {
//     Query query = FirebaseFirestore.instance.collection('recipe');

//     if (currentFilters.cuisine != null) {
//       query = query.where('cuisine', isEqualTo: currentFilters.cuisine);
//     }
//     if (currentFilters.difficulty != null) {
//       query = query.where('difficulty', isEqualTo: currentFilters.difficulty);
//     }
//     if (currentFilters.dietaryPreferences.isNotEmpty) {
//       query = query.where('dietary_preferences', arrayContainsAny: currentFilters.dietaryPreferences.toList());
//     }
    
//     // No search query here because search happens inside the app
//     if (!_areFiltersActive()) {
//       query = query.orderBy('id');
//     }
//     return query;
//   }

//   // Your favorites logic remains unchanged
//   Future<void> fetchFavorites() async {
//     if (currentUser == null) return;
//     try {
//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
//       if (userDoc.exists && userDoc.data()!.containsKey('favorites')) {
//         final List<dynamic> favs = userDoc.data()!['favorites'];
//         favoriteRecipeIds = favs.map((id) => id is int ? id : int.parse(id.toString())).toSet();
//       } else {
//         favoriteRecipeIds.clear();
//       }
//       notifyListeners();
//     } catch (e) {
//       print("Error fetching favorites: $e");
//     }
//   }

//   Future<void> toggleFavorite(int recipeId) async {
//     if (currentUser == null) return;
//     final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

//     if (favoriteRecipeIds.contains(recipeId)) {
//       favoriteRecipeIds.remove(recipeId);
//       await userRef.set({'favorites': FieldValue.arrayRemove([recipeId])}, SetOptions(merge: true));
//     } else {
//       favoriteRecipeIds.add(recipeId);
//       await userRef.set({'favorites': FieldValue.arrayUnion([recipeId])}, SetOptions(merge: true));
//     }
//     notifyListeners();
//   }
  
//   bool isFavorite(int recipeId) {
//     return favoriteRecipeIds.contains(recipeId);
//   }
  
//   bool _areFiltersActive() {
//     return currentFilters.cuisine != null ||
//            currentFilters.difficulty != null ||
//            currentFilters.dietaryPreferences.isNotEmpty ||
//            currentFilters.healthGoals.isNotEmpty;
//   }
  
//   // ❗ REMOVED: fetchMoreRecipes is no longer used

//   Query _buildQuery() {
//     Query query = FirebaseFirestore.instance.collection('recipe');

//     if (currentFilters.cuisine != null) {
//       query = query.where('cuisine', isEqualTo: currentFilters.cuisine);
//     }
//     if (currentFilters.difficulty != null) {
//       query = query.where('difficulty', isEqualTo: currentFilters.difficulty);
//     }
    
//     if (currentFilters.dietaryPreferences.isNotEmpty) {
//       query = query.where('dietary_preferences', arrayContainsAny: currentFilters.dietaryPreferences.toList());
//     }
    
//     if (!_areFiltersActive()) {
//       query = query.orderBy('id');
//     }

//     return query;
//   }

//   Future<void> fetchMoreRecipes() async {
//     if (isLoading || !hasMore) return;
//     isLoading = true;
//     notifyListeners();

//     final snapshot = await _buildQuery().startAfterDocument(_lastDocument!).limit(_pageSize).get();
    
//     if (snapshot.docs.isNotEmpty) {
//       _lastDocument = snapshot.docs.last;
//       final newRecipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>)).toList();
//       recipes.addAll(newRecipes);
//     }

//     if (snapshot.docs.length < _pageSize) {
//       hasMore = false;
//     }

//     isLoading = false;
//     notifyListeners();
//   }
// }



// lib/services/providers and filters/recipe_provider.dart

// lib/services/providers and filters/recipe_provider.dart

import 'dart:async';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeProvider extends ChangeNotifier {
  User? currentUser;
  late StreamSubscription<User?> _authSubscription;
  
  List<Recipe> recipes = [];
  
  bool isLoading = false;
  FilterOptions currentFilters = FilterOptions();
  Set<int> favoriteRecipeIds = {};
  String _searchQuery = '';

  DocumentSnapshot? _lastDocument;
  final int _pageSize = 10;
  bool hasMore = true;

  RecipeProvider() {
    currentFilters = FilterOptions();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
  }

  Future<void> _onUserChanged(User? user) async {
    currentUser = user;
    if (user == null) {
      favoriteRecipeIds.clear();
    } else {
      await fetchFavorites();
    }
    await fetchInitialRecipes();
  }
  
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('recipe');

    if (currentFilters.cuisine != null) {
      query = query.where('cuisine', isEqualTo: currentFilters.cuisine);
    }
    if (currentFilters.difficulty != null) {
      query = query.where('difficulty', isEqualTo: currentFilters.difficulty);
    }
    if (currentFilters.dietaryPreferences.isNotEmpty) {
      query = query.where('dietary_preferences', arrayContainsAny: currentFilters.dietaryPreferences.toList());
    }
    if (currentFilters.healthGoals.isNotEmpty) {
      query = query.where('health_goals', arrayContainsAny: currentFilters.healthGoals.toList());
    }
    
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('recipeName', isGreaterThanOrEqualTo: _searchQuery)
          .where('recipeName', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    if (_searchQuery.isNotEmpty) {
        query = query.orderBy('recipeName');
    } else {
        query = query.orderBy('id');
    }

    return query;
  }

  Future<void> fetchInitialRecipes() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      Query query = _buildQuery();
      // ✅ FIX: Force the query to get data from the server
      final snapshot = await query.limit(_pageSize).get(const GetOptions(source: Source.server));
      
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        recipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>)).toList();
      } else {
        recipes = [];
      }

      hasMore = snapshot.docs.length == _pageSize;

    } catch (e) {
      print("Error fetching initial recipes: $e");
    } finally {
      // Use finally to guarantee isLoading is set to false
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreRecipes() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      Query query = _buildQuery();
      // ✅ FIX: Also apply the server-only fetch here
      final snapshot = await query.startAfterDocument(_lastDocument!).limit(_pageSize).get(const GetOptions(source: Source.server));
      
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newRecipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>)).toList();
        recipes.addAll(newRecipes);
      }

      hasMore = snapshot.docs.length == _pageSize;

    } catch (e) {
      print("Error fetching more recipes: $e");
    } finally {
      // Use finally to guarantee isLoading is set to false
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRecipes() async {
    recipes.clear();
    _lastDocument = null;
    hasMore = true;
    await fetchInitialRecipes();
  }

  void applySearchQuery(String query) {
    _searchQuery = query.trim();
    refreshRecipes();
  }
  
  void applyFilters(FilterOptions filters) {
    currentFilters = filters;
    refreshRecipes();
  }
  
  // --- Favorites Logic (Unchanged) ---
  Future<void> fetchFavorites() async {
    if (currentUser == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists && userDoc.data()!.containsKey('favorites')) {
        final List<dynamic> favs = userDoc.data()!['favorites'];
        favoriteRecipeIds = favs.map((id) => id is int ? id : int.parse(id.toString())).toSet();
      } else {
        favoriteRecipeIds.clear();
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  Future<void> toggleFavorite(int recipeId) async {
    if (currentUser == null) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    if (favoriteRecipeIds.contains(recipeId)) {
      favoriteRecipeIds.remove(recipeId);
      await userRef.update({'favorites': FieldValue.arrayRemove([recipeId])});
    } else {
      favoriteRecipeIds.add(recipeId);
      await userRef.set({'favorites': FieldValue.arrayUnion([recipeId])}, SetOptions(merge: true));
    }
    notifyListeners();
  }
  
  bool isFavorite(int recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}
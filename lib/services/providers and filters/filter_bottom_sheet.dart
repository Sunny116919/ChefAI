// lib/services/filter_bottom_sheet.dart

import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _filterOptions;
  late Future<Map<String, List<String>>> _filterDataFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentFilters = Provider.of<RecipeProvider>(context, listen: false).currentFilters;
    _filterOptions = FilterOptions(
        cuisine: currentFilters.cuisine,
        difficulty: currentFilters.difficulty,
        dietaryPreferences: Set.from(currentFilters.dietaryPreferences),
        healthGoals: Set.from(currentFilters.healthGoals),
        maxCookingTime: currentFilters.maxCookingTime);
    _filterDataFuture = _loadFilterData();
  }

  Future<Map<String, List<String>>> _loadFilterData() async {
    final snapshot = await FirebaseFirestore.instance.collection('recipe').get();
    
    final allCuisines = <String>{};
    final allDiets = <String>{};
    final allHealthGoals = <String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['cuisine'] != null) {
        allCuisines.add(data['cuisine']);
      }
      if (data['dietary_preferences'] is List) {
        allDiets.addAll(List<String>.from(data['dietary_preferences']));
      }
      if (data['health_goals'] is List) {
        allHealthGoals.addAll(List<String>.from(data['health_goals']));
      }
    }

    return {
      'cuisines': allCuisines.toList()..sort(),
      'diets': allDiets.toList()..sort(),
      'healthGoals': allHealthGoals.toList()..sort(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<String>>>(
      future: _filterDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // To make the sheet look better while loading, give it a fixed height
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Could not load filter options."));
        }

        final filterData = snapshot.data!;
        final allCuisines = filterData['cuisines']!;
        final allDiets = filterData['diets']!;
        final allHealthGoals = filterData['healthGoals']!;
        final allDifficulties = ["Easy", "Medium", "Hard"];

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ ADDED: Header with Title and Reset Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Filters'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          // Resets all filters in the UI
                          _filterOptions = FilterOptions(); 
                        });
                      },
                      child: const Text("Reset"),
                    )
                  ],
                ),
                
                _buildSectionTitle('Cuisine & Difficulty'),
                DropdownButton<String?>(
                  value: _filterOptions.cuisine,
                  hint: const Text('All Cuisines'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Cuisines')),
                    ...allCuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (value) => setState(() => _filterOptions.cuisine = value),
                ),
                DropdownButton<String?>(
                  value: _filterOptions.difficulty,
                  hint: const Text('All Levels'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Levels')),
                    ...allDifficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                  ],
                  onChanged: (value) => setState(() => _filterOptions.difficulty = value),
                ),

                _buildMultiSelectChips('Health Goals', allHealthGoals, _filterOptions.healthGoals),
                _buildMultiSelectChips('Dietary Preferences', allDiets, _filterOptions.dietaryPreferences),
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<RecipeProvider>(context, listen: false).applyFilters(_filterOptions);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildMultiSelectChips(String title, List<String> options, Set<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
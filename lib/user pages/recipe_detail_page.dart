import 'dart:io';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

// ❌ REMOVED: Unused import for the deleted recipe_service.dart

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  // --- Implemented Share Function ---
  Future<void> _shareRecipeAsPdf(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final doc = pw.Document();
      final http.Response response = await http.get(Uri.parse(recipe.imageUrl));
      final pw.MemoryImage image = pw.MemoryImage(response.bodyBytes);
      final nutritionalInfo = recipe.nutritionalInfo;
      final font = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      doc.addPage(
        pw.Page(
          build: (pw.Context pdfContext) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(recipe.recipeName,
                      style: pw.TextStyle(font: boldFont, fontSize: 24)),
                  pw.SizedBox(height: 16),
                  pw.ClipRRect(
                    horizontalRadius: 8,
                    verticalRadius: 8,
                    child: pw.Image(image, fit: pw.BoxFit.cover, height: 200),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Time: ${recipe.cookingTime}',
                            style: pw.TextStyle(font: font)),
                        pw.Text('Difficulty: ${recipe.difficulty}',
                            style: pw.TextStyle(font: font)),
                        pw.Text('Cuisine: ${recipe.cuisine}',
                            style: pw.TextStyle(font: font)),
                      ]),
                  pw.SizedBox(height: 8),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            'Calories: ${nutritionalInfo['calories'] ?? 'N/A'} kcal',
                            style: pw.TextStyle(font: font)),
                        pw.Text(
                            'Protein: ${nutritionalInfo['protein'] ?? 'N/A'}',
                            style: pw.TextStyle(font: font)),
                        pw.Text('Fat: ${nutritionalInfo['fat'] ?? 'N/A'}',
                            style: pw.TextStyle(font: font)),
                        pw.Text('Carbs: ${nutritionalInfo['carbs'] ?? 'N/A'}',
                            style: pw.TextStyle(font: font)),
                      ]),
                  pw.Divider(height: 24),
                  pw.Text('Ingredients',
                      style: pw.TextStyle(font: boldFont, fontSize: 18)),
                  pw.SizedBox(height: 8),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: recipe.ingredients
                        .map((ingredient) => pw.Text('• $ingredient',
                            style: pw.TextStyle(font: font)))
                        .toList(),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text('Steps',
                      style: pw.TextStyle(font: boldFont, fontSize: 18)),
                  pw.SizedBox(height: 8),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: List<pw.Widget>.generate(
                      recipe.cookingSteps.length,
                      (index) {
                        final step = recipe.cookingSteps[index];
                        return pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Text('${index + 1}. $step',
                              style: pw.TextStyle(font: font)),
                        );
                      },
                    ),
                  ),
                ]);
          },
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/${recipe.recipeName.replaceAll(' ', '_')}_Recipe.pdf');
      await file.writeAsBytes(await doc.save());

      Navigator.of(context).pop();

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this delicious recipe for ${recipe.recipeName}!',
        subject: 'Recipe: ${recipe.recipeName}',
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share recipe: $e')),
      );
    }
  }

  // --- Corrected Download Function ---
  Future<void> _downloadRecipeAsPdf(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final doc = pw.Document();
      final http.Response response = await http.get(Uri.parse(recipe.imageUrl));
      final pw.MemoryImage image = pw.MemoryImage(response.bodyBytes);
      final nutritionalInfo = recipe.nutritionalInfo;
      final font = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      doc.addPage(
        pw.Page(
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(recipe.recipeName,
                    style: pw.TextStyle(font: boldFont, fontSize: 24)),
                pw.SizedBox(height: 16),
                pw.ClipRRect(
                  horizontalRadius: 8,
                  verticalRadius: 8,
                  child: pw.Image(image, fit: pw.BoxFit.cover, height: 200),
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Time: ${recipe.cookingTime}',
                          style: pw.TextStyle(font: font)),
                      pw.Text('Difficulty: ${recipe.difficulty}',
                          style: pw.TextStyle(font: font)),
                      pw.Text('Cuisine: ${recipe.cuisine}',
                          style: pw.TextStyle(font: font)),
                    ]),
                pw.SizedBox(height: 8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          'Calories: ${nutritionalInfo['calories'] ?? 'N/A'} kcal',
                          style: pw.TextStyle(font: font)),
                      pw.Text('Protein: ${nutritionalInfo['protein'] ?? 'N/A'}',
                          style: pw.TextStyle(font: font)),
                      pw.Text('Fat: ${nutritionalInfo['fat'] ?? 'N/A'}',
                          style: pw.TextStyle(font: font)),
                      pw.Text('Carbs: ${nutritionalInfo['carbs'] ?? 'N/A'}',
                          style: pw.TextStyle(font: font)),
                    ]),
                pw.Divider(height: 24),
                pw.Text('Ingredients',
                    style: pw.TextStyle(font: boldFont, fontSize: 18)),
                pw.SizedBox(height: 8),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: recipe.ingredients
                      .map(
                        (ingredient) => pw.Text('• $ingredient',
                            style: pw.TextStyle(font: font)),
                      )
                      .toList(),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Steps',
                    style: pw.TextStyle(font: boldFont, fontSize: 18)),
                pw.SizedBox(height: 8),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: List<pw.Widget>.generate(
                    recipe.cookingSteps.length,
                    (index) {
                      final step = recipe.cookingSteps[index];
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 4),
                        child: pw.Text('${index + 1}. $step',
                            style: pw.TextStyle(font: font)),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );

      await FileSaver.instance.saveAs(
        name: '${recipe.recipeName.replaceAll(' ', '_')} Recipe',
        bytes: await doc.save(),
        mimeType: MimeType.pdf,
        fileExtension: 'pdf',
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully!')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final bool isFavorited = recipeProvider.isFavorite(recipe.id);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                surfaceTintColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'recipe_image_${recipe.id}',
                        child: Image.network(
                          recipe.imageUrl,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.4),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 8,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorited
                                      ? Colors.red.shade400
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  recipeProvider.toggleFavorite(recipe.id);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.white),
                                onPressed: () => _shareRecipeAsPdf(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.download,
                                    color: Colors.white),
                                tooltip: "Download PDF",
                                onPressed: () => _downloadRecipeAsPdf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    recipe.recipeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  titlePadding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  centerTitle: true,
                ),
                leading: const BackButton(
                  color: Colors.white,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTags(),
                      const SizedBox(height: 24),
                      _buildSummarySection(),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle('Ingredients'),
                      _buildIngredientList(),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle('Cooking Steps'),
                      _buildStepsList(),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- All helper widgets below this point did not need changes ---

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

  Widget _buildSummarySection() {
    final nutritionalInfo = recipe.nutritionalInfo;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(Icons.timer, recipe.cookingTime, 'Cook Time'),
            _buildSummaryItem(
              Icons.bolt,
              recipe.difficulty,
              'Difficulty',
              color: _getDifficultyColor(recipe.difficulty),
            ),
            _buildSummaryItem(Icons.public, recipe.cuisine, 'Cuisine'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutritionItem(
              '${nutritionalInfo['calories']}',
              'kcal',
              Colors.red,
            ),
            _buildNutritionItem(
              nutritionalInfo['protein'],
              'Protein',
              Colors.green,
            ),
            _buildNutritionItem(nutritionalInfo['fat'], 'Fat', Colors.orange),
            _buildNutritionItem(nutritionalInfo['carbs'], 'Carbs', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTags() {
    final List<String> tags = [
      ...recipe.dietaryPreferences,
      ...recipe.healthGoals,
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.blueGrey.shade50,
              labelStyle: TextStyle(color: Colors.blueGrey.shade700),
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }

  Widget _buildNutritionItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label, {
    Color? color,
  }) {
    final itemColor = color ?? Colors.blueGrey;
    return Column(
      children: [
        Icon(icon, color: itemColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: itemColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIngredientList() {
    final List<String> ingredients = recipe.ingredients;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients
          .map(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStepsList() {
    final List<String> steps = recipe.cookingSteps;
    return Column(
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${index + 1}.",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  steps[index],
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

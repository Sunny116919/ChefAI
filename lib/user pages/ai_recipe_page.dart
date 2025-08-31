import 'package:ai_recipe_app/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';

class AiRecipePage extends StatefulWidget {
  const AiRecipePage({super.key});

  @override
  _AiRecipePageState createState() => _AiRecipePageState();
}

class _AiRecipePageState extends State<AiRecipePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _loading = false;

  // The core logic remains exactly the same
  void _generateRecipe() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final gemini = GeminiService();
      final ingredients = _controller.text.trim();
      // For best results, ask the AI to format the response in Markdown.
      // Example prompt: "Create a recipe with ${ingredients}. Format the recipe using Markdown."
      final recipe = await gemini.generateRecipe(ingredients);

      setState(() {
        _result = recipe;
      });
    } catch (e) {
      setState(() {
        _result = '### Oops! Something went wrong.\nFailed to get recipe: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // A soft background color
      appBar: AppBar(
        title: const Text(
          "Chef AI 🍳",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Input Field ---
            _buildInputField(),
            const SizedBox(height: 16),
            // --- Generate Button ---
            _buildGenerateButton(),
            const SizedBox(height: 24),
            // --- Result Display ---
            Expanded(child: _buildResultDisplay()),
          ],
        ),
      ),
    );
  }

  // A styled Text Field for better visual appeal
  Widget _buildInputField() {
    return TextField(
      controller: _controller,
      maxLines: 2,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'e.g., chicken, tomatoes, basil',
        labelText: 'What ingredients do you have?',
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        prefixIcon:
            const Icon(Icons.kitchen_outlined, color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
    );
  }

  // A styled button that feels more interactive
  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _generateRecipe,
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
      label: Text(
        _loading ? "Generating..." : "Create Recipe",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5.0,
      ),
    );
  }

  // Handles the different states: initial, loading, and result/error
  Widget _buildResultDisplay() {
    if (_loading) {
      return _buildLoadingIndicator();
    }

    if (_result.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ramen_dining_outlined, size: 80, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              "Let's cook something amazing!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black45),
            ),
          ],
        ),
      );
    }
    
    // Display result in a styled card with Markdown for rich text
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Markdown(
            data: _result,
            padding: const EdgeInsets.all(16.0),
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              p: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
              listBullet: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
      ),
    );
  }

  // A modern shimmer effect for loading state
  Widget _buildLoadingIndicator() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
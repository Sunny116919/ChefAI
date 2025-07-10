import 'package:ai_recipe_app/services/gemini_service.dart';
import 'package:flutter/material.dart';

class AireciepePage extends StatefulWidget {
  const AireciepePage({super.key});

  @override
  _AireciepePageState createState() => _AireciepePageState();
}

class _AireciepePageState extends State<AireciepePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _loading = false;

  void _generateRecipe() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final gemini = GeminiService();
      final ingredients = _controller.text.trim();
      final recipe = await gemini.generateRecipe(ingredients);

      setState(() {
        _result = recipe;
      });
    } catch (e) {
      setState(() {
        _result = 'Failed to get recipe: $e';
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
      appBar: AppBar(title: Text("AI Recipe Generator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter ingredients (comma-separated)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _generateRecipe,
              child: Text("Generate Recipe"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(
                        _result,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
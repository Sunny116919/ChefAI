import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecipeDisplayPage extends StatefulWidget {
  const RecipeDisplayPage({super.key});

  @override
  _RecipeDisplayPageState createState() => _RecipeDisplayPageState();
}

class _RecipeDisplayPageState extends State<RecipeDisplayPage> {
  List recipes = [];

  @override
  void initState() {
    super.initState();
    loadRecipeData();
  }

  Future<void> loadRecipeData() async {
    final String response = await rootBundle.loadString('assets/recipee.json');
    final data = await json.decode(response);
    setState(() {
      recipes = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Recipes")),
      body: recipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: recipes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          recipe['image_url'],
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 120),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          recipe['recipe_name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:ai_recipe_app/ai_reciepe_page.dart';
import 'package:ai_recipe_app/recipe_display_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // Import your main.dart for CheckAuthPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Redirect to the root which handles auth state
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CheckAuthPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AireciepePage()));
              },
              child: const Text("AI recipe search"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeDisplayPage()));
              },
              child: const Text("Display Recipe page"),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/bulk_upload_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BulkUploadPage extends StatefulWidget {
  const BulkUploadPage({super.key});

  @override
  State<BulkUploadPage> createState() => _BulkUploadPageState();
}

class _BulkUploadPageState extends State<BulkUploadPage> {
  bool _isLoading = false;

  Future<void> _uploadRecipes() async {
    setState(() => _isLoading = true);

    try {
      final String response = await rootBundle.loadString('assets/recipee.json');
      final List<dynamic> data = json.decode(response);

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      int count = 0;

      for (var recipeData in data) {
        // ✅ CHANGED: Get the 'id' field from the JSON
        final recipeId = recipeData['id'];

        if (recipeId != null) {
          // ✅ CHANGED: Create a document reference using the id, converting it to a string
          final docRef = firestore.collection('recipe').doc(recipeId.toString());
          
          batch.set(docRef, recipeData);
          count++;
        }
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Successfully uploaded $count recipes!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error uploading recipes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bulk Upload Recipes"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Press the button below to upload all recipes from your 'assets/recipes.json' file to the Firestore database.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload Recipes"),
                      onPressed: _uploadRecipes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
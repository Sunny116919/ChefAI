// lib/add_recipe_page.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  String? _difficultyValue;
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addIngredientField();
    _addStepField();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveRecipe() async {
    // --- VALIDATION CHECKS ---
    if (_imageFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image for your recipe.')),
        );
      }
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ✅ NEW: Filter out empty strings from the lists
    final ingredients = _ingredientControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    final steps = _stepControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();

    // ✅ NEW: Check if the ingredient and step lists are empty
    if (ingredients.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one ingredient.')),
        );
      }
      return;
    }

    if (steps.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one cooking step.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cloudinary = CloudinaryPublic('dl2qtn9nx', 'recipe_images', cache: false);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_imageFile!.path, resourceType: CloudinaryResourceType.Image),
      );
      final cloudinaryImageUrl = response.secureUrl;
      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance.collection('pending_recipe').add({
        'creatorId': user.uid,
        'creatorEmail': user.email,
        'recipeName': _nameController.text.trim(),
        'cookingTime': _timeController.text.trim(),
        'difficulty': _difficultyValue,
        'ingredients': ingredients, // Use the validated list
        'cookingSteps': steps,     // Use the validated list
        'recipe_image': cloudinaryImageUrl,
        'status': 'Pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe submitted for review!')),
      );
      Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recipe: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Your Recipe 🍳"),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildTextFormField(controller: _nameController, label: "Recipe Name"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextFormField(controller: _timeController, label: "Cooking Time (e.g., 30 mins)")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDifficultyDropdown()),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Ingredients"),
              _buildDynamicFieldList(
                  controllers: _ingredientControllers,
                  hintText: "e.g., 2 cups flour",
                  onRemove: _removeIngredientField),
              _buildAddMoreButton(onPressed: _addIngredientField),
              const SizedBox(height: 16),
              _buildSectionTitle("Cooking Steps"),
              _buildDynamicFieldList(
                  controllers: _stepControllers,
                  hintText: "e.g., Preheat oven to 350°F",
                  onRemove: _removeStepField,
                  isNumbered: true),
              _buildAddMoreButton(onPressed: _addStepField),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                    : const Text("Save Recipe", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ALL HELPER WIDGETS ---

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _imageFile == null ? Colors.grey.shade300 : Colors.teal, width: _imageFile == null ? 1 : 2),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Tap to add a photo", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label cannot be empty';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      value: _difficultyValue,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a difficulty';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Difficulty",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ["Easy", "Medium", "Hard"]
          .map((label) => DropdownMenuItem(
                value: label,
                child: Text(label),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _difficultyValue = value;
        });
      },
    );
  }

  Widget _buildDynamicFieldList({
    required List<TextEditingController> controllers,
    required String hintText,
    required Function(int) onRemove,
    bool isNumbered = false,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controllers.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers[index],
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: isNumbered ? "Step ${index + 1}" : "Ingredient ${index + 1}",
                  hintText: hintText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
              ),
            ),
            if (controllers.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => onRemove(index),
              ),
          ],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildAddMoreButton({required VoidCallback onPressed}) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: Colors.teal),
        label: const Text("Add More", style: TextStyle(color: Colors.teal)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
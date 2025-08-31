// lib/my_recipe_detail_page.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class MyRecipeDetailPage extends StatefulWidget {
  final DocumentSnapshot recipeDoc;
  const MyRecipeDetailPage({super.key, required this.recipeDoc});

  @override
  State<MyRecipeDetailPage> createState() => _MyRecipeDetailPageState();
}

class _MyRecipeDetailPageState extends State<MyRecipeDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _timeController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;
  String? _difficultyValue;

  late String _status;
  bool _isEditable = false;
  bool _isLoading = false;
  String? _imageUrl;
  
  // ✅ NEW: To hold the newly selected image file for preview
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    final data = widget.recipeDoc.data() as Map<String, dynamic>;

    // Fixed the case issue for status check
    _status = data['status']?.toLowerCase() ?? 'pending';
    _isEditable = _status == 'pending';
    
    _imageUrl = data['recipe_image'];
    _nameController = TextEditingController(text: data['recipeName'] ?? '');
    _timeController = TextEditingController(text: data['cookingTime'] ?? '');
    _difficultyValue = data['difficulty'];
    _ingredientControllers = (List<String>.from(data['ingredients'] ?? []))
        .map((item) => TextEditingController(text: item))
        .toList();
    _stepControllers = (List<String>.from(data['cookingSteps'] ?? []))
        .map((item) => TextEditingController(text: item))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    for (var c in _ingredientControllers) { c.dispose(); }
    for (var c in _stepControllers) { c.dispose(); }
    super.dispose();
  }

  // ✅ NEW: Function to pick an image and show it as a preview
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  // ✅ UPDATED: The "Apply Changes" function now handles the image upload
  Future<void> _applyChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Start with the original image URL
      String finalImageUrl = _imageUrl ?? '';

      // If a new image file has been selected, upload it to Cloudinary
      if (_newImageFile != null) {
        final cloudinary = CloudinaryPublic('dl2qtn9nx', 'recipe_images', cache: false);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_newImageFile!.path, resourceType: CloudinaryResourceType.Image),
        );
        // Get the new URL from the upload response
        finalImageUrl = response.secureUrl;
      }
      
      final updatedData = {
        'recipeName': _nameController.text.trim(),
        'cookingTime': _timeController.text.trim(),
        'difficulty': _difficultyValue,
        'ingredients': _ingredientControllers.map((c) => c.text.trim()).toList(),
        'cookingSteps': _stepControllers.map((c) => c.text.trim()).toList(),
        'recipe_image': finalImageUrl, // Update with the new or original URL
        'submittedAt': FieldValue.serverTimestamp(),
      };

      await widget.recipeDoc.reference.update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes applied successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply changes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_nameController.text),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildTextField(
                  controller: _nameController,
                  label: "Recipe Name",
                  readOnly: !_isEditable),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        controller: _timeController,
                        label: "Cooking Time",
                        readOnly: !_isEditable),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDifficultyDropdown()),
                ],
              ),
              const SizedBox(height: 24),
              _buildDynamicSection("Ingredients", _ingredientControllers),
              const SizedBox(height: 24),
              _buildDynamicSection("Cooking Steps", _stepControllers),
              const SizedBox(height: 32),
              if (_isEditable)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _applyChanges,
                    icon: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text("Apply Changes"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.pink.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ UPDATED: This widget now shows the new image preview and a conditional edit button
  Widget _buildImageSection() {
    // Determine which image to show: the new preview or the original one
    ImageProvider imageProvider;
    if (_newImageFile != null) {
      imageProvider = FileImage(_newImageFile!);
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_imageUrl!);
    } else {
      // Placeholder if there is no image
      imageProvider = const AssetImage('assets/placeholder.png'); // Make sure you have a placeholder asset
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image(
              image: imageProvider,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
            ),
          ),
          // Status Badge (moved to the left for better layout)
          Positioned(
            top: 12,
            left: 12,
            child: _buildStatusBadge(_status),
          ),
          // Edit Button (only appears if the recipe is editable)
          if (_isEditable)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.small(
                onPressed: _pickImage,
                tooltip: "Change Image",
                child: const Icon(Icons.edit),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green.shade400;
        text = 'Approved';
        break;
      case 'rejected':
      case 'failed':
        color = Colors.red.shade400;
        text = 'Rejected';
        break;
      case 'pending':
      default:
        color = Colors.amber.shade600;
        text = 'Pending';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: null,
      validator: (v) =>
          (v == null || v.isEmpty) ? "This field cannot be empty" : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      value: _difficultyValue,
      validator: (v) => v == null ? 'Please select a difficulty' : null,
      decoration: InputDecoration(
        labelText: "Difficulty",
        filled: true,
        fillColor: !_isEditable ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: ["Easy", "Medium", "Hard"]
          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
          .toList(),
      onChanged: !_isEditable
          ? null
          : (value) => setState(() => _difficultyValue = value),
    );
  }

  Widget _buildDynamicSection(
      String title, List<TextEditingController> controllers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _buildTextField(
                        controller: controllers[index],
                        label: "${title.substring(0, title.length - 1)} ${index + 1}",
                        readOnly: !_isEditable)),
                if (_isEditable)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent),
                    onPressed: () => setState(() {
                      controllers[index].dispose();
                      controllers.removeAt(index);
                    }),
                  ),
              ],
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        ),
        if (_isEditable)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () =>
                  setState(() => controllers.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: const Text("Add More"),
            ),
          ),
      ],
    );
  }
}
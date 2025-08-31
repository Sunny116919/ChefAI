// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ApprovalDetailPage extends StatefulWidget {
//   final DocumentSnapshot pendingRecipeDoc;

//   const ApprovalDetailPage({super.key, required this.pendingRecipeDoc});

//   @override
//   State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
// }

// class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
//   final _formKey = GlobalKey<FormState>();
//   // ❌ RecipeService is no longer needed.

//   // State management for all editable fields
//   late TextEditingController _nameController;
//   late TextEditingController _timeController;
//   late TextEditingController _cuisineController;
//   late TextEditingController _caloriesController;
//   late TextEditingController _proteinController;
//   late TextEditingController _fatController;
//   late TextEditingController _carbsController;

//   late List<TextEditingController> _ingredientControllers;
//   late List<TextEditingController> _stepControllers;

//   String? _difficultyValue;
//   Set<String> _selectedDiets = {};
//   Set<String> _selectedHealthGoals = {};
//   List<String> _allDiets = [];
//   List<String> _allHealthGoals = [];

//   File? _newImageFile;
//   String? _currentImageUrl;

//   @override
//   void initState() {
//     super.initState();
//     final data = widget.pendingRecipeDoc.data() as Map<String, dynamic>;

//     _nameController = TextEditingController(text: data['recipeName']);
//     _timeController = TextEditingController(text: data['cookingTime']);
//     _difficultyValue = data['difficulty'];
//     _currentImageUrl = data['recipe_image'];
//     _ingredientControllers = (List<String>.from(
//       data['ingredients'] ?? [],
//     )).map((item) => TextEditingController(text: item)).toList();
//     _stepControllers = (List<String>.from(
//       data['cookingSteps'] ?? [],
//     )).map((item) => TextEditingController(text: item)).toList();
//     _cuisineController = TextEditingController();
//     _caloriesController = TextEditingController();
//     _proteinController = TextEditingController();
//     _fatController = TextEditingController();
//     _carbsController = TextEditingController();

//     _loadChipData();
//   }

//   // ✅ UPDATED: This function now gets chip data from Firestore
//   Future<void> _loadChipData() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('recipe')
//         .get();

//     final allDiets = <String>{};
//     final allHealthGoals = <String>{};

//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       if (data['dietary_preferences'] is List) {
//         allDiets.addAll(List<String>.from(data['dietary_preferences']));
//       }
//       if (data['health_goals'] is List) {
//         allHealthGoals.addAll(List<String>.from(data['health_goals']));
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _allDiets = allDiets.toList()..sort();
//         _allHealthGoals = allHealthGoals.toList()..sort();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _timeController.dispose();
//     _cuisineController.dispose();
//     _caloriesController.dispose();
//     _proteinController.dispose();
//     _fatController.dispose();
//     _carbsController.dispose();
//     for (var controller in _ingredientControllers) {
//       controller.dispose();
//     }
//     for (var controller in _stepControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _newImageFile = File(pickedFile.path);
//       });
//     }
//   }

//   void _approveRecipe() {
//     if (_formKey.currentState!.validate()) {
//       print("Validation successful. Ready to approve.");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Recipe Approved (simulation)')),
//       );
//     }
//   }

//   void _rejectRecipe() {
//     print("Recipe rejected.");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Recipe Rejected (simulation)')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(_nameController.text),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildImageSection(),
//               const SizedBox(height: 24),
//               _buildSectionCard(
//                 title: "Recipe Details",
//                 icon: Icons.edit_note,
//                 child: Column(
//                   children: [
//                     _buildTextFormField(
//                       _nameController,
//                       "Recipe Name",
//                       icon: Icons.title,
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: _buildTextFormField(
//                             _timeController,
//                             "Cooking Time",
//                             icon: Icons.timer_outlined,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(child: _buildDifficultyDropdown()),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               _buildDynamicSectionCard(
//                 "Ingredients",
//                 _ingredientControllers,
//                 _addIngredientField,
//                 _removeIngredientField,
//                 "e.g., 2 cups flour",
//               ),
//               _buildDynamicSectionCard(
//                 "Cooking Steps",
//                 _stepControllers,
//                 _addStepField,
//                 _removeStepField,
//                 "e.g., Preheat oven...",
//                 isNumbered: true,
//               ),
//               _buildSectionCard(
//                 title: "Admin Details",
//                 icon: Icons.shield_outlined,
//                 child: Column(
//                   children: [
//                     _buildTextFormField(
//                       _cuisineController,
//                       "Cuisine",
//                       icon: Icons.ramen_dining,
//                     ),
//                     const SizedBox(height: 24),
//                     _buildSectionSubtitle("Nutritional Info"),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: _buildTextFormField(
//                             _caloriesController,
//                             "Calories",
//                             isNumeric: true,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: _buildTextFormField(
//                             _proteinController,
//                             "Protein (g)",
//                             isNumeric: true,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: _buildTextFormField(
//                             _fatController,
//                             "Fat (g)",
//                             isNumeric: true,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: _buildTextFormField(
//                             _carbsController,
//                             "Carbs (g)",
//                             isNumeric: true,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               _buildSectionCard(
//                 title: "Tags & Preferences",
//                 icon: Icons.tag,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionSubtitle("Dietary Preferences"),
//                     _buildMultiSelectChips(_allDiets, _selectedDiets),
//                     const SizedBox(height: 16),
//                     _buildSectionSubtitle("Health Goals"),
//                     _buildMultiSelectChips(
//                       _allHealthGoals,
//                       _selectedHealthGoals,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: _approveRecipe,
//                       icon: const Icon(Icons.check),
//                       label: const Text(
//                         "Approve",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: _rejectRecipe,
//                       icon: const Icon(Icons.close),
//                       label: const Text(
//                         "Reject",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- ALL HELPER WIDGETS ---

//   Widget _buildImageSection() {
//     final imageProvider =
//         (_newImageFile != null
//                 ? FileImage(_newImageFile!)
//                 : NetworkImage(_currentImageUrl!))
//             as ImageProvider;
//     return Center(
//       child: Stack(
//         children: [
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       FullScreenImageViewer(imageProvider: imageProvider),
//                 ),
//               );
//             },
//             child: Hero(
//               tag: 'recipeImage',
//               child: Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: Colors.grey.shade200,
//                   image: DecorationImage(
//                     fit: BoxFit.cover,
//                     image: imageProvider,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 8,
//             right: 8,
//             child: FloatingActionButton.small(
//               onPressed: _pickImage,
//               tooltip: "Change Image",
//               child: const Icon(Icons.edit),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionCard({
//     required String title,
//     required IconData icon,
//     required Widget child,
//   }) {
//     return Card(
//       color: Colors.grey.shade50,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 24),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.indigo),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             child,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDynamicSectionCard(
//     String title,
//     List<TextEditingController> controllers,
//     VoidCallback onAdd,
//     Function(int) onRemove,
//     String hintText, {
//     bool isNumbered = false,
//   }) {
//     return _buildSectionCard(
//       title: title,
//       icon: isNumbered ? Icons.list_alt : Icons.food_bank_outlined,
//       child: Column(
//         children: [
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: controllers.length,
//             itemBuilder: (context, index) {
//               return Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: _buildTextFormField(
//                       controllers[index],
//                       isNumbered
//                           ? "Step ${index + 1}"
//                           : "Ingredient ${index + 1}",
//                       hintText: hintText,
//                       isMultiLine: true,
//                     ),
//                   ),
//                   if (controllers.length > 1)
//                     IconButton(
//                       icon: Icon(
//                         Icons.remove_circle_outline,
//                         color: Colors.red.shade300,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           controllers[index].dispose();
//                           controllers.removeAt(index);
//                         });
//                       },
//                     ),
//                 ],
//               );
//             },
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//           ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton.icon(
//               onPressed: () => setState(() => onAdd()),
//               icon: const Icon(Icons.add),
//               label: const Text("Add More"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addIngredientField() =>
//       _ingredientControllers.add(TextEditingController());
//   void _removeIngredientField(int i) => _ingredientControllers[i].dispose();
//   void _addStepField() => _stepControllers.add(TextEditingController());
//   void _removeStepField(int i) => _stepControllers[i].dispose();

//   Widget _buildSectionSubtitle(String title) => Padding(
//     padding: const EdgeInsets.only(bottom: 8.0),
//     child: Text(
//       title,
//       style: const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: Colors.black54,
//       ),
//     ),
//   );

//   Widget _buildTextFormField(
//     TextEditingController controller,
//     String label, {
//     IconData? icon,
//     bool isNumeric = false,
//     String? hintText,
//     bool isMultiLine = false,
//   }) => TextFormField(
//     controller: controller,
//     keyboardType: isNumeric
//         ? TextInputType.number
//         : (isMultiLine ? TextInputType.multiline : TextInputType.text),
//     maxLines: isMultiLine ? null : 1,
//     validator: (value) {
//       if (value == null || value.trim().isEmpty)
//         return '$label cannot be empty';
//       return null;
//     },
//     decoration: InputDecoration(
//       labelText: label,
//       hintText: hintText,
//       prefixIcon: icon != null ? Icon(icon) : null,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       filled: true,
//       fillColor: Colors.white,
//     ),
//   );

//   Widget _buildDifficultyDropdown() => DropdownButtonFormField<String>(
//     value: _difficultyValue,
//     validator: (value) =>
//         (value == null || value.isEmpty) ? 'Please select a difficulty' : null,
//     decoration: InputDecoration(
//       labelText: "Difficulty",
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       filled: true,
//       fillColor: Colors.white,
//     ),
//     items: ["Easy", "Medium", "Hard"]
//         .map((label) => DropdownMenuItem(value: label, child: Text(label)))
//         .toList(),
//     onChanged: (value) => setState(() => _difficultyValue = value),
//   );

//   Widget _buildMultiSelectChips(
//     List<String> allOptions,
//     Set<String> selectedOptions,
//   ) => Wrap(
//     spacing: 8.0,
//     runSpacing: 4.0,
//     children: allOptions.map((option) {
//       final isSelected = selectedOptions.contains(option);
//       return FilterChip(
//         label: Text(option),
//         selected: isSelected,
//         backgroundColor: Colors.grey.shade200,
//         selectedColor: Colors.indigo.shade100,
//         checkmarkColor: Colors.indigo,
//         onSelected: (bool selected) {
//           setState(() {
//             if (selected) {
//               selectedOptions.add(option);
//             } else {
//               selectedOptions.remove(option);
//             }
//           });
//         },
//       );
//     }).toList(),
//   );
// }

// // ❌ FullScreenImageViewer class should be in its own file.

// class FullScreenImageViewer extends StatelessWidget {
//   final ImageProvider imageProvider;

//   const FullScreenImageViewer({super.key, required this.imageProvider});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ), // Makes the back button white
//       ),
//       body: Center(
//         child: InteractiveViewer(
//           panEnabled: true,
//           minScale: 0.5,
//           maxScale: 4.0,
//           child: Image(image: imageProvider),
//         ),
//       ),
//     );
//   }
// }

//
// ✅ COMPLETE AND VERIFIED CODE - PASTE THIS ENTIRE BLOCK
//

//
// ✅ FINAL, CORRECTED CODE - PASTE THIS ENTIRE FILE
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovalDetailPage extends StatefulWidget {
  final DocumentSnapshot pendingRecipeDoc;

  const ApprovalDetailPage({super.key, required this.pendingRecipeDoc});

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  final _formKey = GlobalKey<FormState>();

  // State management for all editable fields
  late TextEditingController _nameController;
  late TextEditingController _timeController;
  late TextEditingController _cuisineController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;

  String? _difficultyValue;
  Set<String> _selectedDiets = {};
  Set<String> _selectedHealthGoals = {};
  List<String> _allDiets = [];
  List<String> _allHealthGoals = [];

  String? _currentImageUrl;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final data = widget.pendingRecipeDoc.data() as Map<String, dynamic>;
    final nutritionalInfo =
        data['nutritional_info'] as Map<String, dynamic>? ?? {};

    _nameController = TextEditingController(text: data['recipeName'] ?? '');
    _timeController = TextEditingController(text: data['cookingTime'] ?? '');
    _cuisineController = TextEditingController(text: data['cuisine'] ?? '');
    _difficultyValue = data['difficulty'];
    _currentImageUrl = data['recipe_image'];

    _caloriesController = TextEditingController(
      text: (nutritionalInfo['calories'] ?? '').toString(),
    );
    _proteinController = TextEditingController(
      text: (nutritionalInfo['protein'] ?? '').toString(),
    );
    _fatController = TextEditingController(
      text: (nutritionalInfo['fat'] ?? '').toString(),
    );
    _carbsController = TextEditingController(
      text: (nutritionalInfo['carbs'] ?? '').toString(),
    );

    _ingredientControllers = (List<String>.from(
      data['ingredients'] ?? [],
    )).map((item) => TextEditingController(text: item)).toList();
    _stepControllers = (List<String>.from(
      data['cookingSteps'] ?? [],
    )).map((item) => TextEditingController(text: item)).toList();
    if (_ingredientControllers.isEmpty) {
      _ingredientControllers.add(TextEditingController());
    }
    if (_stepControllers.isEmpty) {
      _stepControllers.add(TextEditingController());
    }

    _selectedDiets = Set<String>.from(data['dietary_preferences'] ?? []);
    _selectedHealthGoals = Set<String>.from(data['health_goals'] ?? []);

    _loadChipData();
  }

  // ✅ SIMPLIFIED APPROVE LOGIC
  Future<void> _approveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isProcessing = true);

    try {
      // Step 1: Use the existing Cloudinary image URL. No upload needed.
      final String imageUrlToSave = _currentImageUrl ?? '';

      if (imageUrlToSave.isEmpty) {
        throw Exception("Recipe must have an image link.");
      }

      final firestore = FirebaseFirestore.instance;

      // Step 2: Get the next available ID for the 'recipe' collection.
      final query = await firestore
          .collection('recipe')
          .orderBy('id', descending: true)
          .limit(1)
          .get();
      int nextId = 1;
      if (query.docs.isNotEmpty) {
        nextId = (query.docs.first.data()['id'] as int) + 1;
      }

      // Step 3: Prepare all the data, using the original Cloudinary URL.
      final Map<String, dynamic> recipeData = {
        'id': nextId,
        'recipe_name': _nameController.text.trim(),
        'image_url': imageUrlToSave, // The original Cloudinary link
        'cooking_time': _timeController.text.trim(),
        'difficulty': _difficultyValue,
        'cuisine': _cuisineController.text.trim(),
        'ingredients': _ingredientControllers
            .map((c) => c.text.trim())
            .toList(),
        'cooking_steps': _stepControllers.map((c) => c.text.trim()).toList(),
        'dietary_preferences': _selectedDiets.toList(),
        'health_goals': _selectedHealthGoals.toList(),
        'nutritional_info': {
          'calories': int.tryParse(_caloriesController.text) ?? 0,
          'protein': _proteinController.text.trim(),
          'fat': _fatController.text.trim(),
          'carbs': _carbsController.text.trim(),
        },
      };

      // Step 4: Use a batch write for a safe transaction.
      final batch = firestore.batch();
      final newRecipeRef = firestore
          .collection('recipe')
          .doc(nextId.toString());
      batch.set(newRecipeRef, recipeData);
      final pendingRecipeRef = widget.pendingRecipeDoc.reference;
      batch.update(pendingRecipeRef, {'status': 'Approved'});
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe approved and published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print("Error approving recipe: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _rejectRecipe() async {
    setState(() => _isProcessing = true);
    try {
      await widget.pendingRecipeDoc.reference.update({'status': 'Rejected'});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe Rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print("Error rejecting recipe: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not reject recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- WIDGET AND HELPER METHODS ---

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _cuisineController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadChipData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('recipe')
        .get();
    final allDiets = <String>{};
    final allHealthGoals = <String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['dietary_preferences'] is List) {
        allDiets.addAll(List<String>.from(data['dietary_preferences']));
      }
      if (data['health_goals'] is List) {
        allHealthGoals.addAll(List<String>.from(data['health_goals']));
      }
    }

    if (mounted) {
      setState(() {
        _allDiets = allDiets.toList()..sort();
        _allHealthGoals = allHealthGoals.toList()..sort();
      });
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
      body: AbsorbPointer(
        absorbing: _isProcessing,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                _buildImageSection(),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: "Recipe Details",
                  icon: Icons.edit_note,
                  child: Column(
                    children: [
                      _buildTextFormField(
                        _nameController,
                        "Recipe Name",
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              _timeController,
                              "Cooking Time",
                              icon: Icons.timer_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDifficultyDropdown()),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildDynamicSectionCard(
                  "Ingredients",
                  _ingredientControllers,
                  () => setState(
                    () => _ingredientControllers.add(TextEditingController()),
                  ),
                  (index) {
                    setState(() {
                      _ingredientControllers[index].dispose();
                      _ingredientControllers.removeAt(index);
                    });
                  },
                  "e.g., 2 cups flour",
                ),
                _buildDynamicSectionCard(
                  "Cooking Steps",
                  _stepControllers,
                  () => setState(
                    () => _stepControllers.add(TextEditingController()),
                  ),
                  (index) {
                    setState(() {
                      _stepControllers[index].dispose();
                      _stepControllers.removeAt(index);
                    });
                  },
                  "e.g., Preheat oven...",
                  isNumbered: true,
                ),
                _buildSectionCard(
                  title: "Admin Details",
                  icon: Icons.shield_outlined,
                  child: Column(
                    children: [
                      _buildTextFormField(
                        _cuisineController,
                        "Cuisine",
                        icon: Icons.ramen_dining,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionSubtitle("Nutritional Info"),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              _caloriesController,
                              "Calories",
                              isNumeric: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              _proteinController,
                              "Protein (g)",
                              isNumeric: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              _fatController,
                              "Fat (g)",
                              isNumeric: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              _carbsController,
                              "Carbs (g)",
                              isNumeric: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  title: "Tags & Preferences",
                  icon: Icons.tag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionSubtitle("Dietary Preferences"),
                      _buildMultiSelectChips(_allDiets, _selectedDiets),
                      const SizedBox(height: 16),
                      _buildSectionSubtitle("Health Goals"),
                      _buildMultiSelectChips(
                        _allHealthGoals,
                        _selectedHealthGoals,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _approveRecipe,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          "Approve",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.green.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _rejectRecipe,
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text(
                          "Reject",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.red.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ This widget no longer has an edit button
  Widget _buildImageSection() {
    if (_currentImageUrl == null || _currentImageUrl!.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade200,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: Colors.grey,
              ),
              Text("No Image Provided"),
            ],
          ),
        ),
      );
    }

    final imageProvider = NetworkImage(_currentImageUrl!);

    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FullScreenImageViewer(imageProvider: imageProvider),
            ),
          );
        },
        child: Hero(
          tag: 'recipeImage',
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
              image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      color: Colors.grey.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSectionCard(
    String title,
    List<TextEditingController> controllers,
    VoidCallback onAdd,
    Function(int) onRemove,
    String hintText, {
    bool isNumbered = false,
  }) {
    return _buildSectionCard(
      title: title,
      icon: isNumbered ? Icons.list_alt : Icons.food_bank_outlined,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controllers.length,
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controllers[index],
                      isNumbered
                          ? "Step ${index + 1}"
                          : "Ingredient ${index + 1}",
                      hintText: hintText,
                      isMultiLine: true,
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red.shade300,
                      ),
                      onPressed: () => onRemove(index),
                    ),
                ],
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text("Add More"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    ),
  );

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    bool isNumeric = false,
    String? hintText,
    bool isMultiLine = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: isNumeric
        ? TextInputType.number
        : (isMultiLine ? TextInputType.multiline : TextInputType.text),
    maxLines: isMultiLine ? null : 1,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label cannot be empty';
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
  );

  Widget _buildDifficultyDropdown() => DropdownButtonFormField<String>(
    value: _difficultyValue,
    validator: (value) =>
        (value == null || value.isEmpty) ? 'Please select a difficulty' : null,
    decoration: InputDecoration(
      labelText: "Difficulty",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
    items: ["Easy", "Medium", "Hard"]
        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
        .toList(),
    onChanged: (value) => setState(() => _difficultyValue = value),
  );

  Widget _buildMultiSelectChips(
    List<String> allOptions,
    Set<String> selectedOptions,
  ) => Wrap(
    spacing: 8.0,
    runSpacing: 4.0,
    children: allOptions.map((option) {
      final isSelected = selectedOptions.contains(option);
      return FilterChip(
        label: Text(option),
        selected: isSelected,
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.indigo.shade100,
        checkmarkColor: Colors.indigo,
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
  );
}

class FullScreenImageViewer extends StatelessWidget {
  final ImageProvider imageProvider;

  const FullScreenImageViewer({super.key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image(image: imageProvider),
        ),
      ),
    );
  }
}

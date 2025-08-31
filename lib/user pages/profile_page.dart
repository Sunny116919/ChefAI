import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'package:shared_preferences/shared_preferences.dart'; // Import for local storage
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _userName;
  String? _userEmail;
  String? _userPhone;
  bool _isLoading = true;

  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentUser != null) {
      setState(() {
        _profileImagePath = prefs.getString(
          'profile_image_${currentUser!.uid}',
        );
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      if (currentUser != null) {
        await prefs.setString('profile_image_${currentUser!.uid}', image.path);
        setState(() {
          _profileImagePath = image.path;
        });
      }
    }
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (mounted && userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?['name'];
          _userEmail = userDoc.data()?['email'];
          _userPhone = userDoc.data()?['phone'];
          _nameController.text = _userName ?? '';
          _phoneController.text = _userPhone ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData(String field, String value) async {
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({field: value});
      await _fetchUserData();
    }
  }

  void _showEditDialog(String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: field.toLowerCase() == 'phone'
                ? TextInputType.phone
                : TextInputType.text,
            inputFormatters: field.toLowerCase() == 'phone'
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ]
                : [],
            decoration: InputDecoration(
              hintText: "Enter new $field",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D9CDB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _updateUserData(field.toLowerCase(), controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // In lib/profile_page.dart

  // In lib/profile_page.dart

  void _logout() async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      // ✅ This is the correct universal logout pattern
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // This removes all pages and puts the router at the root
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CheckAuthPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildInfoSection(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAndSaveImage,
            child: CircleAvatar(
              radius: 55,
              backgroundColor: const Color(0xFF2D9CDB).withOpacity(0.1),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF2D9CDB),
                backgroundImage: _profileImagePath != null
                    ? FileImage(File(_profileImagePath!))
                    : null,
                child: _profileImagePath == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _userName ?? 'Your Name',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail ?? 'your.email@example.com',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.person_outline,
                  title: "Name",
                  value: _userName ?? '',
                  controller: _nameController,
                  isEditable: true,
                ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: "Email",
                  value: _userEmail ?? '',
                  isEditable: false,
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  title: "Phone",
                  value: _userPhone ?? 'Not set',
                  controller: _phoneController,
                  isEditable: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    TextEditingController? controller,
    bool isEditable = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: isEditable
          ? IconButton(
              icon: Icon(
                Icons.edit,
                color: const Color(0xFF2D9CDB).withOpacity(0.7),
              ),
              onPressed: () => _showEditDialog(title, controller!),
            )
          : null,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextButton.icon(
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Logout",
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: _logout,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.withOpacity(0.2)),
          ),
          backgroundColor: Colors.red.withOpacity(0.05),
        ),
      ),
    );
  }
}

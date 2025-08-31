import 'package:ai_recipe_app/admin%20pages/approval_detail_page.dart';
import 'package:ai_recipe_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<QuerySnapshot> _pendingRecipesFuture;

  @override
  void initState() {
    super.initState();
    _pendingRecipesFuture = _fetchPendingRecipes();
  }

  Future<QuerySnapshot> _fetchPendingRecipes() {
    return FirebaseFirestore.instance
        .collection('pending_recipe')
        .where('status', isEqualTo: 'Pending')
        .orderBy('submittedAt', descending: true)
        .get();
  }

  Future<void> _refresh() async {
    setState(() {
      _pendingRecipesFuture = _fetchPendingRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pending Recipes"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // ✅ Apply the same universal pattern here
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const CheckAuthPage(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
        // ...
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _pendingRecipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Stack(
                children: [
                  ListView(), // Makes RefreshIndicator work on an empty list
                  const Center(
                    child: Text(
                      "No pending recipes to review.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          final pendingDocs = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              itemCount: pendingDocs.length,
              itemBuilder: (context, index) {
                final doc = pendingDocs[index];
                final data = doc.data() as Map<String, dynamic>;

                return Card(
                  elevation: 2,
                  color: const Color.fromARGB(255, 250, 250, 250),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(data['recipe_image'] ?? ''),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(
                      data['recipeName'] ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Submitted by: ${data['creatorEmail'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ApprovalDetailPage(pendingRecipeDoc: doc),
                        ),
                      ).then(
                        (_) => _refresh(),
                      ); // Your excellent refresh-on-return logic
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

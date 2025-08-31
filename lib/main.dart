// import 'package:ai_recipe_app/admin%20pages/admin_page.dart'; // Import AdminPage
// import 'package:ai_recipe_app/user%20pages/home_page.dart';
// import 'package:ai_recipe_app/services/providers%20and%20filters/recipe_provider.dart';
// import 'package:ai_recipe_app/login%20pages/signin_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => RecipeProvider(),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Chef AI',
//         theme: ThemeData(primarySwatch: Colors.pink),
//         home: const CheckAuthPage(),
//       ),
//     );
//   }
// }

// // ✅ --- THIS WIDGET IS NOW THE SMART ROUTER ---
// class CheckAuthPage extends StatelessWidget {
//   const CheckAuthPage({super.key});

//   // This function checks if the user's email is in the 'admin' collection
//   Future<bool> _isAdmin(String email) async {
//     try {
//       final adminDoc = await FirebaseFirestore.instance
//           .collection('admin')
//           .doc(email)
//           .get();
//       return adminDoc.exists;
//     } catch (e) {
//       // If there's an error, assume they are not an admin
//       print("Error checking admin status: $e");
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // While waiting for auth state
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // If user is logged in
//         if (snapshot.hasData) {
//           final user = snapshot.data!;

//           // Now, check if the logged-in user is an admin
//           return FutureBuilder<bool>(
//             future: _isAdmin(user.email!), // The admin check happens here
//             builder: (context, adminSnapshot) {
//               // While checking the database
//               if (adminSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }

//               // If the result is back
//               if (adminSnapshot.hasData && adminSnapshot.data == true) {
//                 // It's an admin!
//                 return const AdminPage(); //adminpage
//               } else {
//                 // It's a regular user
//                 return const HomePage(); //homepage
//               }
//             },
//           );
//         }
//         // If user is not logged in
//         else {
//           return const SignInPage(); //signinpage
//         }
//       },
//     );
//   }
// }




// --- main.dart ---

import 'package:ai_recipe_app/admin%20pages/admin_page.dart';
import 'package:ai_recipe_app/onboarding_screen.dart.dart';
import 'package:ai_recipe_app/user%20pages/home_page.dart';
import 'package:ai_recipe_app/services/providers%20and%20filters/recipe_provider.dart';
import 'package:ai_recipe_app/login%20pages/signin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 2. IMPORT SHARED_PREFS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // <-- 3. ADD THIS LOGIC
  // Get the SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();
  // Check if the user has seen the onboarding screen.
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  // <-- END OF ADDED LOGIC

  // Pass the flag to the MyApp widget
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  // <-- 4. ACCEPT THE FLAG
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});
  // <-- END OF CHANGE

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chef AI',
        theme: ThemeData(primarySwatch: Colors.pink),
        // <-- 5. DECIDE WHICH SCREEN TO SHOW FIRST
        home: hasSeenOnboarding ? const CheckAuthPage() : const OnboardingScreen(),
      ),
    );
  }
}

// ✅ --- YOUR EXISTING LOGIC IS UNCHANGED AND SAFE ---
class CheckAuthPage extends StatelessWidget {
  const CheckAuthPage({super.key});

  Future<bool> _isAdmin(String email) async {
    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(email)
          .get();
      return adminDoc.exists;
    } catch (e) {
      print("Error checking admin status: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<bool>(
            future: _isAdmin(user.email!),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (adminSnapshot.hasData && adminSnapshot.data == true) {
                return const AdminPage();
              } else {
                return const HomePage();
              }
            },
          );
        } else {
          return const SignInPage();
        }
      },
    );
  }
}
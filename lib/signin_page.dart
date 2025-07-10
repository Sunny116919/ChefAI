import 'dart:async';
import 'package:ai_recipe_app/forgot_password_page.dart';
import 'package:ai_recipe_app/home_page.dart';
import 'package:ai_recipe_app/services/BottomBlob.dart';
import 'package:ai_recipe_app/services/TopBlob.dart';
import 'package:ai_recipe_app/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final List<String> images = [
    'assets/images/chef.png',
    'assets/images/frying-pan.png',
    'assets/images/cooking.png',
    'assets/images/tray.png',
  ];

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  bool isLoading = false;

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool valid = true;

    setState(() {
      // Email validation
      String email = emailController.text.trim();
      if (email.isEmpty) {
        emailError = "Email can't be empty";
        valid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        emailError = "Enter a valid email";
        valid = false;
      } else {
        emailError = null;
      }

      // Password validation (just non-empty here)
      if (passwordController.text.isEmpty) {
        passwordError = "Password can't be empty";
        valid = false;
      } else {
        passwordError = null;
      }
    });

    return valid;
  }

  Future<void> _signIn() async {
  if (!_validateFields()) return;

  setState(() => isLoading = true);

  try {
    UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    // Update password field in Firestore users collection
    final uid = credential.user!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'password': passwordController.text,
    });

    // On success, navigate to HomePage
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      if (e.code == 'user-not-found') {
        emailError = "No user found for that email.";
        passwordError = null;
      } else if (e.code == 'wrong-password') {
        passwordError = "Incorrect password.";
        emailError = null;
      } else {
        emailError = "Authentication failed.";
        passwordError = null;
      }
    });
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: TopBlob()),
          const Positioned.fill(child: BottomBlob()),
          SizedBox(
            height: screenHeight,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 150),
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Image.asset(
                          images[_currentIndex],
                          key: ValueKey<String>(images[_currentIndex]),
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Sign in to your account",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    _buildTextField(
                      controller: emailController,
                      icon: Icons.email_rounded,
                      hint: "Email",
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                    ),
                    const SizedBox(height: 25),

                    _buildTextField(
                      controller: passwordController,
                      icon: Icons.lock,
                      hint: "Password",
                      obscureText: true,
                      errorText: passwordError,
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot your password?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: isLoading ? null : _signIn,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE91E63),
                                Color(0xFF9C27B0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Sign in",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.white),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(color: Colors.black),
                          children: [
                            WidgetSpan(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFFE91E63),
                                    Color(0xFF9C27B0),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(
                                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                ),
                                child: const Text(
                                  'Create',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}

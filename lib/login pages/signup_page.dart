import 'dart:async';
import 'package:ai_recipe_app/user%20pages/home_page.dart';
import 'package:ai_recipe_app/services/blob%20design/BottomBlob.dart';
import 'package:ai_recipe_app/services/blob%20design/TopBlob.dart';
import 'package:ai_recipe_app/login%20pages/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // <--- needed for input formatters

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final List<String> images = [
    'assets/images/chef.png',
    'assets/images/frying-pan.png',
    'assets/images/cooking.png',
    'assets/images/tray.png',
  ];

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // Error messages per field
  String? nameError;
  String? phoneError;
  String? emailError;
  String? passwordError;

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
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool valid = true;

    setState(() {
      // Name validation
      if (nameController.text.trim().isEmpty) {
        nameError = "Name can't be empty";
        valid = false;
      } else {
        nameError = null;
      }

      // Phone validation: exactly 10 digits numeric
      String phone = phoneController.text.trim();
      if (phone.isEmpty) {
        phoneError = "Phone number can't be empty";
        valid = false;
      } else if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
        phoneError = "Enter a valid 10-digit phone number";
        valid = false;
      } else {
        phoneError = null;
      }

      // Email validation: basic pattern
      String email = emailController.text.trim();
      if (email.isEmpty) {
        emailError = "Email can't be empty";
        valid = false;
      } else if (!RegExp(
            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          ) // simple email regex
          .hasMatch(email)) {
        emailError = "Enter a valid email";
        valid = false;
      } else {
        emailError = null;
      }

      // Password validation
      String password = passwordController.text;
      if (password.isEmpty) {
        passwordError = "Password can't be empty";
        valid = false;
      } else if (password.length < 6) {
        passwordError = "Password must be at least 6 characters";
        valid = false;
      } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
        passwordError = "Password must contain at least one uppercase letter";
        valid = false;
      } else if (!RegExp(r'[a-z]').hasMatch(password)) {
        passwordError = "Password must contain at least one lowercase letter";
        valid = false;
      } else if (!RegExp(r'\d').hasMatch(password)) {
        passwordError = "Password must contain at least one number";
        valid = false;
      } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        passwordError = "Password must contain at least one special character";
        valid = false;
      } else {
        passwordError = null;
      }
    });

    return valid;
  }

  Future<void> _signUp() async {
    if (!_validateFields()) return;

    setState(() => isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'uid': credential.user!.uid,
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text, // store hashed in prod
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
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
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Image.asset(
                          images[_currentIndex],
                          key: ValueKey(images[_currentIndex]),
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      "Sign up to get started",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    _buildTextField(
                      nameController,
                      Icons.person,
                      "Full Name",
                      errorText: nameError,
                    ),
                    const SizedBox(height: 25),

                    _buildTextField(
                      phoneController,
                      Icons.phone,
                      "Phone Number",
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      errorText: phoneError,
                    ),
                    const SizedBox(height: 25),

                    _buildTextField(
                      emailController,
                      Icons.email_rounded,
                      "Email",
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                    ),
                    const SizedBox(height: 25),

                    _buildTextField(
                      passwordController,
                      Icons.lock,
                      "Password",
                      obscureText: true,
                      errorText: passwordError,
                    ),
                    const SizedBox(height: 40),

                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: isLoading ? null : _signUp,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
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
                                      "Sign up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(color: Colors.black),
                          children: [
                            WidgetSpan(
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFE91E63),
                                        Color(0xFF9C27B0),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(
                                      Rect.fromLTWH(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    ),
                                child: const Text(
                                  'Sign in',
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

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool obscureText = false,
    TextInputType? keyboardType,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
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
            inputFormatters: inputFormatters,
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

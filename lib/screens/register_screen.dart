// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_theme.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // REAL FIREBASE REGISTRATION
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);


    try {

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await userCredential.user?.updateDisplayName(
        _nameController.text.trim(),
      );




      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Password is too weak. Please use a stronger password.';
          break;

        case 'operation-not-allowed':
          message = 'Email/password registration is not enabled in Firebase.';
          break;

        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.containerBg,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Inset Header Dome
                  Container(
                    margin: const EdgeInsets.only(bottom: 24.0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(160),
                        topRight: Radius.circular(160),
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 36,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/pantherheartface.png',
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'nyra.',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentYellow,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              TextSpan(
                                text: '\nyour ai companion.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title Text
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Let’s get started!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'your safety starts here',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPurple,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name Input
                  _buildLabel('Enter your name'),
                  const SizedBox(height: 6),
                  _buildFormField(
                    controller: _nameController,
                    hintText: 'nyra',
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Email Input
                  _buildLabel('Enter your Email address'),
                  const SizedBox(height: 6),
                  _buildFormField(
                    controller: _emailController,
                    hintText: 'for ex: abc@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email';
                      }

                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                      if (!emailRegex.hasMatch(val.trim())) {
                        return 'Please enter a valid email address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Password Input
                  _buildLabel('Enter password'),
                  const SizedBox(height: 6),
                  _buildFormField(
                    controller: _passwordController,
                    hintText: 'More than 8 letters',
                    isObscure: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textPurple,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter a password';
                      }

                      if (val.length < 8) {
                        return 'Password must be at least 8 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Confirm Password Input
                  _buildLabel('Confirm password'),
                  const SizedBox(height: 6),
                  _buildFormField(
                    controller: _confirmPasswordController,
                    hintText: 'Both passwords should match',
                    isObscure: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textPurple,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (val) {
                      if (val != _passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentYellow,
                        foregroundColor: AppColors.background,
                        disabledBackgroundColor:
                            AppColors.accentYellow.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.background,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer Section
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login here',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textPurple,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: AppColors.textWhite,
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textPurple.withOpacity(0.5),
          fontSize: 14,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF141927),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.accentYellow,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
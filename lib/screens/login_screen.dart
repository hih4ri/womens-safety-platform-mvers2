// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_theme.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // REAL FIREBASE LOGIN
  // ------------------------------------------------------------

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Firebase keeps the user signed in.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account exists with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message =
              'Too many login attempts. Please try again later.';
          break;

        default:
          message =
              e.message ?? 'Login failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // TOP HEADER
                    // ==================================================

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.containerBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(160),
                          topRight: Radius.circular(160),
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        top: 40,
                        bottom: 28,
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/pantherheartface.png',
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'nyra.',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentYellow,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                TextSpan(
                                  text: '\nyour ai companion.',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: AppColors.textPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // FORM
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Welcome back!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Text(
                            'Enter Email address',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _emailController,
                            keyboardType:
                                TextInputType.emailAddress,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textWhite,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Email is required';
                              }

                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );

                              if (!emailRegex.hasMatch(
                                value.trim(),
                              )) {
                                return 'Enter a valid email address';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'for ex: abc@gmail.com',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.textPurple
                                    .withOpacity(0.5),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: AppColors.fieldBg,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'Enter password',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isPasswordObscured,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textWhite,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Password is required';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.fieldBg,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? Icons
                                          .visibility_off_outlined
                                      : Icons
                                          .visibility_outlined,
                                  color: AppColors.textPurple,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordObscured =
                                        !_isPasswordObscured;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ==================================================
                          // FORGOT PASSWORD
                          // ==================================================

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // We will add this later.
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.textPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // LOGIN BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.accentYellow,
                                foregroundColor:
                                    AppColors.background,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            AppColors.background,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            AppColors.background,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ==================================================
                          // REGISTER
                          // ==================================================

                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Don’t have an account?',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: AppColors.textPurple,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Register now',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          AppColors.textPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
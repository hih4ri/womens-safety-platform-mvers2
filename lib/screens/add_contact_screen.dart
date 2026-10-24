// lib/screens/add_contact_screen.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button (Updated to use GoRouter)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPurple,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),

              // MAIN CONTAINER (Layer 2)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header Card with exact visual proportions and adjusted panther position
                      Container(
                        height: 160, // Fixed height matching Figma proportions
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141927),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              // Title Text (Top-Left)
                              const Positioned(
                                top: 20,
                                left: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentYellow,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      'CONTACTS',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentYellow,
                                        letterSpacing: 0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Crouching Panther Graphic (Shifted left away from border)
                              Positioned(
                                right: 12, // Moved inward so it doesn't touch the right border
                                bottom: 0,
                                child: Image.asset(
                                  'assets/images/pantherbravelook.png',
                                  height: 135,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form Inputs
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('Enter name'),
                              const SizedBox(height: 6),
                              _buildTextField(controller: _nameController),
                              const SizedBox(height: 16),

                              _buildLabel('Enter phone number'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Enter relationship'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _relationshipController,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Save Contact Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.trim().isEmpty ||
                                _phoneController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter name and phone number'),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(
                              context,
                              {
                                'name': _nameController.text.trim(),
                                'phone': _phoneController.text.trim(),
                                'relationship': _relationshipController.text.trim(),
                              },
                            );
                          },
                          
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF141927),
                            foregroundColor: AppColors.textPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.08),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Save Contact',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPurple,
                            ),
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
    );
  }

  // --- HELPER METHODS ---

  Widget _buildLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPurple,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
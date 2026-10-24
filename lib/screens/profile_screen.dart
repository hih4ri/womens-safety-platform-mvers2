// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String avatarPath;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.username = 'kairo',
    this.avatarPath = 'assets/images/pantherheartface.png',
    this.onLogout,
  });

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
              // Navigation Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Main Container Container
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
                      const SizedBox(height: 12),

                      // Profile Avatar Graphic
                      Image.asset(
                        avatarPath,
                        height: 110,
                        width: 110,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      // Dynamic User Name Card
                      _buildCardWrapper(
                        child: Text(
                          username,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentYellow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Settings Option List
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildSettingTile(
                              title: 'Notifications',
                              icon: Icons.notifications_none_rounded,
                              onTap: () {
                                // TODO: Navigate to Notifications Settings
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildSettingTile(
                              title: 'Location Settings',
                              icon: Icons.location_on_outlined,
                              onTap: () {
                                // TODO: Navigate to Location Settings
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildSettingTile(
                              title: 'Privacy & Security',
                              icon: Icons.lock_outline_rounded,
                              onTap: () {
                                // TODO: Navigate to Privacy Settings
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bottom Assist Banner
                      _buildCardWrapper(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'nyra at your assist 24/7',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPurple,
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

  // --- REUSABLE UI BUILDERS ---

  Widget _buildCardWrapper({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF141927),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: _buildCardWrapper(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPurple, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPurple,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPurple.withOpacity(0.5),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.containerBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: AppColors.textPurple),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textPurple)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),

            onPressed: () async {
              Navigator.pop(context);

              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                debugPrint('Logout error: $e');
              }
            },            

            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
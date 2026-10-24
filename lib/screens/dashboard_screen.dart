import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../app_theme.dart';
import '../sos_storage.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                color: Colors.white10,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/profile'),
                          child: _HeaderCard(
                            userName: userName,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _SosCard(),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 4.0,
                            bottom: 12.0,
                          ),
                          child: Text(
                            'Quick actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      delegate: SliverChildListDelegate([
                        _ActionCard(
                          icon: Icons.history_rounded,
                          title: 'History',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/sos_history',
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.import_contacts_rounded,
                          title: 'Contacts',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/contacts',
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.location_on_rounded,
                          title: 'Location',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/location',
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Chat AI',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/chat',
                          ),
                        ),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/chat'),
                          child: const _NyraAssistCard(),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String userName;

  const _HeaderCard({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141927),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning,',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentYellow,
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentYellow,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/images/pantherheartface.png',
            height: 52,
            width: 52,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(
              Icons.person,
              color: AppColors.accentYellow,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _SosCard extends StatelessWidget {
  const _SosCard();

  Future<void> _triggerSOS(BuildContext context) async {
    try {
      // 1. Save SOS to history
      await SosStorage.addSosAlert();

      // 2. Get current location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 3. Load emergency contacts
      final prefs = await SharedPreferences.getInstance();


      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // User shouldn't normally reach Dashboard while logged out.
        return;
      }

      final contactsKey = 'emergency_contacts_${user.uid}';

      final savedContacts = prefs.getStringList(contactsKey);


      if (savedContacts == null || savedContacts.isEmpty) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'SOS saved, but no emergency contacts have been added.',
            ),
          ),
        );

        return;
      }

      // 4. Create Google Maps location link
      final latitude = position.latitude;
      final longitude = position.longitude;

      final locationLink =
          'https://maps.google.com/?q=$latitude,$longitude';

      // 5. SOS message
      final message =
          '🚨 SOS ALERT! I need help. '
          'My current location is: $locationLink';

      // 6. Open SMS for each emergency contact
      for (final contactJson in savedContacts) {
        final contact =
            Map<String, dynamic>.from(jsonDecode(contactJson));

        final phone = contact['phone']?.toString();

        if (phone == null || phone.isEmpty) {
          continue;
        }

        final uri = Uri(
          scheme: 'sms',
          path: phone,
          queryParameters: {
            'body': message,
          },
        );

        await launchUrl(uri);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'SOS alert prepared for your emergency contacts.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SOS error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141927),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white10,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'NEED HELP?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPurple,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                await _triggerSOS(context);
              },
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB30000),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 6,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFB3B3),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tap to send alert',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF262135),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white10,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 44,
                color: const Color(0xFF9C8BB4),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9C8BB4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NyraAssistCard extends StatelessWidget {
  const _NyraAssistCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141927),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white10,
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nyra Assist',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.accentYellow,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.accentYellow,
          ),
        ],
      ),
    );
  }
}
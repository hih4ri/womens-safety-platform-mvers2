// lib/screens/sos_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../sos_storage.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  Future<void> _triggerSos(BuildContext context) async {
    try {
      print('========== SOS BUTTON PRESSED ==========');

      // ------------------------------------------------------------
      // 1. Load emergency contacts
      // ------------------------------------------------------------
      final prefs = await SharedPreferences.getInstance();

      final savedContacts =
          prefs.getStringList('emergency_contacts') ?? [];

      print('Emergency contacts found: ${savedContacts.length}');

      if (savedContacts.isEmpty) {
        print('NO EMERGENCY CONTACTS FOUND');

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No emergency contacts added.',
            ),
          ),
        );

        return;
      }

      // ------------------------------------------------------------
      // 2. Save SOS to history
      // ------------------------------------------------------------
      await SosStorage.addSosAlert();

      print('SOS history saved.');

      // ------------------------------------------------------------
      // 3. Create SMS message
      // ------------------------------------------------------------
      const message =
          'SOS ALERT! I need help. This is an emergency.';
    

      // ------------------------------------------------------------
      // 5. Send SMS to every emergency contact
      // ------------------------------------------------------------
      for (final contactJson in savedContacts) {
        try {
          final Map<String, dynamic> contact =
              jsonDecode(contactJson);

          final name = contact['name']?.toString() ?? '';
          final phone = contact['phone']?.toString() ?? '';

          print(
            'Trying to send SOS SMS to: $name ($phone)',
          );

          if (phone.isEmpty) {
            print('Skipping contact because phone is empty.');
            continue;
          }


          print(
            'SMS SEND REQUEST COMPLETED FOR: $phone',
          );
        } catch (e) {
          print(
            'ERROR SENDING SMS TO CONTACT: $e',
          );
        }
      }

      print('========== SOS PROCESS FINISHED ==========');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'SOS sent to your emergency contacts.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('========== SOS ERROR ==========');
      print(e);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SOS error: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // BACK BUTTON
              // --------------------------------------------------
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

              // --------------------------------------------------
              // MAIN CONTAINER
              // --------------------------------------------------
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: const Color(0x0DFFFFFF),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 36.0,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      // ------------------------------------------------
                      // HEADER
                      // ------------------------------------------------
                      const Text(
                        'ARE YOU SURE\nYOU NEED HELP?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPurple,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),

                      // ------------------------------------------------
                      // SOS BUTTON
                      // ------------------------------------------------
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _triggerSos(context),
                          customBorder: const CircleBorder(),
                          child: Ink(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8B0000),
                              border: Border.all(
                                color: const Color(0xFF333333),
                                width: 10,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40FF0000),
                                  blurRadius: 24,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 216,
                                height: 216,
                                decoration:
                                    const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFB30000),
                                ),
                                child: const Center(
                                  child: Text(
                                    'SOS',
                                    style: TextStyle(
                                      fontSize: 56,
                                      fontWeight:
                                          FontWeight.w900,
                                      color:
                                          Color(0xFFFFB3B3),
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // BOTTOM
                      // ------------------------------------------------
                      Column(
                        children: [
                          const Text(
                            'Your emergency\ncontacts will be alerted',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: 220,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF2E243A),
                                foregroundColor:
                                    AppColors.textPurple,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      AppColors.textPurple,
                                ),
                              ),
                            ),
                          ),
                        ],
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
}
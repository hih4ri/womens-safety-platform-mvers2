// lib/screens/emergency_contacts_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  List<Map<String, String>> contacts = [];

  // Create a unique storage key for the currently logged-in user.
  String get _contactsKey {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'emergency_contacts_no_user';
    }

    return 'emergency_contacts_${user.uid}';
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // ---------------------------------------------------------------------------
  // LOAD CONTACTS
  // ---------------------------------------------------------------------------

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final savedContacts = prefs.getStringList(_contactsKey);

    if (savedContacts == null) {
      if (mounted) {
        setState(() {
          contacts = [];
        });
      }
      return;
    }

    final loadedContacts = <Map<String, String>>[];

    for (final contact in savedContacts) {
      try {
        final decoded = jsonDecode(contact);

        loadedContacts.add(
          Map<String, String>.from(decoded),
        );
      } catch (_) {
        // Ignore corrupted contact entries.
      }
    }

    if (!mounted) return;

    setState(() {
      contacts = loadedContacts;
    });
  }

  // ---------------------------------------------------------------------------
  // SAVE CONTACTS
  // ---------------------------------------------------------------------------

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final savedContacts = contacts
        .map((contact) => jsonEncode(contact))
        .toList();

    await prefs.setStringList(
      _contactsKey,
      savedContacts,
    );
  }

  // ---------------------------------------------------------------------------
  // ADD CONTACT
  // ---------------------------------------------------------------------------

  Future<void> _addContact() async {
    final result =
        await Navigator.pushNamed(context, '/add_contact');

    if (result != null && result is Map<String, String>) {
      setState(() {
        contacts.add(result);
      });

      await _saveContacts();
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE CONTACT
  // ---------------------------------------------------------------------------

  Future<void> _deleteContact(int index) async {
    setState(() {
      contacts.removeAt(index);
    });

    await _saveContacts();
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
              // Back button
              IconButton(
                padding: const EdgeInsets.all(8.0),
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPurple,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 8),

              // Main container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white10,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const _HeaderCard(),

                      const SizedBox(height: 16),

                      // Contact list
                      Expanded(
                        child: contacts.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.contacts_outlined,
                                      size: 50,
                                      color: AppColors.textPurple,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No emergency contacts yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textPurple,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Add someone you trust',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                physics:
                                    const BouncingScrollPhysics(),
                                itemCount: contacts.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 12),
                                itemBuilder:
                                    (context, index) {
                                  final contact =
                                      contacts[index];

                                  return _ContactTile(
                                    name: contact['name'] ?? '',
                                    phone: contact['phone'] ?? '',
                                    relationship:
                                        contact['relationship'] ?? '',
                                    onDelete: () =>
                                        _deleteContact(index),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Add contact button
                      _AddContactButton(
                        onPressed: _addContact,
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

// -----------------------------------------------------------------------------
// HEADER
// -----------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentYellow,
                ),
              ),
              Text(
                'CONTACTS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentYellow,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/images/pantherheartface.png',
            height: 60,
            width: 60,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CONTACT TILE
// -----------------------------------------------------------------------------

class _ContactTile extends StatelessWidget {
  final String name;
  final String phone;
  final String relationship;
  final VoidCallback onDelete;

  const _ContactTile({
    required this.name,
    required this.phone,
    required this.relationship,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF141927),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white10,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPurple,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (relationship.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      relationship,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPurple,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textPurple,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADD CONTACT BUTTON
// -----------------------------------------------------------------------------

class _AddContactButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddContactButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF141927),
          foregroundColor: AppColors.textPurple,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Colors.white10,
              width: 1,
            ),
          ),
        ),
        child: const Text(
          'Add Contacts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPurple,
          ),
        ),
      ),
    );
  }
}
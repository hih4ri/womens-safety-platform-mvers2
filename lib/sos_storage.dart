import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SosStorage {
  static String _getKey() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return '';
    }

    return 'sos_history_${user.uid}';
  }

  static Future<void> addSosAlert() async {
    final prefs = await SharedPreferences.getInstance();

    final key = _getKey();

    if (key.isEmpty) {
      return;
    }

    final saved = prefs.getString(key);

    List<Map<String, String>> history = [];

    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);

      history = decoded
          .map((item) => Map<String, String>.from(item))
          .toList();
    }

    final now = DateTime.now();

    final alert = {
      'id': 'SOS-${DateTime.now().millisecondsSinceEpoch}',
      'title': 'SOS Alert',
      'date': '${now.day}/${now.month}/${now.year} '
          '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'subtitle': 'SOS alert triggered',
      'status': 'PENDING',
      'coordinates': 'Location not available',
      'contactsNotified': 'Emergency contacts',
    };

    history.insert(0, alert);

    await prefs.setString(
      key,
      jsonEncode(history),
    );
  }
}
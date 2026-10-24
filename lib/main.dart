import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/add_contact_screen.dart';
import 'screens/location_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/sos_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NyraApp());
}

class NyraApp extends StatelessWidget {
  const NyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyra',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),

      // Firebase decides whether the user is already logged in.
      home: const AuthGate(),

      routes: {
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/chat': (context) => const ChatScreen(),
        '/contacts': (context) => const EmergencyContactsScreen(),
        '/add_contact': (context) => const AddContactScreen(),
        '/location': (context) => const LocationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/sos': (context) => const SosScreen(),
        '/sos_history': (context) => const SosHistoryScreen(),
      },
    );
  }
}

// ------------------------------------------------------------
// AUTH GATE
// ------------------------------------------------------------

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Firebase is checking the current login state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B1020),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is already logged in.
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // No user is logged in.
        return const IntroScreen();
      },
    );
  }
}
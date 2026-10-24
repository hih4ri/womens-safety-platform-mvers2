// lib/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import your screen files
import '../screens/home_screen.dart'; // Adjust import to your actual home screen
import '../screens/add_contact_screen.dart';
import '../screens/report_incident_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/sos_history_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addContact = '/add-contact';
  static const String reportIncident = '/report-incident';
  static const String chat = '/chat';
  static const String sosHistory = '/sos-history';
  static const String profile = '/profile';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(), // Replace with your home widget
      ),
      GoRoute(
        path: AppRoutes.addContact,
        builder: (context, state) => const AddContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportIncident,
        builder: (context, state) => const ReportIncidentScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.sosHistory,
        builder: (context, state) => const SosHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
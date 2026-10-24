import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF090C19),
              borderRadius: BorderRadius.circular(38),
            ),
            child: Column(
              children: [
                // TOP CARD: HEADER & TITLE
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1020),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: const Color(0xFF02040A),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'meet',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontFamily: 'Poppins',
                                  color: const Color(0xFFFECE15),
                                  fontWeight: FontWeight.w800,
                                  height: 0.9,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              Text(
                                'nyra.',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontFamily: 'Poppins',
                                  color: const Color(0xFFFECE15),
                                  fontWeight: FontWeight.w800,
                                  height: 0.85,
                                  letterSpacing: -2.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 32.0),
                                child: Text(
                                  'your ai companion.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF895095),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // MIDDLE CARD: CHARACTER ILLUSTRATION
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/pantherwave.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),

                // BOTTOM AREA: REGISTER BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigates to the Auth screen in Register mode
                        Navigator.pushNamed(
                          context,
                          '/auth',
                          arguments: {'isRegister': true},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFECE15),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [

              // LIGHT BLUE BASE
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0B1020),
                ),
              ),

              // DARKER BLUE BACK SHAPE
              Positioned(
                left: width * 0.055,
                right: width * 0.055,
                top: height * 0.075,
                height: height * 0.875,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF090C19),
                    borderRadius: BorderRadius.circular(38),
                  ),
                ),
              ),

              // TOP NYRA CARD
              Positioned(
                left: width * 0.083,
                right: width * 0.083,
                top: height * 0.087,
                height: height * 0.185,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1020),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: const Color(0xFF02040A),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'nyra.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFFFECE15),
                            fontSize: width * 0.105,
                            fontWeight: FontWeight.w800,
                            height: 0.85,
                            letterSpacing: -2.5,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.16,
                          ),
                          child: Text(
                            'your ai companion.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: const Color(0xFF895095),
                              fontSize: width * 0.029,
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // LOWER INTRODUCTION CARD
              Positioned(
                left: width * 0.083,
                right: width * 0.083,
                top: height * 0.275,
                bottom: height * 0.045,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1020),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF02040A),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [

                      // PANTHER
                      SizedBox(
                        height: height * 0.31,
                        width: width * 0.72,
                        child: Image.asset(
                          'assets/images/pantherwave.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // DESCRIPTION
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.045,
                        ),
                        child: Text(
                          'nyra. is your personal safety\n'
                          'companion, designed to help you\n'
                          'stay connected, aware, and\n'
                          'protected. Get quick access to\n'
                          'emergency alerts, trusted contacts,\n'
                          'incident reporting, and AI-powered\n'
                          'safety assistance — all in one place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFF9A5BA8),
                            fontSize: width * 0.036,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // GET STARTED BUTTON
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: height * 0.025,
                        ),
                        child: SizedBox(
                          width: width * 0.53,
                          height: height * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFECE15),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Get started',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: width * 0.047,
                                fontWeight: FontWeight.w700,
                              ),
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
}
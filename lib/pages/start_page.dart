import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text(
                      'Next Space',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A Hive to Strive',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                        fontSize: 18, color: Colors.white, fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

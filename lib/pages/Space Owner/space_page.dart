import 'package:flutter/material.dart';

class SpacePage extends StatefulWidget {
  const SpacePage({super.key});

  @override
  State<SpacePage> createState() => _SpacePageState();
}

class _SpacePageState extends State<SpacePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
            // color: Colors.blue, // Blue background
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100), // Spacer from the top
            const Text(
              "Create Your Space",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black, // White text
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/onboardingimageone.jpg', // Replace with your image asset
              height: 400,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              "Easily create and manage your own spaces! Add details, invite people, and organize activities in a dedicated space.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black, // White text
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // White button
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                //Navigate to create space
                Navigator.pushNamed(context, '/create_space');
              },
              child: const Text(
                "Create Space",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Blue text on button
                ),
              ),
            ),
            const SizedBox(height: 50), // Spacer from the bottom
          ],
        ),
      ),
    );
  }
}

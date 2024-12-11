import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  // Properties for image, title, and subtitle
  final String image;
  final String title;
  final String subtitle;

  const OnboardingScreen({
    super.key,
    required this.image, // Path to the image asset
    required this.title, // Title text to display
    required this.subtitle, // Subtitle text to display
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center elements vertically
      children: [
        // Image at the top of the onboarding screen
        Container(
          width: 250, // Set the width of the image container
          height: 250, // Set the height of the image container
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), // Rounded corners
            image: DecorationImage(
              image: AssetImage(image), // Load image from assets
              fit: BoxFit.cover, // Ensure image covers the container
            ),
          ),
        ),
        const SizedBox(height: 30), // Space between image and text
        Column(
          children: [
            // Title Text
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10), // Horizontal padding for the text
              child: Text(
                title, // Display the title
                style: const TextStyle(
                  fontSize: 26, // Font size for title
                  fontWeight: FontWeight.bold, // Bold title
                  color: Colors.white, // White color for the text
                ),
              ),
            ),
            const SizedBox(height: 10), // Space between title and subtitle
            // Subtitle Text
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10), // Horizontal padding for the subtitle
              child: Text(
                subtitle, // Display the subtitle
                style: const TextStyle(
                  fontSize: 16, // Font size for subtitle
                  color:
                      Colors.white70, // Slightly transparent white for subtitle
                ),
                textAlign: TextAlign.center, // Center-align the subtitle text
              ),
            ),
          ],
        ),
      ],
    );
  }
}

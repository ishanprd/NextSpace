import 'package:flutter/material.dart';
import 'package:nextspace/Widget/onboardingscreen.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final PageController _pageController =
      PageController(); // Controller for PageView
  int _currentPage = 0; // Track the current page in the PageView

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context)
        .size; // Get screen size to make layout responsive

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient and image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // Gradient starts at the top
                  end: Alignment.bottomCenter, // Gradient ends at the bottom
                  colors: [
                    Colors.black.withOpacity(0.8), // Dark top for the gradient
                    Colors.black, // Solid black at the bottom
                  ],
                ),
              ),
            ),
          ),

          // Page view for onboarding screens
          Positioned.fill(
            child: PageView(
              controller:
                  _pageController, // PageController for handling the page view
              onPageChanged: (index) {
                setState(() {
                  _currentPage =
                      index; // Update current page when PageView changes
                });
              },
              children: const [
                // First onboarding screen
                OnboardingScreen(
                  image: 'assets/onboardingimageone.jpg',
                  title: 'Welcome to Next Space',
                  subtitle:
                      'Discover a place where creativity meets productivity. Enjoy a flexible, inspiring environment tailored to your needs.',
                ),
                // Second onboarding screen
                OnboardingScreen(
                  image: 'assets/onboardingimagetwo.jpg',
                  title: 'Flexible Plans for Everyone',
                  subtitle:
                      'Whether you`re a freelancer, startup, or remote team, we have the perfect space to suit your work style',
                ),
                // Third onboarding screen
                OnboardingScreen(
                  image: 'assets/onboardingimagethree.jpg',
                  title: 'Community & Networking',
                  subtitle:
                      'Collaborate with like-minded professionals, attend events, and expand your network in an inspiring environment.',
                ),
              ],
            ),
          ),

          // Bottom navigation dots to indicate the current page in the PageView
          Positioned(
            bottom: size.height *
                0.1, // Position dots 10% from the bottom of the screen
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Align dots at the center
                children: List.generate(
                  3, // Number of pages in the PageView
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 5, // Dot radius
                      backgroundColor: _currentPage == index
                          ? Colors.white // Active dot color
                          : Colors.white.withOpacity(0.5), // Inactive dot color
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Get Started Button - Positioned at the bottom of the screen
          Positioned(
            bottom: size.height *
                0.2, // Position button 20% from the bottom of the screen
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to login page when the button is pressed
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  minimumSize: Size(size.width * 0.7,
                      50), // Button width is 70% of screen width
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Rounded corners for button
                  ),
                ),
                child: const Text(
                  'GET STARTED', // Button text
                  style: TextStyle(
                    fontSize: 16, // Text size
                    color: Colors.white, // Text color
                    fontWeight: FontWeight.bold, // Text weight
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

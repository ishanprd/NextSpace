import 'package:flutter/material.dart';
import 'package:nextspace/pages/login_page.dart';
import 'package:nextspace/pages/signup_page_for_spaceowner.dart';
import 'package:nextspace/pages/signup_page.dart';
import 'package:nextspace/pages/signup_page_for_coworker.dart';

void main() {
  runApp(const NextSpace()); // Run the app, passing the NextSpace widget
}

class NextSpace extends StatelessWidget {
  const NextSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Space',
      theme: ThemeData(
        // Defines the app's theme with a deep purple color scheme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Enable Material 3 components
      ),
      debugShowCheckedModeBanner:
          false, // Disable the debug banner in development
      home: const LoginPage(), // Set the initial screen of the app to StartPage
      routes: {
        // Define named routes for navigating between pages
        '/login': (context) => const LoginPage(), // Route for signup page
        '/spaceowner_signup': (context) => const SignupPageForSpaceOwner(),
        // Define named routes for navigating between pages
        '/signup': (context) => const SignupPage(), // Route for signup page
        '/coworker_signup': (context) => const SignupPageForCoworker(),
      },
    );
  }
}

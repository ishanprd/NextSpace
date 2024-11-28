import 'package:flutter/material.dart';
import 'package:nextspace/pages/login_page.dart';
import 'package:nextspace/pages/signup_page_for_spaceowner.dart';

void main() {
  runApp(const NextSpace());
}

class NextSpace extends StatelessWidget {
  const NextSpace({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Space',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner:
          false, // Disable the debug banner in development
      home: const LoginPage(), // Set the initial screen of the app to StartPage
      routes: {
        // Define named routes for navigating between pages
        '/signup': (context) => const LoginPage(), // Route for signup page
        '/coworker_signup': (context) => const SignupPageForSpaceOwner(),
      },
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nextspace/pages/Co-worker/coworker_dashboard.dart';

import 'package:nextspace/pages/authentication/reset/reset_password.dart';
import 'package:nextspace/pages/authentication/signup/co-worker/email_page_for_coworker.dart';
import 'package:nextspace/pages/authentication/login_page.dart';
import 'package:nextspace/pages/authentication/signup/co-worker/email_verification_for_coworker.dart';
import 'package:nextspace/pages/authentication/signup/space_owner/email_page_for_space_owner.dart';
import 'package:nextspace/pages/authentication/signup/space_owner/email_verification_for_space_owner.dart';
import 'package:nextspace/pages/authentication/signup/space_owner/signup_page_for_space_owner.dart';
import 'package:nextspace/pages/authentication/signup/signup_page.dart';
import 'package:nextspace/pages/authentication/signup/co-worker/signup_page_for_coworker.dart';
import 'package:nextspace/pages/start_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase app
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
          useMaterial3: true,
          fontFamily: 'Inter' // Enable Material 3 components
          ),
      debugShowCheckedModeBanner:
          false, // Disable the debug banner in development

      routes: {
        // Define named routes for navigating between pages
        '/': (context) => const StartPage(),
        '/login': (context) => const LoginPage(), // Route for signup page
        '/signup': (context) => const SignupPage(), // Route for signup page
        '/email/coworker': (context) => const EmailPageForCoworker(),
        '/email/spaceowner': (context) => const EmailPageSpaceOwner(),
        '/spaceowner_signup': (context) => const SignupPageForSpaceOwner(),
        '/coworker_signup': (context) => const SignupPageForCoworker(),
        '/emailverification/coworker': (context) =>
            const EmailVerificationForCoworker(),
        '/emailverification/spaceowner': (context) =>
            const EmailVerificationForSpaceOwner(),
        '/reset_password': (context) => const ResetPassword(),

        '/coworker_dashboard': (context) => const CoworkerDashboard(),
      },
    );
  }
}

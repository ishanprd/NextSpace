import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nextspace/navigation/admin_navigation.dart';
import 'package:nextspace/navigation/chat_navigation.dart';
import 'package:nextspace/pages/Co-worker/book/add_detail.dart';
import 'package:nextspace/pages/Co-worker/book/payment.dart';
import 'package:nextspace/pages/Space%20Owner/chat/chat.dart';
import 'package:nextspace/pages/Space%20Owner/setting/notification.dart';
import 'package:nextspace/pages/Space%20Owner/space/create_space.dart';
import 'package:nextspace/pages/Space%20Owner/space/edit_space.dart';
import 'package:nextspace/pages/Space%20Owner/space/view_space.dart';
import 'package:nextspace/pages/Co-worker/book/view_space_for_book.dart';
import 'package:nextspace/pages/admin/setting/edit_admin_profile.dart';
import 'package:nextspace/pages/admin/setting/issues_problems.dart';
import 'package:nextspace/pages/admin/setting/notification.dart';
import 'package:nextspace/pages/Space%20Owner/space_page.dart';
import 'package:nextspace/pages/authentication/auth_handler.dart';
import 'firebase_options.dart';
import 'package:nextspace/pages/start_page.dart';
import 'package:nextspace/pages/authentication/reset/reset_password.dart';
import 'package:nextspace/pages/authentication/signup/co-worker/email_page_for_coworker.dart';
import 'package:nextspace/pages/authentication/login_page.dart';
import 'package:nextspace/pages/authentication/signup/co-worker/email_verification_for_coworker.dart';
import 'package:nextspace/pages/authentication/signup/space_owner/email_page_for_space_owner.dart';
import 'package:nextspace/pages/authentication/signup/space_owner/email_verification_for_space_owner.dart';
import 'package:nextspace/pages/authentication/signup/space_owner/signup_page_for_space_owner.dart';
import 'package:nextspace/pages/authentication/signup/signup_page.dart';
import 'package:nextspace/pages/authentication/signup/co-worker/signup_page_for_coworker.dart';
import 'package:nextspace/navigation/owner_navigation.dart';
import 'package:nextspace/navigation/coworker_navigation.dart';
import 'package:nextspace/pages/Space%20Owner/setting/edit_profile.dart';
import 'package:nextspace/pages/Space%20Owner/setting/feedback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase app
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
          fontFamily: 'Inter' // Enable Material 3 components
          ),
      debugShowCheckedModeBanner: false,
      home: AuthChecker(), // Disable the debug banner in development

      routes: {
        // Define named routes for navigating between pages
        '/start_page': (context) => const StartPage(),
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
        '/coworker': (context) => const CoworkerNavigation(),
        '/space_owner': (context) => const SpaceOwnerNavigation(),
        '/edit_profile': (context) => const EditProfile(),
        '/feedback': (context) => const SpaceFeedback(),
        '/notifications': (context) => const SpaceNotification(),
        '/conversations': (context) => const Chat(),
        '/create_space': (context) => const CreateSpace(),
        '/view_space': (context) => const ViewSpace(),
        '/admin': (context) => const AdminNavigation(),
        '/edit_admin_profile': (context) => const EditAdminProfile(),
        '/issues': (context) => const IssuesProblems(),
        '/admin_notifications': (context) => const AdminNotification(),
        '/space_page': (context) => const SpacePage(),
        '/edit_space': (context) => const EditSpace(),
        '/view_space_for_book': (context) => const ViewSpaceForBook(),
        '/add_details': (context) => const AddDetail(),
        '/payments': (context) => const PaymentPage(),
        '/chat': (context) => const ChatNavigation(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  final AuthHandler _authHandler = AuthHandler();

  AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _authHandler.getUserRole(), // Fetch user role and login status
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final role = snapshot.data!['role']; // Extract role from snapshot
          final isLoggedIn =
              snapshot.data!['isLoggedIn']; // Extract login status

          if (isLoggedIn) {
            switch (role) {
              case 'coworker':
                return const CoworkerNavigation();
              case 'spaceOwner':
                return const SpaceOwnerNavigation();
              case 'admin':
                return const AdminNavigation();
              default:
                return const StartPage(); // Default to start page if role is unknown
            }
          } else {
            return const StartPage(); // User is not logged in
          }
        }

        return const StartPage(); // Default case
      },
    );
  }
}

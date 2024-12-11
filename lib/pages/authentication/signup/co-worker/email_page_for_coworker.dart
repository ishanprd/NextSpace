// Import necessary Flutter packages
import 'package:flutter/material.dart';
// Import custom widgets and validation methods
import 'package:nextspace/Widget/dialog_box.dart';
import 'package:nextspace/validation/check_email_exits.dart';
import 'package:nextspace/validation/email_validation.dart';

// Stateful widget for handling email input and validation
class EmailPageForCoworker extends StatefulWidget {
  const EmailPageForCoworker({super.key});

  @override
  State<EmailPageForCoworker> createState() => _EmailPageForCoworkerState();
}

class _EmailPageForCoworkerState extends State<EmailPageForCoworker> {
  final FocusNode _focusNode = FocusNode(); // Focus node for email input field
  final TextEditingController _emailController =
      TextEditingController(); // Controller for email text input

  @override
  Widget build(BuildContext context) {
    // Get the device screen size for responsive layout
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      resizeToAvoidBottomInset: true, // Prevent resizing on keyboard appearance
      body: SingleChildScrollView(
        // Allows scrolling in case of keyboard visibility
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical:
                size.height * 0.02, // Vertical padding based on screen size
            horizontal:
                size.width * 0.04, // Horizontal padding based on screen size
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.1), // Add space at the top
              Text(
                'Create Your Account', // Page title
                style: TextStyle(
                  fontSize: size.width * 0.08, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01), // Small gap
              Text(
                'Create account for exploring news', // Subtitle
                style: TextStyle(fontSize: size.width * 0.04),
              ),
              SizedBox(height: size.height * 0.02), // Space between elements
              const Icon(
                Icons.location_on, // Location icon
                color: Colors.red,
                size: 50,
              ),
              Text(
                'NEXT SPACE', // App name
                style: TextStyle(
                  fontSize: size.width * 0.1, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'A Hive to Strive', // Tagline
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.03), // Space after tagline
              Image.asset(
                'assets/email.png', // Email image
                height: size.height *
                    0.25, // Adjust image size based on screen height
              ),
              SizedBox(height: size.height * 0.03), // Space after image
              // Email input field
              TextField(
                controller: _emailController, // Controller for email input
                keyboardType: TextInputType.emailAddress, // Email input type
                focusNode: _focusNode, // Focus for the input field
                decoration: InputDecoration(
                  labelText: "Email", // Email field label
                  prefixIcon: const Icon(
                    Icons.email, // Icon for email field
                    color: Colors.blueAccent,
                  ),
                  border: OutlineInputBorder(
                    // Style for email input field
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02), // Space before the buttons
              // 'Continue' button
              ElevatedButton(
                onPressed: () async {
                  String email =
                      _emailController.text; // Get email from input field
                  bool exist =
                      await checkEmailExists(email); // Check if email exists

                  // Validation for empty email
                  if (email.isEmpty) {
                    showDialog(
                      // Show error dialog for empty email
                      context: context,
                      builder: (BuildContext context) {
                        return DialogBox(
                          icon: Icons.error_outline,
                          color: Colors.red,
                          title: "Please enter your email", // Error message
                          onOkPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        );
                      },
                    );
                  }
                  // Validation for invalid email format
                  else if (!isValidEmail(email)) {
                    showDialog(
                      // Show error dialog for invalid email
                      context: context,
                      builder: (BuildContext context) {
                        return DialogBox(
                          icon: Icons.error_outline,
                          color: Colors.red,
                          title: "Please enter a valid email", // Error message
                          onOkPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        );
                      },
                    );
                  }
                  // If email already exists in the database
                  else if (exist) {
                    showDialog(
                      // Show error dialog for existing email
                      context: context,
                      builder: (BuildContext context) {
                        return DialogBox(
                          icon: Icons.error_outline,
                          color: Colors.red,
                          title: "email already exists !!", // Error message
                          onOkPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        );
                      },
                    );
                  }
                  // If email is valid and does not exist
                  else if (!exist) {
                    Navigator.pushNamed(
                      context,
                      '/coworker_signup', // Navigate to the coworker signup page
                      arguments: email, // Pass email to the next page
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  minimumSize: Size(
                      double.infinity, size.height * 0.07), // Full-width button
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                ),
                child: Text(
                  "Continue", // Button text
                  style: TextStyle(
                    fontSize: size.width * 0.05, // Responsive text size
                    color: Colors.white, // White text color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 'Back' button
              SizedBox(height: size.height * 0.02),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  minimumSize: Size(
                      double.infinity, size.height * 0.07), // Full-width button
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                ),
                child: Text(
                  "Back", // Button text
                  style: TextStyle(
                    fontSize: size.width * 0.05, // Responsive text size
                    color: Colors.white, // White text color
                    fontWeight: FontWeight.bold,
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

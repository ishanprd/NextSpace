import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false; // Boolean variable for remember me checkbox
  bool _obscureText = true; // Boolean to toggle password visibility

  @override
  Widget build(BuildContext context) {
    // Getting screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image for the top section
          Container(
            height:
                screenHeight * 0.53, // Adjust height to 53% of screen height
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.07), // Spacer for top margin
                // Welcome message
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: screenWidth * 0.1, // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White color to stand out
                  ),
                ),
                SizedBox(height: screenHeight * 0.01), // Spacer
                // Subtitle text
                Text(
                  "Let’s login for explore more",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Responsive font size
                    color: Colors.white, // Light color for subtitle
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Spacer
                // Location Icon
                Icon(
                  Icons.location_on_sharp,
                  size: screenWidth * 0.12, // Responsive icon size
                  color: Colors.red, // Red color for the icon
                ),
                // Next Space text
                Text(
                  "NEXT SPACE",
                  style: TextStyle(
                    fontSize: screenWidth * 0.10, // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White color for the text
                  ),
                ),
              ],
            ),
          ),
          // Login form with white background
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: screenHeight * 0.35, // Adjust padding for the form
                bottom: 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Login form container with shadow
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0, // Soft shadow
                          offset: Offset(0, 5), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Google Sign-In Button
                        ElevatedButton.icon(
                          onPressed: () {
                            // Add Google Sign-In Logic here
                          },
                          icon: Image.asset(
                            'assets/google-logo.png', // Google logo image
                            width: screenWidth * 0.1, // Responsive size
                            height: screenWidth * 0.1, // Responsive size
                          ),
                          label: Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.04, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white, // White background
                            minimumSize: Size(double.infinity,
                                screenHeight * 0.07), // Full width button
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Rounded button corners
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03), // Spacer
                        // Divider with "Or login with" text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 201, 203, 203),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text("Or login with"),
                            const SizedBox(width: 10),
                            Container(
                              width: 100,
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 201, 203, 203),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03), // Spacer
                        // Email TextField
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.blueAccent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.blue, // Focus border color
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02), // Spacer
                        // Password TextField
                        TextField(
                          obscureText:
                              _obscureText, // Toggle password visibility
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.blueAccent,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText =
                                      !_obscureText; // Toggle the visibility
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.blue, // Focus border color
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01), // Spacer
                        // Remember Me and Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.blueAccent,
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe =
                                          value!; // Toggle Remember Me
                                    });
                                  },
                                ),
                                const Text("Remember me"),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Forgot Password Screen
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03), // Spacer
                        // Log In Button
                        ElevatedButton(
                          onPressed: () {
                            // Log In Logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent, // Button color
                            minimumSize: Size(double.infinity,
                                screenHeight * 0.07), // Full width button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Rounded button corners
                            ),
                          ),
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03), // Spacer
                        // Sign-Up Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            SizedBox(width: screenWidth * 0.01),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context,
                                    '/signup'); // Navigate to Sign Up page
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
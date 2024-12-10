import 'package:flutter/material.dart';
import 'package:nextspace/service/auth_service.dart';
import 'package:nextspace/validation/email_validation.dart';
import 'package:nextspace/validation/password_validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false; // Boolean variable for remember me checkbox
  bool _obscureText = true; // Boolean to toggle password visibility
  bool _isLoading = false; // Boolean to manage loading state

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthService authService = AuthService();

  Future<void> login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    if (!isValidPassword(_passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password should be at least 8 characters long")),
      );
      return;
    }

    // If all validations pass, proceed with login
    setState(() {
      _isLoading = true; // Show the loading indicator
    });

    try {
      // Call the login function from AuthService
      await authService.loginUser(
        context: context,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the loading indicator after login attempt
      });
    }
  }

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
                SizedBox(height: screenHeight * 0.17), // Spacer for top margin
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
                top: screenHeight * 0.53, // Adjust padding for the form
                bottom: 20.0,
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
                        // Email TextField
                        TextField(
                          controller: _emailController,
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
                          controller: _passwordController,
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
                                Navigator.pushNamed(context, '/reset_password');
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
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent, // Button color
                            minimumSize: Size(double.infinity,
                                screenHeight * 0.07), // Full width button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Rounded button corners
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
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

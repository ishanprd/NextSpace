import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Spacer
              SizedBox(
                  height: screenHeight * 0.1), // Adjust based on screen height
              // Logo
              Icon(
                Icons.shield,
                size: screenWidth * 0.15, // Responsive size for the icon
                color: Colors.blue,
              ),
              SizedBox(height: screenHeight * 0.02),
              // Title
              Text(
                "Sign in to your Account",
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              // Subtitle
              Text(
                "Enter your email and password to log in",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // Responsive font size
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: () {
                  // Add Google Sign-In Logic
                },
                icon: Icon(Icons.account_circle, size: screenWidth * 0.06),
                label: Text(
                  "Continue with Google",
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, screenHeight * 0.07),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              const Text("Or login with"),
              SizedBox(height: screenHeight * 0.03),
              // Email TextField
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Password TextField
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              // Remember Me and Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      Text("Remember me"),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Forgot Password Screen
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              // Log In Button
              ElevatedButton(
                onPressed: () {
                  // Add Log-In Logic
                },
                child: Text(
                  "Log In",
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, screenHeight * 0.07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Sign-Up Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  SizedBox(width: screenWidth * 0.01),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Sign-Up Screen
                    },
                    child: Text(
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
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // Get screen size
    double width = size.width;
    double height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // Ensure screen resizes when the keyboard appears
      body: SingleChildScrollView(
        // Ensure content is scrollable when the keyboard is visible
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: height * 0.02,
            horizontal: width * 0.04,
          ),
          child: Column(
            children: [
              SizedBox(height: height * 0.1),
              Image.asset(
                'assets/reset.png',
                height: height * 0.35,
                width: width * 0.5, // Dynamic width adjustment for the image
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Reset Your Password',
                style: TextStyle(
                  fontSize: width *
                      0.08, // Dynamically adjust font size based on screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Enter your email adress below and we`ll send you a link with instructions',
                style: TextStyle(
                  fontSize: width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.02),

              // Align the 'Enter Verification Code' label to the left
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),

              // Input fields for verification code (5-digit example)
              TextField(
                keyboardType: TextInputType.emailAddress,
                focusNode: FocusNode(),
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
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),

              // Verification Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/confirm_email');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, height * 0.07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Send Verification Code",
                  style: TextStyle(
                    fontSize: width * 0.05, // Dynamic font size for button text
                    color: Colors.white,
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

import 'package:flutter/material.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
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
                'assets/new password.png',
                height: height * 0.25,
                width: width * 0.5, // Dynamic width adjustment for the image
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Enter New Password',
                style: TextStyle(
                  fontSize: width *
                      0.08, // Dynamically adjust font size based on screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Set Complex passwords to protect',
                style: TextStyle(
                  fontSize: width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.02),

              // Input fields for verification code (5-digit example)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
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
                  labelText: "password",
                  prefixIcon: const Icon(
                    Icons.password,
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Re Type Password',
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
                  labelText: "Password",
                  prefixIcon: const Icon(
                    Icons.password,
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
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, height * 0.07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Set New Password",
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

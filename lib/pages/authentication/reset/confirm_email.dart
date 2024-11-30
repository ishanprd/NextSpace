import 'package:flutter/material.dart';

class ConfirmEmail extends StatefulWidget {
  const ConfirmEmail({super.key});

  @override
  State<ConfirmEmail> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
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
                'assets/opt.png',
                height: height * 0.25,
                width: width * 0.5, // Dynamic width adjustment for the image
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Confirm Your Email',
                style: TextStyle(
                  fontSize: width *
                      0.08, // Dynamically adjust font size based on screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'We`ve sent 5 digits verification code to abc@gmail.com',
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
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),

              // Input fields for verification code (5-digit example)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Flexible(
                    child: SizedBox(
                      width: width *
                          0.14, // Adjust size of each input box based on width
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 1, // Limit to 1 character per field
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '', // Hide counter text
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
                    ),
                  );
                }),
              ),
              SizedBox(height: height * 0.03),

              // Verification Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/new_password');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, height * 0.07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Verify and Create Account",
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

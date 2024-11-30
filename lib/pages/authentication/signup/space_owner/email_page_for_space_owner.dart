import 'package:flutter/material.dart';

class EmailPageSpaceOwner extends StatefulWidget {
  const EmailPageSpaceOwner({super.key});

  @override
  State<EmailPageSpaceOwner> createState() => _EmailPageSpaceOwnerState();
}

class _EmailPageSpaceOwnerState extends State<EmailPageSpaceOwner> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // Ensure screen resizes when the keyboard appears
      body: SingleChildScrollView(
        // Ensure content is scrollable when the keyboard is visible
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
            horizontal: size.width * 0.04,
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.1),
              Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: size.width * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Create account for exploring news',
                style: TextStyle(fontSize: size.width * 0.04),
              ),
              SizedBox(height: size.height * 0.02),
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 50,
              ),
              Text(
                'NEXT SPACE',
                style: TextStyle(
                  fontSize: size.width * 0.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'A Hive to Strive',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Image.asset(
                'assets/email.png',
                height: size.height * 0.25,
              ),
              SizedBox(height: size.height * 0.03),
              TextField(
                focusNode: _focusNode,
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
              SizedBox(height: size.height * 0.02),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/spaceowner_signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, size.height * 0.07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: size.width * 0.05,
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

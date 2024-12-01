import 'package:flutter/material.dart';

class EmailPageForCoworker extends StatefulWidget {
  const EmailPageForCoworker({super.key});

  @override
  State<EmailPageForCoworker> createState() => _EmailPageForCoworkerState();
}

class _EmailPageForCoworkerState extends State<EmailPageForCoworker> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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
                  String email = _emailController.text;
                  if (email.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/coworker_signup',
                      arguments: email, // Passing email to the next page
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter an email")),
                    );
                  }
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

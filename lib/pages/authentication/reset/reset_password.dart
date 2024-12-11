import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextspace/Widget/dialog_box.dart';
import 'package:nextspace/validation/check_email_exits.dart';
import 'package:nextspace/validation/email_validation.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword(email) async {
    bool exist = await checkEmailExists(_emailController.text);
    try {
      if (exist) {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return DialogBox(
              icon: Icons.thumb_up,
              color: Colors.green,
              title: "Password reset email has been sent",
              onOkPressed: () {
                Navigator.pushNamed(context, '/login'); // Close the dialog
              },
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Given email hasn`t registered yet')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to reset password!')),
      );
    }
  }

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
                  fontSize: width * 0.08, // Dynamically adjust font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Enter your email address below and we\'ll send you a link with instructions',
                style: TextStyle(
                  fontSize: width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.02),

              // Align the 'Email Address' label to the left
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

              // Email Input Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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

              // Reset Password Button
              ElevatedButton(
                onPressed: () {
                  String email = _emailController.text;
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter an email")),
                    );
                  } else if (!isValidEmail(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter a valid email")),
                    );
                  } else {
                    _resetPassword(email); // Only send email if valid
                  }
                },
                // Call reset password function
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
                    fontSize: width * 0.05, // Dynamic font size
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                // Call reset password function
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, height * 0.07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Back",
                  style: TextStyle(
                    fontSize: width * 0.05, // Dynamic font size
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

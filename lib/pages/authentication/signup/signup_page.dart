import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(color: Colors.black),
          )),
          // Overlay card with buttons
          Positioned(
            top: 100, // Position from the top of the screen
            left: 0, // Align to the left edge
            right: 0, // Align to the right edge
            child: Container(
              width: size.width, // Full screen width
              height: size.height * 1, // 70% of screen height
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(223, 226, 235, 100),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        height: 8,
                        width: 100,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 50,
                  ),
                  const Text(
                    'NEXT SPACE',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'A Hive to Strive',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/onboardingimagetwo.jpg'),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/email/coworker');
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign up as Co-Worker',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/email/spaceowner');
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign up as Space Owner',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

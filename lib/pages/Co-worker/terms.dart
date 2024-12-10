import 'package:flutter/material.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Policies"),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terms and Conditions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "1. Use of the Space:\n"
              "   - Members agree to use the coworking space for professional work-related activities.\n"
              "   - Activities that disrupt other members or violate local laws are strictly prohibited.\n\n"
              "2. Membership:\n"
              "   - All members must provide accurate personal information when registering.\n"
              "   - Memberships are non-transferable without prior approval from management.\n\n"
              "3. Payments:\n"
              "   - Payments for membership or services must be made on time.\n"
              "   - Refunds are subject to the coworking space's cancellation policy.\n\n"
              "4. Property and Equipment:\n"
              "   - Members are responsible for the care of the coworking space's property.\n"
              "   - Damages caused intentionally or through negligence will be charged to the member.\n\n"
              "5. Privacy:\n"
              "   - Respect the privacy and confidentiality of other members.\n"
              "   - Sharing or distributing sensitive information without consent is prohibited.\n\n",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Policies",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "1. Code of Conduct:\n"
              "   - Treat all members and staff with respect and courtesy.\n"
              "   - Any form of harassment, discrimination, or offensive behavior is strictly prohibited.\n\n"
              "2. Internet Usage:\n"
              "   - Internet access is provided for professional purposes only.\n"
              "   - Illegal or inappropriate use of the internet is not allowed.\n\n"
              "3. Security:\n"
              "   - Members are responsible for securing their personal belongings.\n"
              "   - Do not share access codes or keys with non-members.\n\n"
              "4. Cleanliness:\n"
              "   - Keep your workspace clean and tidy.\n"
              "   - Dispose of trash in designated bins.\n\n"
              "5. Termination:\n"
              "   - The coworking space reserves the right to terminate membership for violations of terms and policies.\n"
              "   - Members will be notified in advance in case of termination.\n\n",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "By using our coworking space, you agree to abide by these terms and policies. Failure to do so may result in suspension or termination of your membership.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

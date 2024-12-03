import 'package:flutter/material.dart';

class EditAdminProfile extends StatefulWidget {
  const EditAdminProfile({super.key});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  final TextEditingController _nameController =
      TextEditingController(text: "Melissa Peters");
  final TextEditingController _emailController =
      TextEditingController(text: "melpeters@gmail.com");
  final TextEditingController _passwordController =
      TextEditingController(text: "********");
  final TextEditingController _dobController =
      TextEditingController(text: "23/05/1995");
  String _selectedCountry = "Nigeria";

  final List<String> countries = [
    "Nigeria",
    "United States",
    "Canada",
    "United Kingdom",
    "Australia"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture with camera icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      AssetImage('assets/email.png'), // Replace with your asset
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 16),
                    onPressed: () {
                      // Handle profile picture change
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date of birth field
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    // Handle date picker
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Country/Region dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountry = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Country/Region",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Save changes button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle save changes action
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent),
                child: const Text(
                  "Save changes",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

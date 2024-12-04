import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditAdminProfile extends StatefulWidget {
  const EditAdminProfile({super.key});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedGender = 'Male'; // Default gender
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Uint8List? imageBytes;
  String _base64Image = "";
  File? _image;
  final picker = ImagePicker();
  String error = '';
  String? email;

  Future uploadCitizenship() async {
    final XFile? pickedImage2 =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage2 != null) {
      final bytes = await pickedImage2.readAsBytes();
      setState(() {
        _image = File(pickedImage2.path);
        _base64Image = base64Encode(bytes);
        error = ''; // Clear previous error if image is selected
      });
    } else {
      setState(() {
        error = "No image selected";
      });
    }
  }

  void updateUserProfile() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isNotEmpty) {
      try {
        // Prepare user data for update
        Map<String, dynamic> updatedData = {
          'fullName': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phoneNumber': _phoneController.text,
          'gender': _selectedGender,
        };

        // Include the base64 image if it's set
        if (_base64Image.isNotEmpty) {
          updatedData['imageUrl'] = _base64Image;
        }

        // Update the user document in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update(updatedData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isNotEmpty) {
      try {
        // Fetch the data of the space owner from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Assuming your collection is named 'users'
            .doc(userId)
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;

          // Populate the controllers with the fetched data
          setState(() {
            _nameController.text = userData['fullName'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _passwordController.text = userData['password'] ?? '';
            _phoneController.text = userData['phoneNumber'] ?? '';
            _selectedGender = userData['gender'] ?? 'Male';
            final base64Image = userData['imageUrl'] ?? '';

            if (base64Image.isNotEmpty) {
              try {
                imageBytes =
                    base64Decode(base64Image); // Decode base64 image data
              } catch (e) {
                print('Error decoding base64: $e');
                imageBytes = null; // Handle decoding error
              }
            } // Set gender
          });
        } else {
          print("User not found!");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

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

            // Phone number field
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Gender field - Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // If image is not base64, try loading from file path
            // Save changes button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  updateUserProfile();
                  Navigator.pushNamed(context, '/space_owner');
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

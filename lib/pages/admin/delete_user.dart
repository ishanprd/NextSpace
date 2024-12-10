import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteUser extends StatefulWidget {
  final String userId; // Accepting userId as an argument

  const DeleteUser({super.key, required this.userId});

  @override
  State<DeleteUser> createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  Uint8List? imageBytes;
  Uint8List? imageBytes2;
  String _selectedGender = 'Male'; // Default gender

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    if (widget.userId.isNotEmpty) {
      // Use widget.userId
      try {
        // Fetch the user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Assuming your collection is named 'users'
            .doc(widget.userId) // Use widget.userId
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;

          // Handle null values and provide default values where needed
          setState(() {
            // Use default 'Male' if gender is null
            _selectedGender = userData['gender'] ?? 'Male';

            // Handle imageUrl safely (check for null)
            final base64Image2 =
                userData['imageUrl'] ?? ''; // Default to empty string if null

            // if (base64Image2.isNotEmpty) {
            //   try {
            //     imageBytes2 =
            //         base64Decode(base64Image2); // Decode base64 image data
            //   } catch (e) {
            //     print('Error decoding base64: $e');
            //     imageBytes2 = null; // Handle decoding error
            //   }
            // } else {
            //   imageBytes2 = null; // Handle case where imageUrl is empty or null
            // }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Profile'),
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
            // Profile picture display (commented out if not needed)
            // const SizedBox(height: 20),

            // Name display
            Text(
              'Name: ${FirebaseAuth.instance.currentUser?.email ?? 'Not Available'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Phone number display
            Text(
              'Phone Number: ${FirebaseAuth.instance.currentUser?.phoneNumber ?? 'Not Available'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Gender display
            Text(
              'Gender: $_selectedGender',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            if (imageBytes2 != null)
              SizedBox(
                width: double
                    .infinity, // Set width to occupy the full available space
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.memory(
                    imageBytes2!,
                    fit: BoxFit
                        .cover, // You can change the BoxFit to control how the image fits
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

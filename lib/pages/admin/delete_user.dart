import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteUser extends StatefulWidget {
  final String userId; // Accepting userId as an argument

  const DeleteUser({super.key, required this.userId});

  @override
  State<DeleteUser> createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  Uint8List? imageBytes2;
  Uint8List? imageBytes;

  String _selectedGender = 'Male'; // Default gender
  String? _userName;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Delete user from Firestore
  void DeleteUser() async {
    try {
      // Delete user document from Firestore
      await FirebaseFirestore.instance
          .collection('users') // Assuming your collection is named 'users'
          .doc(widget.userId) // Use widget.userId
          .delete();

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User successfully deleted.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after deletion
      Navigator.of(context).pop();
      _fetchUserData();
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    if (widget.userId.isNotEmpty) {
      try {
        // Fetch the user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Assuming your collection is named 'users'
            .doc(widget.userId) // Use widget.userId
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          print("User data: $userData");

          // Handle null values and provide default values where needed
          setState(() {
            _userName = userData['fullName']?.toString() ?? 'Not Available';
            _phoneNumber =
                userData['phoneNumber']?.toString() ?? 'Not Available';
            _selectedGender = userData['gender']?.toString() ?? 'Male';

            final base64Image =
                userData['image']?.toString() ?? ''; // Default to empty string
            if (base64Image.isNotEmpty) {
              try {
                imageBytes =
                    base64Decode(base64Image); // Decode base64 image data
              } catch (e) {
                print('Error decoding base64: $e');
                imageBytes = null; // Handle decoding error
              }
            } else {
              imageBytes2 = null; // Ensure imageBytes2 is null if no image
            }
            // Handle imageUrl safely
            final base64Image2 = userData['imageUrl']?.toString() ?? '';
            if (base64Image2.isNotEmpty) {
              try {
                imageBytes2 =
                    base64Decode(base64Image2); // Decode base64 image data
              } catch (e) {
                print('Error decoding base64: $e');
                imageBytes2 = null; // Handle decoding error
              }
            } else {
              imageBytes2 = null; // Ensure imageBytes2 is null if no image
            }
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
            CircleAvatar(
              radius: 50,
              backgroundImage: imageBytes != null
                  ? MemoryImage(imageBytes!) // Display decoded image
                  : const AssetImage('assets/applogo.png')
                      as ImageProvider, // Replace with your asset
            ),
            const SizedBox(height: 16),

            // Name display
            Text(
              'Name: ${_userName ?? 'Loading...'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Phone number display
            Text(
              'Phone Number: ${_phoneNumber ?? 'Loading...'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Gender display
            Text(
              'Gender: $_selectedGender',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Profile picture display
            if (imageBytes2 != null)
              SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.memory(
                    imageBytes2!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Delete user button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  DeleteUser(); // Call delete user function
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  "Delete User",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

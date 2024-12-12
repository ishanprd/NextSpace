import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedGender = 'Male'; // Default gender
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Uint8List? imageBytes;
  Uint8List? imageBytes2;

  String _base64Image = "";
  String _base64Image2 = "";

  File? _image;
  File? _image2;

  final picker = ImagePicker();
  bool _isLoading = false;
  String error = '';
  String? email;

  Future uploadCitizenship() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      final XFile? pickedImage2 =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage2 != null) {
        final bytes = await pickedImage2.readAsBytes();
        setState(() {
          _image2 = File(pickedImage2.path);
          _base64Image2 = base64Encode(bytes);
          error = ''; // Clear previous error if image is selected
        });
      } else {
        setState(() {
          error = "No image selected";
        });
      }
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> uploadimage() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        final image = img.decodeImage(Uint8List.fromList(bytes));
        if (image != null) {
          // Resize image (example: 800px wide, maintaining aspect ratio)
          final resizedImage = img.copyResize(image, width: 800);

          // Convert resized image to bytes
          final resizedBytes = Uint8List.fromList(img.encodeJpg(resizedImage));

          // Update the state with the compressed image
          setState(() {
            _image = File(pickedImage.path);
            _base64Image = base64Encode(resizedBytes);
            imageBytes = resizedBytes; // Display the compressed image
            error = ''; // Clear any previous errors
          });
        }
      } else {
        setState(() {
          error = "No image selected"; // If no image was picked
        });
      }
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void updateUserProfile() async {
    setState(() {
      _isLoading = true; // Start loading
    });
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

        // Only add image and imageUrl if they are not empty
        if (_base64Image.isNotEmpty) {
          updatedData['image'] = _base64Image; // Add image if it's not empty
        }

        if (_base64Image2.isNotEmpty) {
          updatedData['imageUrl'] =
              _base64Image2; // Add imageUrl if it's not empty
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
        _fetchUserData();
        Navigator.pop(context); // Fetch updated data after successful update
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
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
            final base64Image = userData['image'] ?? '';

            if (base64Image.isNotEmpty) {
              try {
                imageBytes =
                    base64Decode(base64Image); // Decode base64 image data
              } catch (e) {
                print('Error decoding base64: $e');
                imageBytes = null; // Handle decoding error
              }
            } // Set gender
            final base64Image2 = userData['imageUrl'] ?? '';

            if (base64Image2.isNotEmpty) {
              try {
                imageBytes2 =
                    base64Decode(base64Image2); // Decode base64 image data
              } catch (e) {
                print('Error decoding base64: $e');
                imageBytes2 = null; // Handle decoding error
              }
            } //
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
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture with camera icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes!) // Display decoded image
                        : const AssetImage('assets/applogo.png')
                            as ImageProvider, // Replace with your asset
                  ), // Replace with your asset
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 16),
                      onPressed: () {
                        uploadimage();
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
                    ), // Display image using Image.memory
                  ),
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: uploadCitizenship,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.blueAccent,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.black,
                ),
                label: const Text(
                  'Citizenship',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_base64Image2.isEmpty)
                    Text(
                      error,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    )
                  else
                    const Text(
                      "Citizenship Uploaded successfully!",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                ],
              ),
              // If image is not base64, try loading from file path
              // Save changes button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    updateUserProfile();
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
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ]),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextspace/Widget/dialog_box.dart';
import 'package:nextspace/service/auth_service.dart';

class SignupPageForCoworker extends StatefulWidget {
  const SignupPageForCoworker({super.key});

  @override
  State<SignupPageForCoworker> createState() => _SignupPageForCoworkerState();
}

class _SignupPageForCoworkerState extends State<SignupPageForCoworker> {
  // Focus nodes for managing text field focus
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Controllers for text fields
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variables to store base64 encoded images
  String _base64Image1 = "";
  String _base64Image2 = "";

  // AuthService instance for registration
  AuthService authService = AuthService();

  // Default gender selection
  String? _selectedGender = "Male";

  // Variables to store the images
  File? _image1;
  File? _image2;
  final picker = ImagePicker();
  String error = '';
  String? email;

  // Method to handle the citizenship image upload
  Future uploadCitizenship() async {
    final XFile? pickedImage2 =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage2 != null) {
      final bytes = await pickedImage2.readAsBytes();
      setState(() {
        _image2 = File(pickedImage2.path);
        _base64Image2 = base64Encode(bytes); // Encode the image to base64
        error = ''; // Clear previous error if image is selected
      });
    } else {
      setState(() {
        error = "No image selected";
      });
    }
  }

  // Method to handle the profile image upload
  Future uploadimage() async {
    final XFile? pickedImage1 =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage1 != null) {
      final bytes = await pickedImage1.readAsBytes();
      setState(() {
        _image1 = File(pickedImage1.path);
        _base64Image1 = base64Encode(bytes); // Encode the image to base64
        error = ''; // Clear previous error if image is selected
      });
    } else {
      setState(() {
        error = "No image selected";
      });
    }
  }

  // Method to register the user
  Future<void> registerUser() async {
    // Validate inputs
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your full name")),
      );
      return;
    }

    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number")),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your address")),
      );
      return;
    }

    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }

    if (_image1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload your citizenship image")),
      );
      return;
    }
    if (_image2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload your profile image")),
      );
      return;
    }

    try {
      // Call AuthService to register the user
      await authService.registerUser(
        context: context,
        email: email ?? '',
        password: _passwordController.text,
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        gender: _selectedGender ?? 'Male',
        imageUrl: _base64Image2,
        image: _base64Image1, // Upload images to Firebase Storage if needed
        role: 'coworker', // Assign role as 'coworker'
      );
      // Show success dialog after registration
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            icon: Icons.login,
            color: Colors.green,
            title: "Login Successfully",
            onOkPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          );
        },
      );
    } catch (e) {
      // Show error dialog if registration fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            icon: Icons.error_outline,
            color: Colors.red,
            title: "Registration failed: ${e.toString()}",
            onOkPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  // Get the email passed from the previous page
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    email = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    // Dispose the focus nodes to prevent memory leaks
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.03,
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
                'Create account for exploring more',
                style: TextStyle(fontSize: size.width * 0.04),
              ),
              SizedBox(height: size.height * 0.03),

              // Full Name Field
              TextField(
                focusNode: _nameFocusNode,
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(
                    Icons.face,
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
              SizedBox(height: size.height * 0.03),

              // Phone number Field
              TextField(
                focusNode: _phoneFocusNode,
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Phone number",
                  prefixIcon: const Icon(
                    Icons.phone,
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
              SizedBox(height: size.height * 0.03),

              // Address Field
              TextField(
                controller: _addressController,
                focusNode: _addressFocusNode,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  labelText: "Address",
                  prefixIcon: const Icon(
                    Icons.location_on,
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
              SizedBox(height: size.height * 0.03),

              // Gender Selection (Radio Buttons)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Gender: ',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Male',
                        groupValue: _selectedGender,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const Text('Male'),
                      Radio<String>(
                        value: 'Female',
                        groupValue: _selectedGender,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const Text('Female'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.03),

              // Password Field
              TextField(
                focusNode: _passwordFocusNode,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(
                    Icons.lock,
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
              SizedBox(height: size.height * 0.03),

              // Image Upload (Profile and Citizenship)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: uploadimage,
                    child: const Text('Upload Profile Image'),
                  ),
                  SizedBox(width: size.width * 0.05),
                  ElevatedButton(
                    onPressed: uploadCitizenship,
                    child: const Text('Upload Citizenship Image'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.03),

              // Error Message
              if (error.isNotEmpty)
                Text(
                  error,
                  style:
                      TextStyle(color: Colors.red, fontSize: size.width * 0.04),
                ),
              SizedBox(height: size.height * 0.03),

              // Register Button
              ElevatedButton(
                onPressed: registerUser,
                child: const Text('Register'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(size.width, size.height * 0.07),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

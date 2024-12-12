import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextspace/Widget/dialog_box.dart';
import 'package:nextspace/service/auth_service.dart';

class SignupPageForSpaceOwner extends StatefulWidget {
  const SignupPageForSpaceOwner({super.key});

  @override
  State<SignupPageForSpaceOwner> createState() =>
      _SignupPageForSpaceOwnerState();
}

class _SignupPageForSpaceOwnerState extends State<SignupPageForSpaceOwner> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  String _base64Image1 = "";
  String _base64Image2 = "";
  bool _isLoading = false;

  AuthService authService = AuthService();

  String? _selectedGender = "Male"; // Move this outside the build method

  File? _image1;
  File? _image2;
  final picker = ImagePicker();
  String error = '';
  String? email;

  Future uploadCitizenship() async {
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
  }

  Future uploadimage() async {
    final XFile? pickedImage1 =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage1 != null) {
      final bytes = await pickedImage1.readAsBytes();
      setState(() {
        _image1 = File(pickedImage1.path);
        _base64Image1 = base64Encode(bytes);
        error = ''; // Clear previous error if image is selected
      });
    } else {
      setState(() {
        error = "No image selected";
      });
    }
  }

  Future<void> registerUser() async {
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
        const SnackBar(content: Text("Please upload your image")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

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
        image: _base64Image1,
        role: 'space_owner',
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            icon: Icons.login,
            color: Colors.green,
            title: "Register Successfully",
            onOkPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            icon: Icons.error,
            color: Colors.red,
            title: "Registration failed: ${e.toString()}",
            onOkPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the email passed from the previous page
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
      body: Stack(children: [
        SingleChildScrollView(
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
                          activeColor:
                              Colors.blue, // Set the color of the radio button
                        ),
                        const Text(
                          "Male",
                          style: TextStyle(
                              color: Colors.blue), // Set the text color to blue
                        ),
                        const SizedBox(
                            width: 10), // Space between radio buttons
                        Radio<String>(
                          value: 'Female',
                          groupValue: _selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          activeColor:
                              Colors.blue, // Set the color of the radio button
                        ),
                        const Text(
                          "Female",
                          style: TextStyle(
                              color: Colors.blue), // Set the text color to blue
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: size.height * 0.03),

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
                SizedBox(height: size.height * 0.03),
                OutlinedButton.icon(
                  onPressed: uploadimage,
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
                    'Profile',
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
                    if (_base64Image1.isEmpty)
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
                        "Profile Uploaded successfully!",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),

                // Password Field
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(
                      Icons.password,
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

                // Continue Button
                ElevatedButton(
                  onPressed: registerUser,
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
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ]),
    );
  }
}

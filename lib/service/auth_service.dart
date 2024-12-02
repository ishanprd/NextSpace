import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextspace/Model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user
  Future<void> registerUser({
    required context,
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String imageUrl,
    required String role,
  }) async {
    try {
      // Firebase Authentication - Create User
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) throw Exception("User registration failed!");

      // Firestore - Save User Data
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber, // Avoid storing plaintext in production!
        'gender': gender,
        'imageUrl': imageUrl,
        'role': role,
        'password': password,
        'isVerified': false,
      });
      // Send email verification
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }

  // Fetch full user data
  Future<UserModel> fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) throw Exception("User not found!");

      // Return full user data as an extended UserModel
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Error fetching user data: ${e.toString()}");
    }
  }

  // Log in user
  Future<void> loginUser({
    required context,
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Authentication - Sign In User
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("User not found!");
      }

      // Fetch User Data from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception("User data not found!");
      }

      // Map Firestore data to `UserModel`
      UserModel userModel =
          UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

      // Check if the email is verified
      if (!user.emailVerified) {
        // If email is not verified, notify the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please verify your email before logging in.")),
        );

        // Optionally, you can trigger a re-send of the verification email
        await user.sendEmailVerification();

        return; // Stop further execution as the user needs to verify their email
      }

      await _firestore.collection('users').doc(user.uid).update({
        'isVerified': true, // Set `isVerified` to true once email is verified
      });

      // Proceed with user role-based navigation
      String role = userModel.role;

      // Navigate to the respective dashboard based on the role
      if (role == 'coworker') {
        Navigator.pushNamed(context, '/coworker_dashboard');
      } else if (role == 'space_owner') {
        Navigator.pushNamed(context, '/space_owner');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown role: $role")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  // Log out user
  Future<void> signOut(context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}

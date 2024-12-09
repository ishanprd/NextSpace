import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For user role retrieval

class AuthHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the user is logged in and fetch their role
  Future<Map<String, dynamic>> getUserRole() async {
    final user = _auth.currentUser;

    if (user != null) {
      // Fetch user role from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return {
          'isLoggedIn': true,
          'role': userDoc.data()?['role'], // Assuming `role` field exists
        };
      }
    }

    return {'isLoggedIn': false, 'role': null};
  }
}

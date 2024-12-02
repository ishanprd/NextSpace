import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkEmailExists(String email) async {
  try {
    // Reference to your Firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Query to check if the email exists
    QuerySnapshot querySnapshot =
        await users.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isEmpty) {
      // Email doesn't exist in the database
      return false;
    } else {
      // Email exists in the database
      return true;
    }
  } catch (e) {
    print("Error checking email: $e");
    return false; // Return false in case of error
  }
}

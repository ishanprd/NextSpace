// Import necessary packages
import 'package:nextspace/Model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// FirebaseHelper class contains methods to interact with Firebase
class FirebaseHelper {
  // Static method to get UserModel by user ID (uid)
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel; // Variable to hold the user data

    // Fetch the document snapshot from the 'users' collection using the given uid
    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    // Check if the document exists and contains data
    if (docSnap.data() != null) {
      // Convert the document data into a UserModel object using fromJson
      userModel = UserModel.fromJson(docSnap.data() as Map<String, dynamic>);
    }

    // Return the UserModel object, or null if the user was not found
    return userModel;
  }
}

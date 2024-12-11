import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpaceFeedback extends StatefulWidget {
  const SpaceFeedback({super.key});

  @override
  State<SpaceFeedback> createState() => _SpaceFeedbackState();
}

class _SpaceFeedbackState extends State<SpaceFeedback> {
  // Fetch feedbacks from Firestore
  Future<List<Map<String, dynamic>>> fetchFeedbacks() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser; // Get current user
    final spacesSnapshot = await firestore
        .collection('spaces') // Get all spaces owned by the current user
        .where('ownerId', isEqualTo: user?.uid)
        .get();

    final List<String> spaceIds =
        spacesSnapshot.docs.map((doc) => doc.id).toList(); // Collect space IDs
    var collection = FirebaseFirestore.instance
        .collection('feedbacks') // Get all feedbacks for those spaces
        .where('spaceId', whereIn: spaceIds);
    var querySnapshot = await collection.get();
    var feedbackList = querySnapshot.docs.map((doc) {
      return doc.data(); // Convert query snapshot to list of feedbacks
    }).toList();
    return feedbackList;
  }

  // Fetch user info based on userId
  Future<Map<String, dynamic>> fetchUserInfo(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists
        ? userDoc.data() ?? {}
        : {}; // Fetch user data or return empty map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"), // App bar with title "Feedback"
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Use FutureBuilder to display feedback data
        future: fetchFeedbacks(), // Call the fetchFeedbacks method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading spinner while waiting
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show error if fetch fails
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
                    'No feedback available.')); // Show message if no feedback found
          } else {
            var feedbacks = snapshot.data!; // Get feedback data from snapshot
            return ListView.builder(
              // Display the list of feedbacks
              padding: const EdgeInsets.all(16.0),
              itemCount: feedbacks
                  .length, // Set item count based on number of feedbacks
              itemBuilder: (context, index) {
                var feedback = feedbacks[index];
                String userId =
                    feedback['userId']; // Get userId from the feedback

                return FutureBuilder<Map<String, dynamic>>(
                  future:
                      fetchUserInfo(userId), // Fetch user info based on userId
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator()); // Show loading spinner for user data
                    } else if (userSnapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error: ${userSnapshot.error}')); // Show error if user fetch fails
                    } else if (!userSnapshot.hasData ||
                        userSnapshot.data!.isEmpty) {
                      return const Center(
                          child: Text(
                              'User info not found.')); // Show message if user data not found
                    } else {
                      var user = userSnapshot.data!; // Get user data
                      final base64Image =
                          user['image']; // Get base64 image from user data

                      Uint8List? imageBytes;
                      try {
                        imageBytes = base64Decode(
                            base64Image); // Decode base64 image data
                      } catch (e) {
                        print('Error decoding base64: $e');
                        imageBytes = null; // Handle decoding error
                      }

                      // Return a Card widget to display the feedback and user info
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: imageBytes != null
                                        ? MemoryImage(
                                            imageBytes) // Display decoded image
                                        : const AssetImage(
                                                'assets/userprofile.jpg')
                                            as ImageProvider,
                                    radius: 25,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['fullName'] ??
                                            'Unknown', // Display user full name
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        feedback['timestamp'] != null
                                            ? DateFormat('yyyy-MM-dd').format(
                                                (feedback['timestamp']
                                                        as Timestamp)
                                                    .toDate(), // Display formatted feedback timestamp
                                              )
                                            : 'Unknown date',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                feedback['feedback'] ??
                                    'No comment', // Display feedback content
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

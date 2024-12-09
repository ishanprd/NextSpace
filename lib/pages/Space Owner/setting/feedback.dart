import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    var collection = FirebaseFirestore.instance.collection('feedbacks');
    var querySnapshot = await collection.get();
    var feedbackList = querySnapshot.docs.map((doc) {
      return doc.data();
    }).toList();
    return feedbackList;
  }

  // Fetch user info based on userId
  Future<Map<String, dynamic>> fetchUserInfo(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() ?? {} : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No feedback available.'));
          } else {
            var feedbacks = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                var feedback = feedbacks[index];
                String userId = feedback['userId']; // Get userId from feedback

                return FutureBuilder<Map<String, dynamic>>(
                  future:
                      fetchUserInfo(userId), // Fetch user info based on userId
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (userSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${userSnapshot.error}'));
                    } else if (!userSnapshot.hasData ||
                        userSnapshot.data!.isEmpty) {
                      return const Center(child: Text('User info not found.'));
                    } else {
                      var user = userSnapshot.data!;
                      final base64Image = user['image'];

                      Uint8List? imageBytes;
                      try {
                        imageBytes = base64Decode(
                            base64Image); // Decode base64 image data
                      } catch (e) {
                        print('Error decoding base64: $e');
                        imageBytes = null; // Handle decoding error
                      } //
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
                                        user['fullName'] ?? 'Unknown',
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
                                                    .toDate(),
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
                                feedback['feedback'] ?? 'No comment',
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

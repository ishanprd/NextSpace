import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IssuesProblems extends StatefulWidget {
  const IssuesProblems({super.key});

  @override
  State<IssuesProblems> createState() => _IssuesProblemsState();
}

class _IssuesProblemsState extends State<IssuesProblems> {
  // List to store report data
  List<QueryDocumentSnapshot> reports = [];
  Uint8List? imageBytes;
  var fullName = 'Unknown User'; // Default value for fullName

  @override
  void initState() {
    super.initState();
    _fetchReports(); // Fetch reports when the widget is initialized
  }

  // Fetch data from Firestore
  Future<void> _fetchReports() async {
    try {
      // Fetch reports from the Firestore collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports') // Replace with your collection name
          .get();

      // Iterate through each report and fetch user data
      for (var report in snapshot.docs) {
        var userId = report['userId']; // Assuming userId field in report
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users') // Assuming users collection
            .doc(userId)
            .get();

        setState(() {
          fullName = userSnapshot['fullName'] ??
              'Unknown User'; // Default if field is missing
        });

        // Get user data from the user document with null safety
        var userAvatar = userSnapshot['image'] ?? '';

        // If the user avatar exists, decode it; else, use a default avatar
        try {
          imageBytes = base64Decode(userAvatar); // Decode base64 image data
        } catch (e) {
          print('Error decoding base64: $e');
          imageBytes = null; // Handle decoding error
        }

        // You can update the report document here if needed
      }

      setState(() {
        reports = snapshot.docs; // Store the fetched reports
      });
    } catch (e) {
      print("Error fetching reports: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Issues and Problems"),
      ),
      body: reports.isEmpty
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                var report = reports[index];

                // Fetch and handle missing fields with default values
                var reportDate = report['timestamp'];
                if (reportDate is Timestamp) {
                  reportDate = reportDate
                      .toDate()
                      .toString(); // Convert Timestamp to DateTime and then to string
                } else {
                  reportDate = 'Unknown Date';
                }

                var reportDescription = report['description'] ??
                    'No feedback available'; // Default if missing

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
                              radius: 20,
                              backgroundImage: imageBytes != null
                                  ? MemoryImage(
                                      imageBytes!) // Display decoded image
                                  : const AssetImage('assets/userprofile.jpg')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reportDate,
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
                          reportDescription, // Display report description
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

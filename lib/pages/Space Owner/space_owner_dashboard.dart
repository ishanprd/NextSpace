import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpaceOwnerDashboard extends StatefulWidget {
  const SpaceOwnerDashboard({super.key});

  @override
  _SpaceOwnerDashboardState createState() => _SpaceOwnerDashboardState();
}

class _SpaceOwnerDashboardState extends State<SpaceOwnerDashboard> {
  int bookingCount = 0;
  int feedbackCount = 0;
  double revenue = 0.0;
  bool isLoading = true;
  Uint8List? imageBytes;
  // Track loading state
  Future<List<Map<String, dynamic>>> fetchTransactions(
      List<String> spaceIds) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Step 1: Fetch bookings with successful payments for the given spaceIds
      final bookingsSnapshot = await firestore
          .collection('bookings')
          .where('spaceId', whereIn: spaceIds)
          .where('paymentStatus', isEqualTo: 'Success')
          .get();

      // Step 2: Collect user IDs from bookings
      final List<Map<String, dynamic>> transactions = [];
      final Set<String> userIds =
          bookingsSnapshot.docs.map((doc) => doc['userId'] as String).toSet();

      // Step 3: Fetch user details for the collected user IDs
      for (final userId in userIds) {
        final userDoc = await firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();

        if (userData != null) {
          // Match bookings with user data
          bookingsSnapshot.docs.forEach((bookingDoc) {
            if (bookingDoc['userId'] == userId) {
              Uint8List? imageBytes;

              // Decode base64 image if available
              try {
                final base64Image = userData['image'] ?? '';
                if (base64Image.isNotEmpty) {
                  imageBytes = base64Decode(base64Image);
                }
              } catch (e) {
                print('Error decoding base64 image: $e');
              }

              transactions.add({
                'name': userData['fullName'],
                'photo': imageBytes, // Store the decoded image bytes
                'price': bookingDoc['price'],
                'date': bookingDoc['date'],
              });
            } // Set
          });
        }
      }
      return transactions;
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOverviewData();
  }

  Future<void> fetchOverviewData() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("No user is currently signed in.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Step 1: Fetch space IDs owned by the current user
      final spacesSnapshot = await firestore
          .collection('spaces')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      final List<String> spaceIds =
          spacesSnapshot.docs.map((doc) => doc.id).toList();

      if (spaceIds.isEmpty) {
        print("No spaces found for the current user.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Step 2: Fetch booking count and revenue
      final bookingsSnapshot = await firestore
          .collection('bookings')
          .where('spaceId', whereIn: spaceIds)
          .get();

      setState(() {
        bookingCount = bookingsSnapshot.docs.length;
        revenue = bookingsSnapshot.docs.fold(
          0.0,
          (sum, doc) {
            final price = doc['price'];
            final priceValue =
                (price is String) ? double.tryParse(price) : price;
            return sum + (priceValue ?? 0.0);
          },
        );
      });
      final transactions = await fetchTransactions(spaceIds);
      setState(() {
        transactionList =
            transactions; // Store fetched transactions for rendering
        isLoading = false;
      });

      // Step 3: Fetch feedback count
      final feedbackSnapshot = await firestore
          .collection('feedbacks')
          .where('spaceId', whereIn: spaceIds)
          .get();

      setState(() {
        feedbackCount = feedbackSnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching overview data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Dashboard",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatCard(
                        title: "Booked",
                        value: "$bookingCount",
                        increment: "Updated",
                        color: Colors.blue,
                        icon: Icons
                            .event_available, // Calendar or event icon for bookings
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        title: "Revenue",
                        value: "$revenue",
                        increment: "Updated",
                        color: Colors.pink,
                        icon: Icons
                            .currency_rupee_sharp, // Money icon for revenue
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatCard(
                        title: "Feedback",
                        value: "$feedbackCount",
                        increment: "Updated",
                        color: Colors.red,
                        icon: Icons.feedback, // Feedback or comment icon
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildTransactionList(), // Transactions List
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String increment,
    required Color color,
    required IconData icon, // Add an icon parameter
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            // Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: TextStyle(color: color, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    increment,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> transactionList = [];

  Widget _buildTransactionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: transactionList.length,
      itemBuilder: (context, index) {
        final transaction = transactionList[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: CircleAvatar(
            backgroundImage: transaction['photo'] != null
                ? MemoryImage(transaction['photo'])
                : const AssetImage('assets/applogo.png') as ImageProvider,
            radius: 24,
          ),
          title: Text(
            transaction['name'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            transaction['date']?.toString() ?? 'No date',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Text(
            "Rs ${transaction['price'] ?? '0.00'}",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

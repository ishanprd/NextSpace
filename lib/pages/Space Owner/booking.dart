import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? currentUserId; // Logged-in user's ID
  String? spaceId; // Space ID for the user's owned space

  String? bookingId;

  List<Map<String, dynamic>> activeRequests =
      []; // For storing active booking requests
  List<Map<String, dynamic>> bookingHistory = []; // For storing booking history
  List<Map<String, dynamic>> cancelledBookings =
      []; // For storing cancelled bookings

  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
    _getUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;

      DocumentSnapshot userSnapshot = (await _firestore
              .collection('spaces')
              .where('ownerId', isEqualTo: currentUserId)
              .get())
          .docs
          .first;

      spaceId = userSnapshot.id;
      _fetchBookings();
    }
  }

  // Fetch user data (name and photo) from users collection
  Future<Map<String, String?>> _getUserDetails(String userId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();
    var userData = userSnapshot.data() as Map<String, dynamic>?;

    return {
      'userName': userData?['fullName'] ?? 'Unknown',
      'userPhoto': userData?['image'] ?? 'assets/default_user.jpg',
    };
  }

  // Fetching bookings for the specific space owned by the user
  Future<void> _fetchBookings() async {
    if (spaceId == null) return;

    setState(() {
      isLoading = true; // Start loading
    });

    QuerySnapshot bookingSnapshot = await _firestore
        .collection('bookings')
        .where('spaceId', isEqualTo: spaceId)
        .get();

    List<Map<String, dynamic>> fetchedActiveRequests = [];
    List<Map<String, dynamic>> fetchedBookingHistory = [];
    List<Map<String, dynamic>> fetchedCancelledBookings = [];

    for (var doc in bookingSnapshot.docs) {
      var bookingData = doc.data() as Map<String, dynamic>;
      String status = bookingData['status'] ?? '';
      String userId = bookingData[
          'userId']; // Get the userId of the person who made the booking

      // Fetch the user's name and photo based on the userId
      bookingId = doc.id;
      Map<String, String?> userDetails = await _getUserDetails(userId);

      // Add user details to the booking data
      bookingData['bookingId'] = bookingId;
      bookingData['userName'] = userDetails['userName'];
      bookingData['userPhoto'] = userDetails['userPhoto'];

      // Categorizing bookings based on status
      if (status == 'Pending') {
        fetchedActiveRequests.add(bookingData);
      } else if (status == 'Accepted') {
        fetchedBookingHistory.add(bookingData);
      } else if (status == 'Cancelled') {
        fetchedCancelledBookings.add(bookingData);
      }
    }

    setState(() {
      activeRequests = fetchedActiveRequests;
      bookingHistory = fetchedBookingHistory;
      cancelledBookings = fetchedCancelledBookings;
      isLoading = false; // Stop loading
    });
  }

  // Function to handle accepting a booking request

// Function to handle accepting a booking request
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection(
              'bookings') // Replace 'bookings' with your collection name
          .doc(bookingId) // Use the document ID of the booking
          .update({'status': newStatus}); // Update the status field

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking status updated to $newStatus")),
      );

      // Refresh the bookings after the update
      await _fetchBookings();
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update Booking status: $e")),
      );
    }
  }

  // Function to handle the building of the order list for each tab
  Widget _buildOrderList(String listType) {
    List<Map<String, dynamic>> orders = [];
    if (listType == "Requests") {
      orders = activeRequests;
    } else if (listType == "History") {
      orders = bookingHistory;
    } else if (listType == "Cancelled") {
      orders = cancelledBookings;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: orders.isEmpty
          ? const Center(
              child: Text(
                "No data available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final user = orders[index];
                final base64Image = user['userPhoto'];

                Uint8List? imageBytes;
                try {
                  imageBytes =
                      base64Decode(base64Image); // Decode base64 image data
                } catch (e) {
                  print('Error decoding base64: $e');
                  imageBytes = null; // Handle decoding error
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes) // Display decoded image
                          : const AssetImage('assets/userprofile.jpg')
                              as ImageProvider,
                      radius: 25,
                    ),
                    title: Text(
                      orders[index]["userName"] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: ${orders[index]['date']}"),
                        Text("Price: Rs. ${orders[index]['price']}"),
                        Text("Status: ${orders[index]['status']}"),
                      ],
                    ),
                    trailing: listType == "Requests"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () {
                                  // Pass the correct bookingId for the selected booking
                                  updateBookingStatus(
                                      orders[index]['bookingId'], 'Accepted');
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Pass the correct bookingId for the selected booking
                                  updateBookingStatus(
                                      orders[index]['bookingId'], 'Cancelled');
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
            child: Text(
          "Space Management",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        )),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Requests"),
            Tab(text: "History"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList("Requests"),
                _buildOrderList("History"),
                _buildOrderList("Cancelled"),
              ],
            ),
    );
  }
}

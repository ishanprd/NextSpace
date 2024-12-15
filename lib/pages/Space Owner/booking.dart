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

  bool isLoading = true;
  var userId; // Track loading state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
    //fetch the user data
    _getUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  //functions for get users

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
      setState(() {
        isLoading = false; // Set loading state to true, indicating the data is being fetched.
      });
    }
    else{
      setState(() {
        isLoading = false; // Set loading state to true, indicating the data is being fetched.
      });
    }

  }

  ///function to send notifications

  Future<void> sendNotification(
      String userId, String title, String message) async {
    try {
      // Add notification details to Firestore
      final notificationData = {
        'userId': userId,
        'title': title,
        'body': message,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(notificationData);

      print("Notification added to Firestore successfully!");

      if (notificationData.isNotEmpty) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification");
      }
    } catch (e) {
      print("Error calling function: $e");
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

//fetch the booking data
  Future<void> _fetchBookings() async {
    if (spaceId == null)
      return; // Return early if spaceId is null, no need to fetch bookings.

    setState(() {
      isLoading =
          true; // Set loading state to true, indicating the data is being fetched.
    });

    try {
      // Fetch bookings from Firestore where 'spaceId' matches the current spaceId.
      QuerySnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .where('spaceId', isEqualTo: spaceId)
          .get();

      // Initialize lists to store bookings based on their status.
      List<Map<String, dynamic>> fetchedActiveRequests = [];
      List<Map<String, dynamic>> fetchedBookingHistory = [];
      List<Map<String, dynamic>> fetchedCancelledBookings = [];

      // Loop through each booking document in the snapshot.
      for (var doc in bookingSnapshot.docs) {
        var bookingData = doc.data() as Map<String, dynamic>;
        String status = bookingData['status'] ?? ''; // Get the booking status.
        String userId = bookingData[
            'userId']; // Get the user ID associated with the booking.

        bookingId = doc.id; // Store the booking document ID.
        Map<String, String?> userDetails =
            await _getUserDetails(userId); // Fetch user details.

        // Add user details to the booking data.
        bookingData['bookingId'] = bookingId;
        bookingData['userName'] = userDetails['userName'];
        bookingData['userPhoto'] = userDetails['userPhoto'];

        // Categorize the booking based on its status.
        if (status == 'Pending') {
          fetchedActiveRequests.add(
              bookingData); // Add to active requests if status is 'Pending'.
        } else if (status == 'Accepted') {
          fetchedBookingHistory.add(
              bookingData); // Add to booking history if status is 'Accepted'.
        } else if (status == 'Cancelled') {
          fetchedCancelledBookings.add(
              bookingData); // Add to cancelled bookings if status is 'Cancelled'.
        }
      }

      // Update state if the widget is still mounted (to prevent memory leaks).
      if (mounted) {
        setState(() {
          activeRequests =
              fetchedActiveRequests; // Update the list of active requests.
          bookingHistory = fetchedBookingHistory; // Update the booking history.
          cancelledBookings =
              fetchedCancelledBookings; // Update the list of cancelled bookings.
          isLoading = false; // Stop the loading state as data has been fetched.
        });
      }
    } catch (e) {
      // Handle any errors that occur during the data fetching.
      if (mounted) {
        setState(() {
          isLoading = false; // Stop the loading state if an error occurs.
        });
      }
      print(
          "Error fetching bookings: $e"); // Print the error for debugging purposes.
    }
  }

// Function to handle accepting a booking request
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection(
              'bookings') // Replace 'bookings' with your collection name
          .doc(bookingId) // Use the document ID of the booking
          .update({'status': newStatus}); // Update the status field
      if (newStatus == 'Accepted') {
        // Send a notification to the user
        var bookingSnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get();

        setState(() {
          userId = bookingSnapshot['userId'];
        });
        await sendNotification(userId, 'Booking Status',
            'Your booking request has been accepted.');
      } else if (newStatus == 'Cancelled') {
        // Send a notification to the user
        await sendNotification(userId, 'Booking Status',
            'Your booking request has been Cancelled.');
      }
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

    // Show loading indicator if data is still being fetched
    // if (isLoading) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    // Show a message if the orders list is empty
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: orders.isEmpty
          ? const Center(
        child: Text(
          "No bookings available",
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
            imageBytes = base64Decode(base64Image); // Decode base64 image data
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
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      // Pass the correct bookingId for the selected booking
                      updateBookingStatus(
                          orders[index]['bookingId'], 'Accepted');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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
      body:  // Show loading
          TabBarView(
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

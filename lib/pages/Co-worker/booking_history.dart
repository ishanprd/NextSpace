import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication.
import 'package:flutter/material.dart'; // For Flutter UI components.
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore database interactions.

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  // Firestore reference and Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Dynamically fetch the user ID of the currently authenticated user.
    final String userId = _auth.currentUser?.uid ??
        ''; // If no user is authenticated, userId is set to an empty string.

    // Firestore query to fetch bookings where the userId matches the current user's ID.
    final Query bookings = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Booking History", // Title for the app bar.
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blue, // App bar background color.
        automaticallyImplyLeading:
            false, // Do not show the back button in the app bar.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for the body content.
        child: StreamBuilder<QuerySnapshot>(
          // StreamBuilder listens to changes in the Firestore bookings collection.
          stream: bookings.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for data.
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // If no data is found, show a message.
              return const Center(child: Text("No booking history found."));
            }

            // If data is found, extract the booking documents.
            final bookingHistory = snapshot.data!.docs;

            return ListView.builder(
              // Display the booking history in a list.
              itemCount: bookingHistory.length,
              itemBuilder: (context, index) {
                final booking = bookingHistory[index];
                final data = booking.data() as Map<String,
                    dynamic>; // Convert Firestore document to map.

                return Card(
                  margin: const EdgeInsets.only(
                      bottom: 16.0), // Add margin between cards.
                  elevation: 3, // Card shadow elevation.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Rounded corners for the card.
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16.0), // Padding inside the card.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data["spaceName"] ??
                              "N/A", // Show the space name from the booking data.
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold, // Bold style for space name.
                          ),
                        ),
                        const SizedBox(height: 8), // Space between elements.
                        Text(
                          "Date: ${data["date"] ?? "N/A"}", // Show booking date.
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey, // Grey color for the date.
                          ),
                        ),
                        const SizedBox(height: 8), // Space between elements.
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Space out status and price.
                          children: [
                            Text(
                              "Status: ${data["status"] ?? "N/A"}", // Show booking status (e.g., confirmed, cancelled).
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: data["status"] == "Cancelled"
                                    ? Colors
                                        .red // Red color for cancelled bookings.
                                    : data["status"] == "Confirmed"
                                        ? Colors
                                            .blue // Blue color for confirmed bookings.
                                        : Colors
                                            .green, // Green for other statuses.
                              ),
                            ),
                            Text(
                              "Price: ${data["price"] ?? "N/A"}", // Show the price of the booking.
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green, // Green color for price.
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

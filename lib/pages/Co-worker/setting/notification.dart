import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication for user authentication.
import 'package:flutter/material.dart'; // Flutter UI components.
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database interactions.

class CoworkerNotification extends StatefulWidget {
  const CoworkerNotification({super.key});

  @override
  State<CoworkerNotification> createState() => _CoworkerNotificationState();
}

class _CoworkerNotificationState extends State<CoworkerNotification> {
  // Stream to listen for notifications for the user.
  late Stream<QuerySnapshot>? _notificationsStream;
  String? userId; // The user's ID for querying notifications.

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Initialize notifications when the widget is created.
  }

  // Function to initialize notifications based on the logged-in user.
  Future<void> _initializeNotifications() async {
    // Wait for the FirebaseAuth instance to initialize and get the current user.
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If a user is logged in, fetch notifications from Firestore for this user.
      setState(() {
        userId = user.uid; // Store the user's ID.
        _notificationsStream = FirebaseFirestore.instance
            .collection(
                'notifications') // Collection where notifications are stored.
            .where('userId',
                isEqualTo: userId) // Filter notifications for this user.
            .orderBy('createdAt',
                descending: true) // Order by creation date in descending order.
            .snapshots(); // Listen for real-time updates.
      });
    } else {
      // If no user is logged in, set the notifications stream to null.
      setState(() {
        _notificationsStream = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"), // Title of the app bar.
      ),
      body: _notificationsStream == null
          // If no user is logged in, show a message indicating that.
          ? const Center(child: Text("No user logged in."))
          : StreamBuilder<QuerySnapshot>(
              // StreamBuilder listens for real-time updates in the notifications stream.
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading spinner while waiting for data.
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // If no data is found, show a message indicating no notifications.
                  return const Center(child: Text("No notifications found."));
                }

                final notifications =
                    snapshot.data!.docs; // Extract the notification documents.

                return ListView.builder(
                  // Display the notifications in a list.
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index].data() as Map<String, dynamic>;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Rounded corners for each card.
                      ),
                      elevation: 4, // Card shadow elevation.
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16), // Margin between cards.
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Padding inside the card.
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors
                                    .green), // Icon to indicate notification.
                            const SizedBox(
                                width: 12), // Space between the icon and text.
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    notification['title'] ??
                                        'Notification', // Display notification title.
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          8), // Space between title and body text.
                                  Text(
                                    notification['body'] ??
                                        '', // Display notification body.
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors
                                          .grey, // Grey color for body text.
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors
                                      .grey), // Close button to delete notification.
                              onPressed: () {
                                // Delete the notification from Firestore when the close button is pressed.
                                FirebaseFirestore.instance
                                    .collection('notifications')
                                    .doc(notifications[index]
                                        .id) // Get the notification by ID.
                                    .delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

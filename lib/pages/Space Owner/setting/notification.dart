import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpaceNotification extends StatefulWidget {
  const SpaceNotification({super.key});

  @override
  State<SpaceNotification> createState() => _SpaceNotificationState();
}

class _SpaceNotificationState extends State<SpaceNotification> {
  late Stream<QuerySnapshot>? _notificationsStream;
  String? userId;
  String? spaceId;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Get the current user ID
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        userId = user.uid;

        // Query the spaces collection to find a space matching the current userId
        final spacesQuery = await FirebaseFirestore.instance
            .collection('spaces') // Replace with your spaces collection name
            .where('ownerId', isEqualTo: userId) // Match userId in spaces
            .limit(1)
            .get();

        if (spacesQuery.docs.isNotEmpty) {
          final spaceDoc = spacesQuery.docs.first;
          spaceId = spaceDoc.id; // Retrieve the space ID

          // Fetch notifications related to the space ID
          setState(() {
            _notificationsStream = FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: spaceId)
                .orderBy('createdAt', descending: true)
                .snapshots();
          });
        } else {
          setState(() {
            _notificationsStream = null; // No space found for the user
          });
        }
      } else {
        setState(() {
          _notificationsStream = null; // No user logged in
        });
      }
    } catch (e) {
      print("Error initializing notifications: $e");
      setState(() {
        _notificationsStream = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: _notificationsStream == null
          ? const Center(
              child: Text("No user logged in or no notifications available."))
          : StreamBuilder<QuerySnapshot>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No notifications found."));
                }

                final notifications = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index].data() as Map<String, dynamic>;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    notification['title'] ?? 'Notification',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notification['body'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('notifications')
                                    .doc(notifications[index].id)
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

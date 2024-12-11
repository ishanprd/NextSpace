import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpaceManage extends StatefulWidget {
  const SpaceManage({super.key});

  @override
  State<SpaceManage> createState() => _SpaceManageState();
}

class _SpaceManageState extends State<SpaceManage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lists to store spaces based on their status
  List<Map<String, dynamic>> activeRequests = [];
  List<Map<String, dynamic>> bookingSpace = [];
  List<Map<String, dynamic>> cancelledBookings = [];

  // Loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
    _fetchSpaces(); // Fetch spaces from Firestore
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  // Fetch spaces and owners from Firestore based on their status
  Future<void> _fetchSpaces() async {
    try {
      // Fetch spaces
      QuerySnapshot spacesSnapshot =
          await FirebaseFirestore.instance.collection('spaces').get();
      //fetch the space data
      List<Map<String, dynamic>> spaces = spacesSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'spaceName': doc['spaceName'],
          'monthlyPrice': doc['hoursPrice'],
          'status': doc['status'],
          'ownerId': doc['ownerId'],
        };
      }).toList();

      // Fetch the id of owner
      Set ownerIds = spaces.map((space) => space['ownerId']).toSet();
//fetch the user
      QuerySnapshot ownersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'space_owner')
          .where('uid', whereIn: ownerIds.toList())
          .get();

      Map<String, Map<String, dynamic>> owners = {
        for (var doc in ownersSnapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>
      };

      // Combine spaces with their owners
      for (var space in spaces) {
        space['ownerName'] = owners[space['ownerId']]?['fullName'] ?? 'Unknown';
        space['ownerPhoto'] =
            owners[space['ownerId']]?['image'] ?? 'assets/userprofile.jpg';
      }

      // Split spaces into different categories
      setState(() {
        activeRequests =
            spaces.where((space) => space['status'] == 'Pending').toList();
        bookingSpace =
            spaces.where((space) => space['status'] == 'Accepted').toList();
        cancelledBookings =
            spaces.where((space) => space['status'] == 'Cancelled').toList();
        isLoading = false; // Set loading to false when data is fetched
      });
    } catch (e) {
      print("Error fetching spaces: $e");
      setState(() {
        isLoading = false; // Set loading to false even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: const Center(
            child: Text(
          "Space Manage",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        )),
        elevation: 0, // Removes shadow below the app bar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Requests"),
            Tab(text: "Space"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : TabBarView(
              controller: _tabController,
              children: [
                // Active Requests Tab
                _buildOrderList("Requests"),
                // Booking Space Tab
                _buildOrderList("Space"),
                // Cancelled Bookings Tab
                _buildOrderList("Cancelled"),
              ],
            ),
    );
  }

  Future<void> updateSpaceStatus(String spaceId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('spaces') // Replace 'spaces' with your collection name
          .doc(spaceId) // Use the document ID of the space
          .update({'status': newStatus}); // Update the status field
      sendNotification(spaceId, 'Space Status', 'Booking has been $newStatus');
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Space status updated to $newStatus")),
      );

      // Refresh the spaces after the update
      await _fetchSpaces();
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update space status: $e")),
      );
    }
  }

  // Reusable widget to build order lists
  Widget _buildOrderList(String listType) {
    List<Map<String, dynamic>> orders = [];
    if (listType == "Requests") {
      orders = activeRequests;
    } else if (listType == "Space") {
      orders = bookingSpace;
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
                final base64Image = user['ownerPhoto'];

                Uint8List? imageBytes;

                if (base64Image.isNotEmpty) {
                  try {
                    imageBytes =
                        base64Decode(base64Image); // Decode base64 image data
                  } catch (e) {
                    print('Error decoding base64: $e');
                    imageBytes = null; // Handle decoding error
                  }
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
                      orders[index]["ownerName"] ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Space: ${orders[index]['spaceName'] ?? 'Unknown'}"),
                        Text(
                            "Price: Rs. ${orders[index]['monthlyPrice'] ?? 'N/A'}"),
                        Text("Status: ${orders[index]['status'] ?? 'Unknown'}"),
                      ],
                    ),
                    trailing: listType == "Requests"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () async {
                                  // Add accept request logic here
                                  updateSpaceStatus(
                                      orders[index]['id'], 'Accepted');
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Add delete request logic here
                                  await updateSpaceStatus(
                                      orders[index]['id'], 'Cancelled');
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
}

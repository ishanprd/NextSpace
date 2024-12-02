import 'package:flutter/material.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample lists for different order statuses
  List<Map<String, dynamic>> activeRequests = [
    {
      "userName": "John Doe",
      "userPhoto": "assets/userprofile.jpg", // User photo asset path
      "price": 1500,
      "peopleCount": 5,
      "status": "Pending",
      "spaceName": "Conference Hall A"
    },
    {
      "userName": "Jane Smith",
      "userPhoto": "assets/userprofile2.jpg",
      "price": 1000,
      "peopleCount": 3,
      "status": "Pending",
      "spaceName": "Meeting Room B"
    },
  ];

  List<Map<String, dynamic>> bookingHistory = [
    {
      "userName": "Alice Johnson",
      "userPhoto": "assets/userprofile3.jpg",
      "price": 2000,
      "peopleCount": 10,
      "status": "Completed",
      "spaceName": "Event Hall C"
    },
  ];

  List<Map<String, dynamic>> cancelledBookings = [
    {
      "userName": "Bob Williams",
      "userPhoto": "assets/userprofile4.jpg",
      "price": 1200,
      "peopleCount": 4,
      "status": "Cancelled",
      "spaceName": "Workspace D"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to handle accepting a booking request
  void acceptRequest(int index) {
    setState(() {
      activeRequests[index]["status"] = "Accepted";
    });
  }

  // Function to delete a request
  void deleteRequest(String listType, int index) {
    setState(() {
      if (listType == "Requests") {
        activeRequests.removeAt(index);
      } else if (listType == "History") {
        bookingHistory.removeAt(index);
      } else if (listType == "Cancelled") {
        cancelledBookings.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/email.png',
            fit: BoxFit.cover,
          ), // Replace with your logo
        ),
        automaticallyImplyLeading: false, // Remove the back button
        title: const Center(child: Text("Space Management")),
        elevation: 0, // Removes shadow below the app bar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Requests"),
            Tab(text: "History"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Requests Tab
          _buildOrderList("Requests"),
          // Booking History Tab
          _buildOrderList("History"),
          // Cancelled Bookings Tab
          _buildOrderList("Cancelled"),
        ],
      ),
    );
  }

  // Reusable widget to build order lists
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(orders[index]["userPhoto"]),
                      radius: 25,
                    ),
                    title: Text(
                      orders[index]["userName"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Space: ${orders[index]['spaceName']}"),
                        Text("People: ${orders[index]['peopleCount']}"),
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
                                  acceptRequest(index);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteRequest(listType, index);
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

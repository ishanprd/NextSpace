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
  bool isLoading = true; // Track loading state

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
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        title: "Revenue",
                        value: "Rs $revenue",
                        increment: "Updated",
                        color: Colors.pink,
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
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
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
    );
  }

  Widget _buildTransactionList() {
    // Sample dynamic data (you can replace this with actual data)
    List<Map<String, String>> transactions = [
      {
        "name": "Product Design Handbook",
        "price": "\$30.00",
        "purchases": "88 purchases",
        "color": "green",
      },
      {
        "name": "Website UI Kit",
        "price": "\$8.00",
        "purchases": "68 purchases",
        "color": "blue",
      },
      {
        "name": "Icon UI Kit",
        "price": "\$8.00",
        "purchases": "53 purchases",
        "color": "orange",
      },
      {
        "name": "E-commerce Web Template",
        "price": "\$10.00",
        "purchases": "48 purchases",
        "color": "purple",
      },
      {
        "name": "Wireframing Kit",
        "price": "\$8.00",
        "purchases": "51 purchases",
        "color": "red",
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        Color itemColor;
        switch (transaction["color"]) {
          case "green":
            itemColor = Colors.green;
            break;
          case "blue":
            itemColor = Colors.blue;
            break;
          case "orange":
            itemColor = Colors.orange;
            break;
          case "purple":
            itemColor = Colors.purple;
            break;
          case "red":
            itemColor = Colors.red;
            break;
          default:
            itemColor = Colors.grey;
        }
        return _ProductTile(
          name: transaction["name"]!,
          price: transaction["price"]!,
          purchases: transaction["purchases"]!,
          color: itemColor,
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String name;
  final String price;
  final String purchases;
  final Color color;

  const _ProductTile({
    required this.name,
    required this.price,
    required this.purchases,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(Icons.shopping_bag, color: color),
      ),
      title: Text(name),
      subtitle: Text("$price · $purchases"),
    );
  }
}

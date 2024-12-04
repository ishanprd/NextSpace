import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Variables to store fetched data
  int usersCount = 0;
  int bookedCount = 0;
  int feedbackCount = 0;
  int revenueCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchOverviewData(); // Fetch data when widget is initialized
  }

  // Fetch data from Firestore
  Future<void> _fetchOverviewData() async {
    try {
      // Fetch user count
      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        usersCount = userSnapshot.docs.length;
      });

      // Fetch booked count (replace with actual collection)
      QuerySnapshot bookedSnapshot =
          await FirebaseFirestore.instance.collection('bookings').get();
      setState(() {
        bookedCount = bookedSnapshot.docs.length;
      });

      // Fetch feedback count (replace with actual collection)
      QuerySnapshot feedbackSnapshot =
          await FirebaseFirestore.instance.collection('feedback').get();
      setState(() {
        feedbackCount = feedbackSnapshot.docs.length;
      });

      // Fetch revenue (this could be from a 'revenue' collection or calculated differently)
      QuerySnapshot revenueSnapshot =
          await FirebaseFirestore.instance.collection('transactions').get();
      setState(() {
        revenueCount = revenueSnapshot.docs.fold<int>(
            0, (previousValue, doc) => previousValue + (doc['amount'] as int));
      });
    } catch (e) {
      print("Error fetching overview data: $e");
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
        child: SingleChildScrollView(
          child: Column(
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
                    title: "Users",
                    value: "$usersCount",
                    increment: "100↑", // You can update this to dynamic data
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    title: "Booked",
                    value: "$bookedCount",
                    increment: "10k↑",
                    color: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatCard(
                    title: "Feedback",
                    value: "$feedbackCount",
                    increment: "5↓",
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    title: "Revenue",
                    value: "\$$revenueCount", // Dynamically display revenue
                    increment: "50k↑",
                    color: Colors.pink,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Pie Charts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const AspectRatio(
                aspectRatio: 1.5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: PieChartWidget(),
                ),
              ),
              const Text(
                "Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildTransactionList(),
            ],
          ),
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

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: 40,
            color: Colors.blue,
            title: 'Users\n40%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: 30,
            color: Colors.red,
            title: 'Issue\n30%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.green,
            title: 'Revenue\n20%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: 10,
            color: Colors.yellow,
            title: 'Spaces\n10%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

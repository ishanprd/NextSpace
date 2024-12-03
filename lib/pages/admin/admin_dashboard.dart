import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
                    value: "12k",
                    increment: "100↑",
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    title: "Booked",
                    value: "50k",
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
                    value: "10",
                    increment: "5↓",
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    title: "Revenue",
                    value: "108k",
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
    // Sample dynamic data
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

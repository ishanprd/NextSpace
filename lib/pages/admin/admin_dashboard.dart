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
  bool isLoading = true; // To track the loading state

  @override
  void initState() {
    super.initState();
    _fetchOverviewData(); // Fetch data when widget is initialized
  }

  // Fetch data from Firestore
  Future<void> _fetchOverviewData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch user count
      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        usersCount = userSnapshot.docs.length;
      });

      // Fetch booked count (replace with actual collection)
      QuerySnapshot bookedSnapshot =
          await FirebaseFirestore.instance.collection('reports').get();
      setState(() {
        bookedCount = bookedSnapshot.docs.length;
      });

      // Fetch feedback count (replace with actual collection)
      QuerySnapshot feedbackSnapshot =
          await FirebaseFirestore.instance.collection('spaces').get();
      setState(() {
        feedbackCount = feedbackSnapshot.docs.length;
      });

      // Fetch revenue (this could be from a 'revenue' collection or calculated differently)
    } catch (e) {
      print("Error fetching overview data: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop showing the loading spinner
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Overview",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatCard(
                          title: "Users",
                          value: "$usersCount",
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          title: "Spaces",
                          value: "$bookedCount",
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatCard(
                          title: "Report and Problems",
                          value: "$feedbackCount",
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Pie Charts",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PieChartWidget(
                          usersCount: usersCount,
                          spacesCount: bookedCount,
                          issuesCount: feedbackCount,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Bar Charts",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BarChartWidget(
                          usersCount: usersCount,
                          spacesCount: bookedCount,
                          issuesCount: feedbackCount,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
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
          ],
        ),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final int usersCount;
  final int spacesCount;
  final int issuesCount;

  const PieChartWidget({
    super.key,
    required this.usersCount,
    required this.spacesCount,
    required this.issuesCount,
  });

  @override
  Widget build(BuildContext context) {
    final int total = usersCount + spacesCount + issuesCount;

    // Calculate percentages
    final double usersPercentage = (usersCount / total) * 100;
    final double spacesPercentage = (spacesCount / total) * 100;
    final double issuesPercentage = (issuesCount / total) * 100;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: usersPercentage,
            color: Colors.blue,
            title: 'Users\n${usersPercentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: issuesPercentage,
            color: Colors.red,
            title: 'Issues\n${issuesPercentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: spacesPercentage,
            color: Colors.green,
            title: 'Spaces\n${spacesPercentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final int usersCount;
  final int spacesCount;
  final int issuesCount;

  const BarChartWidget({
    super.key,
    required this.usersCount,
    required this.spacesCount,
    required this.issuesCount,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare the data for the bar chart
    final barData = [
      BarChartGroupData(
        x: 0,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: usersCount.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: issuesCount.toDouble(),
            color: Colors.red,
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: spacesCount.toDouble(),
            color: Colors.green,
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: false),
        barGroups: barData,
        minY: 0,
        maxY: (usersCount > spacesCount && usersCount > issuesCount)
            ? usersCount.toDouble()
            : (spacesCount > issuesCount)
                ? spacesCount.toDouble()
                : issuesCount.toDouble(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewUsers extends StatefulWidget {
  const ViewUsers({super.key});

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lists to store users based on roles
  List<Map<String, dynamic>> coWorkers = [];
  List<Map<String, dynamic>> spaceOwners = [];

  // Loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
    _fetchUsers(); // Fetch users from Firestore
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch users from Firestore based on their role
  Future<void> _fetchUsers() async {
    try {
      // Fetch users from Firestore where role is 'Co-worker'
      QuerySnapshot coWorkersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'coworker')
          .get();

      // Fetch users from Firestore where role is 'Space Owner'
      QuerySnapshot spaceOwnersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'space_owner')
          .get();

      // Populate the lists based on the query results
      setState(() {
        coWorkers = coWorkersSnapshot.docs.map((doc) {
          return {
            'userName': doc['fullName'],
            'userPhoto':
                doc['imageUrl'] ?? 'assets/userprofile.jpg', // Default image
            'role': doc['role'],
          };
        }).toList();

        spaceOwners = spaceOwnersSnapshot.docs.map((doc) {
          return {
            'userName': doc['fullName'],
            'userPhoto':
                doc['imageUrl'] ?? 'assets/userprofile.jpg', // Default image
            'role': doc['role'],
          };
        }).toList();

        isLoading = false; // Set loading to false when data is fetched
      });
    } catch (e) {
      print("Error fetching users: $e");
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
            "View Users",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
        ),
        elevation: 0, // Removes shadow below the app bar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Co-workers"),
            Tab(text: "Space Owners"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : TabBarView(
              controller: _tabController,
              children: [
                // Co-workers Tab
                _buildUserList(coWorkers),
                // Space Owners Tab
                _buildUserList(spaceOwners),
              ],
            ),
    );
  }

  // Reusable widget to build user lists
  Widget _buildUserList(List<Map<String, dynamic>> userList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: userList.isEmpty
          ? const Center(
              child: Text(
                "No users available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(userList[index]["userPhoto"]),
                      radius: 25,
                    ),
                    title: Text(
                      userList[index]["userName"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Role: ${userList[index]['role']}"),
                  ),
                );
              },
            ),
    );
  }
}

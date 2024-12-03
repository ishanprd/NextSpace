import 'package:flutter/material.dart';

class ViewUsers extends StatefulWidget {
  const ViewUsers({super.key});

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample lists for different roles
  List<Map<String, dynamic>> coWorkers = [
    {
      "userName": "John Doe",
      "userPhoto": "assets/userprofile.jpg",
      "role": "Co-worker",
    },
    {
      "userName": "Jane Smith",
      "userPhoto": "assets/userprofile2.jpg",
      "role": "Co-worker",
    },
  ];

  List<Map<String, dynamic>> spaceOwners = [
    {
      "userName": "Alice Johnson",
      "userPhoto": "assets/userprofile3.jpg",
      "role": "Space Owner",
    },
    {
      "userName": "Bob Williams",
      "userPhoto": "assets/userprofile4.jpg",
      "role": "Space Owner",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: TabBarView(
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
                      backgroundImage: AssetImage(userList[index]["userPhoto"]),
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

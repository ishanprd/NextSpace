import 'package:flutter/material.dart';
import 'package:nextspace/pages/admin/admin_dashboard.dart';
import 'package:nextspace/pages/admin/admin_setting.dart';
import 'package:nextspace/pages/admin/space_manage.dart';
import 'package:nextspace/pages/admin/view_users.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int myIndex = 0; // Current tab index
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> screenList = [
    const AdminDashboard(),
    const SpaceManage(),
    const ViewUsers(),
    const AdminSetting(),
  ];

  void onTabTapped(int index) {
    setState(() {
      myIndex = index;
    });
    // Animate to the new page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300), // Animation duration
      curve: Curves.easeInOut, // Animation curve
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // Navigate to the selected tab
        iconSize: 30,
        type: BottomNavigationBarType.shifting,
        currentIndex: myIndex, // Highlight current tab
        selectedItemColor: Colors.blueAccent, // Selected item color
        unselectedItemColor: Colors.black, // Unselected item color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_rounded),
            label: "Space Manage",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_agenda),
            label: "View Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable manual swiping
        children: screenList,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller to free resources
    super.dispose();
  }
}

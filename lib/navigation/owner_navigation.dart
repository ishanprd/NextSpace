import 'package:flutter/material.dart';
import 'package:nextspace/pages/Space%20Owner/booking.dart';
import 'package:nextspace/pages/Space%20Owner/space_message.dart';
import 'package:nextspace/pages/Space%20Owner/space_owner_dashboard.dart';
import 'package:nextspace/pages/Space%20Owner/space_page.dart';
import 'package:nextspace/pages/Space%20Owner/space_setting.dart';

class SpaceOwnerNavigation extends StatefulWidget {
  const SpaceOwnerNavigation({super.key});

  @override
  State<SpaceOwnerNavigation> createState() => _SpaceOwnerNavigationState();
}

class _SpaceOwnerNavigationState extends State<SpaceOwnerNavigation> {
  int myIndex = 0;
  final PageController _pageController = PageController(initialPage: 2);

  final List<Widget> screenList = [
    const SpaceOwnerDashboard(),
    const SpacePage(),
    const Booking(),
    const SpaceMessage(),
    const SpaceSetting(),
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
        onTap: onTabTapped,
        iconSize: 30,
        type: BottomNavigationBarType.shifting,
        currentIndex: myIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard),
            label: "My Space",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "view space",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Message",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: "Setting",
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
}

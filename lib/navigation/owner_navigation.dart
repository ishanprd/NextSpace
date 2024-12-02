import 'package:flutter/material.dart';
import 'package:nextspace/pages/Space%20Owner/booking.dart';
import 'package:nextspace/pages/Space%20Owner/space_feedback.dart';
import 'package:nextspace/pages/Space%20Owner/space_owner_dashboard.dart';
import 'package:nextspace/pages/Space%20Owner/space_page.dart';
import 'package:nextspace/pages/Space%20Owner/space_profile.dart';

class SpaceOwnerNavigation extends StatefulWidget {
  const SpaceOwnerNavigation({super.key});

  @override
  State<SpaceOwnerNavigation> createState() => _SpaceOwnerNavigationState();
}

class _SpaceOwnerNavigationState extends State<SpaceOwnerNavigation> {
  int myIndex = 2;
  final PageController _pageController = PageController(initialPage: 2);

  final List<Widget> screenList = [
    const SpaceOwnerDashboard(),
    const SpacePage(),
    const Booking(),
    const SpaceFeedback(),
    const SpaceProfile(),
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
            icon: Icon(Icons.feedback_rounded),
            label: "Feed back",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_sharp),
            label: "My Account",
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

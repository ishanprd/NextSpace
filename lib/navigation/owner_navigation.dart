import 'package:flutter/material.dart';
import 'package:nextspace/pages/Space%20Owner/booking.dart';
import 'package:nextspace/pages/Space%20Owner/space_feedback.dart';
import 'package:nextspace/pages/Space%20Owner/space_owner_dashboard.dart';
import 'package:nextspace/pages/Space%20Owner/space_page.dart';
import 'package:nextspace/pages/Space%20Owner/space_profile.dart';

class NavigationFlow extends StatefulWidget {
  const NavigationFlow({super.key});

  @override
  State<NavigationFlow> createState() => _NavigationFlowState();
}

class _NavigationFlowState extends State<NavigationFlow> {
  int myIndex = 2;
  List screenList = [
    const SpaceOwnerDashboard(),
    const SpacePage(),
    const Booking(),
    const SpaceFeedback(),
    const SpaceProfile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        iconSize: 30,
        type: BottomNavigationBarType.shifting,
        currentIndex: myIndex,
        // Background color
        selectedItemColor: Colors.blueAccent, // Selected item color
        unselectedItemColor: Colors.black, // Unselected item color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: "My Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: "My Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "My Account",
          ),
        ],
      ),
      body: screenList[myIndex],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nextspace/pages/Co-worker/booking_history.dart';
import 'package:nextspace/pages/Co-worker/chat.dart';
import 'package:nextspace/pages/Co-worker/coworker_dashboard.dart';
import 'package:nextspace/pages/Co-worker/setting.dart';
import 'package:nextspace/pages/Co-worker/search_space.dart';

class CoworkerNavigation extends StatefulWidget {
  const CoworkerNavigation({super.key});

  @override
  State<CoworkerNavigation> createState() => _CoworkerNavigationState();
}

class _CoworkerNavigationState extends State<CoworkerNavigation> {
  int myIndex = 2;
  List screenList = [
    const CoworkerDashboard(),
    const SearchSpace(),
    const BookingHistory(),
    const Chat(),
    const CoWorkerSetting()
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

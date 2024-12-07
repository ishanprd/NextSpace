import 'package:flutter/material.dart';
import 'package:nextspace/pages/Co-worker/booking_history.dart';
import 'package:nextspace/pages/Co-worker/chat.dart';
import 'package:nextspace/pages/Co-worker/coworker_dashboard.dart';
import 'package:nextspace/pages/Co-worker/setting.dart';
import 'package:nextspace/pages/Co-worker/search_space.dart';

class ChatNavigation extends StatefulWidget {
  const ChatNavigation({super.key});

  @override
  State<ChatNavigation> createState() => _ChatNavigationState();
}

class _ChatNavigationState extends State<ChatNavigation> {
  int myIndex = 3;
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
      backgroundColor: Colors.white,
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
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: "Booking History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: screenList[myIndex],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nextspace/pages/Space%20Owner/booking.dart';
import 'package:nextspace/pages/Space%20Owner/chat/chat.dart';
import 'package:nextspace/pages/Space%20Owner/space/view_space.dart';
import 'package:nextspace/pages/Space%20Owner/space_owner_dashboard.dart';
import 'package:nextspace/pages/Space%20Owner/space_page.dart';
import 'package:nextspace/pages/Space%20Owner/space_setting.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To check the user status
import 'package:cloud_firestore/cloud_firestore.dart'; // To access Firestore and check if the space is created

class SpaceOwnerNavigation extends StatefulWidget {
  const SpaceOwnerNavigation({super.key});

  @override
  State<SpaceOwnerNavigation> createState() => _SpaceOwnerNavigationState();
}

class _SpaceOwnerNavigationState extends State<SpaceOwnerNavigation> {
  int myIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  bool isSpaceCreated = false;

  @override
  void initState() {
    super.initState();
    _checkIfSpaceCreated();
  }

  void _checkIfSpaceCreated() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Query spaces collection for a document where ownerId equals current user's UID
      var querySnapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .where('ownerId', isEqualTo: user.uid) // Search by ownerId field
          .get();

      // Check if any document exists with the given ownerId
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isSpaceCreated = true;
        });
      } else {
        setState(() {
          isSpaceCreated = false;
        });
      }
    }
  }

  final List<Widget> screenList = [
    const SpaceOwnerDashboard(),
    const ViewSpace(), // This will be conditionally rendered
    const Booking(),
    const Chat(),
    const SpaceSetting(),
  ];

  void onTabTapped(int index) {
    if (index == 1 && !isSpaceCreated) {
      // If user tries to open the 'My Space' page but space is not created, show a different page or alert
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Space Not Created"),
            content: const Text(
                "Please create your space first before accessing this page."),
            actions: <Widget>[
              TextButton(
                child: const Text("Create Space"),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to the space creation page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SpacePage()),
                  ).then((_) {
                    // Once coming back, check if the space is created
                    _checkIfSpaceCreated();
                  });
                },
              ),
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
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
            icon: Icon(Icons.manage_accounts),
            label: "Management",
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

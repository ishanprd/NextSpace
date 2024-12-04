import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<Message> messages = [
    Message("Fauziah", "I will do the voice over", "10:30 PM",
        "assets/avatar1.png", true),
    Message(
        "Nicole", "just open la 😁😉", "3:15 PM", "assets/avatar2.png", false),
    Message("Brian", "bye 😊", "Yesterday", "assets/avatar3.png", true),
    Message("Cheng", "call me when you get...", "Yesterday",
        "assets/avatar4.png", false),
    Message("Model", "ready for another adv...", "Yesterday",
        "assets/avatar5.png", true),
    Message(
        "Ash King", "whatsapp my frnd 🐯", "2d", "assets/avatar6.png", false),
    Message("Remote Guy", "here is your bill for the...", "Mar 10",
        "assets/avatar7.png", false),
    Message("Kg1", "LOL!!! 🎉", "Mar 7", "assets/avatar8.png", false),
    Message("Stephen", "that would be great!", "Mar 3", "assets/avatar9.png",
        false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Center(child: Text('Messages')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Add options menu functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(message.avatar),
              radius: 25,
              child: message.isActive
                  ? const Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.green,
                      ),
                    )
                  : null,
            ),
            title: Text(
              message.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              message.message,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              message.time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                  context, '/conversations'); // Handles navigation
            },
          );
        },
      ),
    );
  }
}

class Message {
  final String name;
  final String message;
  final String time;
  final String avatar;
  final bool isActive;

  Message(this.name, this.message, this.time, this.avatar, this.isActive);
}

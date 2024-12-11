import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextspace/Model/chat_room_model.dart';
import 'package:nextspace/Model/message_model.dart';
import 'package:nextspace/Model/user_model.dart';
import 'package:uuid/uuid.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser; // The target user in the chatroom
  final ChatRoomModel chatroom; // The current chatroom
  final UserModel userModel; // The current user's model
  final User firebaseUser; // The Firebase user for authentication

  const ChatRoomPage({
    super.key,
    required this.targetUser,
    required this.chatroom,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController =
      TextEditingController(); // Controller for the message input field

  // Function to send a message
  void sendMessage() async {
    String msg =
        messageController.text.trim(); // Get the message from the input field
    messageController
        .clear(); // Clear the input field after sending the message

    if (msg.isNotEmpty) {
      // Only send message if it's not empty
      MessageModel newMessage = MessageModel(
        messageid: const Uuid().v4(), // Generate a unique message ID
        sender: widget.userModel.uid, // The sender's UID
        createdon: DateTime.now(), // Timestamp of the message
        text: msg, // The actual message text
        seen: false, // Message not seen initially
      );

      // Save the new message to Firestore in the corresponding chatroom
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      // Update the last message of the chatroom
      widget.chatroom.lastMessage = msg;

      // Save the updated chatroom information in Firestore
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!"); // Log message sent
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      // Fetch target user's data from Firestore
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.targetUser.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.done) {
          // Check if the data has been fetched
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            // Retrieve and decode the user's base64 image if available
            final base64Image = userSnapshot.data!.data()?['image'];
            Uint8List? imageBytes;

            if (base64Image != null) {
              try {
                imageBytes =
                    base64Decode(base64Image); // Decode base64 to image bytes
              } catch (e) {
                log('Error decoding base64: $e'); // Log error if decoding fails
                imageBytes = null;
              }
            }

            // Display the chatroom UI
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: imageBytes != null
                          ? MemoryImage(
                              imageBytes) // Use the decoded image if available
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider, // Default avatar if no image is available
                      child: imageBytes == null
                          ? const Icon(Icons.person)
                          : null, // Default icon if no image
                    ),
                    const SizedBox(width: 10),
                    Text(widget.targetUser.fullName
                        .toString()), // Display target user's name
                  ],
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // Chat Messages Section
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: StreamBuilder(
                          // Stream of messages in the chatroom
                          stream: FirebaseFirestore.instance
                              .collection("chatrooms")
                              .doc(widget.chatroom.chatroomid)
                              .collection("messages")
                              .orderBy("createdon",
                                  descending:
                                      true) // Order messages by creation date
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              // Check if data is active
                              if (snapshot.hasData) {
                                QuerySnapshot dataSnapshot =
                                    snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  reverse:
                                      true, // Reverse the list to show the latest message at the bottom
                                  itemCount: dataSnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    // Deserialize the message into MessageModel
                                    MessageModel currentMessage =
                                        MessageModel.fromMap(
                                      dataSnapshot.docs[index].data()
                                          as Map<String, dynamic>,
                                    );

                                    // Align the message based on the sender (current user or target user)
                                    return Row(
                                      mainAxisAlignment: (currentMessage
                                                  .sender ==
                                              widget.userModel.uid)
                                          ? MainAxisAlignment
                                              .end // Align to the right for current user
                                          : MainAxisAlignment
                                              .start, // Align to the left for target user
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: (currentMessage.sender ==
                                                    widget.userModel.uid)
                                                ? Colors
                                                    .blue // Blue for current user's message
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary, // Different color for target user
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            currentMessage.text
                                                .toString(), // Display message text
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                      "An error occurred! Please check your internet connection."), // Show error message
                                );
                              } else {
                                return const Center(
                                  child: Text(
                                      "Say hi to your new friend"), // Default text when no messages are available
                                );
                              }
                            } else {
                              return const Center(
                                  child:
                                      CircularProgressIndicator()); // Show loading spinner while waiting for messages
                            }
                          },
                        ),
                      ),
                    ),
                    // Message Input Section
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller:
                                  messageController, // Bind the message controller
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter message", // Placeholder text
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                sendMessage, // Call sendMessage function when pressed
                            icon: Icon(
                              Icons.send,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary, // Use secondary theme color for send icon
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
                child: Text(
                    "User not found.")); // Show error if user data is not found
          }
        } else {
          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading spinner while waiting for user data
        }
      },
    );
  }
}

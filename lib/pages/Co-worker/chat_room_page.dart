import 'dart:convert'; // For base64 encoding/decoding.
import 'dart:developer'; // For logging messages to the console.
import 'dart:typed_data'; // For handling byte data like images.

import 'package:cloud_firestore/cloud_firestore.dart'; // For interacting with Firestore.
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication.
import 'package:flutter/material.dart'; // For Flutter UI components.
import 'package:nextspace/Model/chat_room_model.dart'; // For the chat room model.
import 'package:nextspace/Model/message_model.dart'; // For the message model.
import 'package:nextspace/Model/user_model.dart'; // For the user model.
import 'package:uuid/uuid.dart'; // For generating unique message IDs.

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser; // Target user of the chat.
  final ChatRoomModel chatroom; // Chat room details.
  final UserModel userModel; // Current logged-in user model.
  final User firebaseUser; // Firebase user instance.

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
      TextEditingController(); // Controller for the message input field.

  void sendMessage() async {
    String msg = messageController.text.trim(); // Get the trimmed message text.
    messageController.clear(); // Clear the input field.

    if (msg.isNotEmpty) {
      // Only send the message if it's not empty.
      MessageModel newMessage = MessageModel(
        messageid: const Uuid().v4(), // Generate a unique ID for the message.
        sender: widget.userModel.uid, // The current user is the sender.
        createdon: DateTime.now(), // Timestamp when the message was created.
        text: msg, // The message content.
        seen: false, // Set the initial "seen" status to false.
      );

      // Save the message in Firestore under the appropriate chatroom.
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      // Update the last message in the chatroom.
      widget.chatroom.lastMessage = msg;

      // Save the updated chatroom in Firestore.
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!"); // Log the message sent action.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the target user's details from Firestore.
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.targetUser.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.done) {
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final base64Image = userSnapshot.data!.data()?[
                'image']; // Get the base64 image string of the target user.
            Uint8List? imageBytes;

            if (base64Image != null) {
              // If the user has an image, decode the base64 string.
              try {
                imageBytes = base64Decode(base64Image);
              } catch (e) {
                log('Error decoding base64: $e'); // Log any errors during decoding.
                imageBytes = null;
              }
            }

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    // Display target user's profile picture in the app bar.
                    CircleAvatar(
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                      child:
                          imageBytes == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 10),
                    // Display target user's full name in the app bar.
                    Text(widget.targetUser.fullName.toString()),
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
                          stream: FirebaseFirestore.instance
                              .collection("chatrooms")
                              .doc(widget.chatroom.chatroomid)
                              .collection("messages")
                              .orderBy("createdon", descending: true)
                              .snapshots(), // Stream the messages from Firestore in descending order.
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (snapshot.hasData) {
                                QuerySnapshot dataSnapshot =
                                    snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  reverse:
                                      true, // Reverse the list to show the most recent messages at the bottom.
                                  itemCount: dataSnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    MessageModel currentMessage =
                                        MessageModel.fromMap(
                                      dataSnapshot.docs[index].data()
                                          as Map<String, dynamic>,
                                    );

                                    return Row(
                                      mainAxisAlignment: (currentMessage
                                                  .sender ==
                                              widget.userModel.uid)
                                          ? MainAxisAlignment
                                              .end // Align the message to the right for the current user.
                                          : MainAxisAlignment
                                              .start, // Align the message to the left for the target user.
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (currentMessage.sender ==
                                                    widget.userModel.uid)
                                                ? Colors
                                                    .blue // Blue for the current user's messages.
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary, // Secondary color for target user's messages.
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            currentMessage.text
                                                .toString(), // Display the message text.
                                            style: const TextStyle(
                                              color: Colors
                                                  .white, // White text color.
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                      "An error occurred! Please check your internet connection."),
                                );
                              } else {
                                return const Center(
                                  child: Text(
                                      "Say hi to your new friend"), // Display this message if no messages are found.
                                );
                              }
                            } else {
                              return const Center(
                                child:
                                    CircularProgressIndicator(), // Show a loading indicator while fetching messages.
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    // Message Input Field Section
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller:
                                  messageController, // Controller for the message input field.
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    "Enter message", // Placeholder text for the message input field.
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                sendMessage, // Trigger sendMessage function when the send button is pressed.
                            icon: Icon(
                              Icons.send,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary, // Send icon color.
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
                    "User not found.")); // Show this message if the target user is not found.
          }
        } else {
          return const Center(
            child:
                CircularProgressIndicator(), // Show a loading indicator while fetching user data.
          );
        }
      },
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextspace/Model/chat_room_model.dart';
import 'package:nextspace/Model/firebase_helper.dart';
import 'package:nextspace/Model/user_model.dart';
import 'package:nextspace/pages/Space Owner/chat/chat_room_page.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final String userId = _auth.currentUser?.uid ?? ''; // Get current user's ID

    // Fetch user data from Firestore based on the current user's UID
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading indicator while waiting
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Error: ${snapshot.error}')); // Show error if fetching data fails
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
              child: Text(
                  'No user data found')); // Show message if no user data is found
        } else {
          // Deserialize user data into UserModel
          UserModel userModel = UserModel.fromJson(snapshot.data!.data()!);

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Chat"), // Set app bar title to "Chat"
              automaticallyImplyLeading:
                  false, // Disable the default back button
              backgroundColor: Colors.blue, // Set app bar background color
            ),
            body: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                // Stream to listen for real-time changes to chatrooms
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${userModel.uid}",
                        isEqualTo:
                            true) // Filter chatrooms where the user is a participant
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot = snapshot.data!;
                      if (chatRoomSnapshot.docs.isEmpty) {
                        // Enhanced "No Chats Available" UI
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "No Chats Available",
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        // Display a list of chatrooms
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          // Deserialize each chatroom document into ChatRoomModel
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          // Extract participants from the chatroom and remove the current user's ID
                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;
                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(userModel.uid);

                          // Fetch information of the other participant in the chatroom
                          return FutureBuilder<UserModel?>(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]), // Get target user by ID
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser = userData.data!;

                                  // Fetch the target user's data from Firestore
                                  return FutureBuilder<
                                      DocumentSnapshot<Map<String, dynamic>>>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(targetUser.uid)
                                        .get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (userSnapshot.hasData &&
                                            userSnapshot.data!.exists) {
                                          // Handle base64 image data for user profile picture
                                          final base64Image = userSnapshot.data!
                                              .data()?['image'];
                                          Uint8List? imageBytes;

                                          if (base64Image != null) {
                                            try {
                                              imageBytes = base64Decode(
                                                  base64Image); // Decode the base64 image data
                                            } catch (e) {
                                              print(
                                                  'Error decoding base64: $e');
                                              imageBytes =
                                                  null; // Handle decoding error
                                            }
                                          }

                                          // Return a ListTile for each chatroom
                                          return ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return ChatRoomPage(
                                                      chatroom: chatRoomModel,
                                                      firebaseUser:
                                                          _auth.currentUser!,
                                                      userModel: userModel,
                                                      targetUser: targetUser,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            leading: CircleAvatar(
                                              backgroundImage: imageBytes !=
                                                      null
                                                  ? MemoryImage(
                                                      imageBytes) // Display the decoded image if available
                                                  : const AssetImage(
                                                          'assets/default_avatar.png')
                                                      as ImageProvider,
                                              child: imageBytes == null
                                                  ? const Icon(Icons
                                                      .person) // Display a default icon if image is not available
                                                  : null,
                                            ),
                                            title: Text(targetUser.fullName),
                                            subtitle: chatRoomModel
                                                    .lastMessage!.isNotEmpty
                                                ? Text(chatRoomModel
                                                    .lastMessage!) // Display the last message in the chat
                                                : Text(
                                                    "Say hi to your new friend!",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ),
                                          );
                                        } else {
                                          return const SizedBox
                                              .shrink(); // Return an empty widget if user data is not found
                                        }
                                      } else {
                                        return const SizedBox
                                            .shrink(); // Return an empty widget while waiting for user data
                                      }
                                    },
                                  );
                                } else {
                                  return const SizedBox
                                      .shrink(); // Return an empty widget if user data is null
                                }
                              } else {
                                return const Center(
                                    child:
                                        CircularProgressIndicator()); // Show loading spinner while waiting for user data
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error: ${snapshot.error}'), // Show error if fetching chatrooms fails
                      );
                    } else {
                      return const Center(
                          child: Text(
                              "No Chats")); // Show message if no chatrooms are found
                    }
                  } else {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show loading spinner while waiting for chatroom data
                  }
                },
              ),
            ),
          );
        }
      },
    );
  }
}

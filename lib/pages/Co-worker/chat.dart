import 'dart:convert'; // For base64 encoding/decoding.
import 'dart:typed_data'; // For handling byte data.

import 'package:cloud_firestore/cloud_firestore.dart'; // For interacting with Firestore.
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication.
import 'package:flutter/material.dart'; // For Flutter UI components.
import 'package:nextspace/Model/chat_room_model.dart'; // For chat room model.
import 'package:nextspace/Model/firebase_helper.dart'; // For helper methods to interact with Firebase.
import 'package:nextspace/Model/user_model.dart'; // For user model.
import 'package:nextspace/pages/Co-worker/chat_room_page.dart'; // For navigating to the chat room page.

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase authentication instance.

  @override
  Widget build(BuildContext context) {
    final String userId =
        _auth.currentUser?.uid ?? ''; // Get the current user ID.

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      // Fetch user data from Firestore.
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading indicator while fetching user data.
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Error: ${snapshot.error}')); // Show error message if fetching data fails.
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
              child: Text(
                  'No user data found')); // Handle the case when no user data is found.
        } else {
          UserModel userModel = UserModel.fromJson(
              snapshot.data!.data()!); // Parse user data into a UserModel.

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Chat"),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blue, // Set the app bar background color.
            ),
            body: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                // Stream chatrooms the user is part of.
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${userModel.uid}",
                        isEqualTo:
                            true) // Filter chatrooms where the user is a participant.
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot = snapshot.data!;

                      if (chatRoomSnapshot.docs.isEmpty) {
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
                      } else {
                        return ListView.builder(
                          // List all chatrooms the user is part of.
                          itemCount: chatRoomSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                                chatRoomSnapshot.docs[index].data() as Map<
                                    String, dynamic>); // Parse each chatroom.

                            Map<String, dynamic> participants = chatRoomModel
                                .participants!; // Get the participants of the chatroom.
                            List<String> participantKeys =
                                participants.keys.toList();
                            participantKeys.remove(userModel
                                .uid); // Remove current user from the list of participants.

                            return FutureBuilder<UserModel?>(
                              // Fetch user details for the other participant.
                              future: FirebaseHelper.getUserModelById(
                                  participantKeys[
                                      0]), // Get the user model by participant ID.
                              builder: (context, userData) {
                                if (userData.connectionState ==
                                    ConnectionState.done) {
                                  if (userData.data != null) {
                                    UserModel targetUser = userData.data!;

                                    return FutureBuilder< // Fetch user data from Firestore for the target user.
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
                                            final base64Image = userSnapshot
                                                    .data!
                                                    .data()?[
                                                'image']; // Get image data (base64).
                                            Uint8List? imageBytes;

                                            if (base64Image != null) {
                                              try {
                                                imageBytes = base64Decode(
                                                    base64Image); // Decode the base64 image data.
                                              } catch (e) {
                                                print(
                                                    'Error decoding base64: $e'); // Handle decoding errors.
                                                imageBytes = null;
                                              }
                                            }

                                            return ListTile(
                                              // Build a list tile for each chatroom.
                                              style: ListTileStyle.list,
                                              focusColor: Colors.grey,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return ChatRoomPage(
                                                        // Navigate to the chat room page.
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
                                                // Display the target user's profile image.
                                                backgroundImage: imageBytes !=
                                                        null
                                                    ? MemoryImage(imageBytes)
                                                    : const AssetImage(
                                                            'assets/applogo.png')
                                                        as ImageProvider,
                                                child: imageBytes == null
                                                    ? const Icon(Icons.person)
                                                    : null,
                                              ),
                                              title: Text(targetUser
                                                  .fullName), // Display the target user's full name.
                                              subtitle: chatRoomModel
                                                      .lastMessage!.isNotEmpty
                                                  ? Text(chatRoomModel
                                                      .lastMessage!) // Display the last message if available.
                                                  : Text(
                                                      "Say hi to your new friend!", // Default message if no last message.
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                    ),
                                            );
                                          } else {
                                            return const SizedBox
                                                .shrink(); // Return an empty widget if the user does not exist.
                                          }
                                        } else {
                                          return const SizedBox
                                              .shrink(); // Return an empty widget if user data is still loading.
                                        }
                                      },
                                    );
                                  } else {
                                    return const SizedBox
                                        .shrink(); // Return an empty widget if user data is null.
                                  }
                                } else {
                                  return const Center(
                                      child:
                                          CircularProgressIndicator()); // Show loading indicator if user data is still loading.
                                }
                              },
                            );
                          },
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error: ${snapshot.error}'), // Show error if there's an issue with fetching chatrooms.
                      );
                    } else {
                      return const Center(
                          child: Text(
                              "No Chats")); // Show message if no chatrooms are available.
                    }
                  } else {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show loading indicator while data is being fetched.
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

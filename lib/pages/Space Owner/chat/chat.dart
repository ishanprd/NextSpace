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
    final String userId = _auth.currentUser?.uid ?? '';

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No user data found'));
        } else {
          UserModel userModel = UserModel.fromJson(snapshot.data!.data()!);

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Chat"),
            ),
            body: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${userModel.uid}", isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot = snapshot.data!;

                      return ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;
                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(userModel.uid);

                          return FutureBuilder<UserModel?>(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser = userData.data!;

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
                                          final base64Image = userSnapshot.data!
                                              .data()?['image'];
                                          Uint8List? imageBytes;

                                          if (base64Image != null) {
                                            try {
                                              imageBytes =
                                                  base64Decode(base64Image);
                                            } catch (e) {
                                              print(
                                                  'Error decoding base64: $e');
                                              imageBytes = null;
                                            }
                                          }

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
                                                  ? MemoryImage(imageBytes)
                                                  : const AssetImage(
                                                          'assets/default_avatar.png')
                                                      as ImageProvider,
                                              child: imageBytes == null
                                                  ? const Icon(Icons.person)
                                                  : null,
                                            ),
                                            title: Text(targetUser.fullName),
                                            subtitle: chatRoomModel
                                                    .lastMessage!.isNotEmpty
                                                ? Text(
                                                    chatRoomModel.lastMessage!)
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
                                          return const SizedBox.shrink();
                                        }
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return const Center(child: Text("No Chats"));
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextspace/Model/chat_room_model.dart';
import 'package:nextspace/Model/firebase_helper.dart';
import 'package:nextspace/Model/user_model.dart';
import 'package:nextspace/pages/Co-worker/chat_room_page.dart';

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
    // The user data is being fetched asynchronously, so we need to handle it with a FutureBuilder.
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
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${userModel.uid}", isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;

                      // Check if there are no chatrooms available
                      if (chatRoomSnapshot.docs.isEmpty) {
                        return const Center(
                          child: Text("No Chats"),
                        );
                      }

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

                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser =
                                      userData.data as UserModel;

                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return ChatRoomPage(
                                            chatroom: chatRoomModel,
                                            firebaseUser: _auth.currentUser!,
                                            userModel: userModel,
                                            targetUser: targetUser,
                                          );
                                        }),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetUser.photo.toString()),
                                    ),
                                    title: Text(targetUser.fullName),
                                    subtitle:
                                        (chatRoomModel.lastMessage!.isNotEmpty)
                                            ? Text(chatRoomModel.lastMessage!)
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
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const Center(
                        child: Text("No Chats"),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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

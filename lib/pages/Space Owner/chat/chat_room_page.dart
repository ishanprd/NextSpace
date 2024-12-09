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
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

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
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg.isNotEmpty) {
      MessageModel newMessage = MessageModel(
        messageid: const Uuid().v4(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.targetUser.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.done) {
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final base64Image = userSnapshot.data!.data()?['image'];
            Uint8List? imageBytes;

            if (base64Image != null) {
              try {
                imageBytes = base64Decode(base64Image);
              } catch (e) {
                log('Error decoding base64: $e');
                imageBytes = null;
              }
            }

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                      child:
                          imageBytes == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 10),
                    Text(widget.targetUser.fullName.toString()),
                  ],
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // Chat Messages
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("chatrooms")
                              .doc(widget.chatroom.chatroomid)
                              .collection("messages")
                              .orderBy("createdon", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (snapshot.hasData) {
                                QuerySnapshot dataSnapshot =
                                    snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  reverse: true,
                                  itemCount: dataSnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    MessageModel currentMessage =
                                        MessageModel.fromMap(
                                      dataSnapshot.docs[index].data()
                                          as Map<String, dynamic>,
                                    );

                                    return Row(
                                      mainAxisAlignment:
                                          (currentMessage.sender ==
                                                  widget.userModel.uid)
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
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
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            currentMessage.text.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
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
                                  child: Text("Say hi to your new friend"),
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
                    ),
                    // Message Input Field
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: messageController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter message",
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: sendMessage,
                            icon: Icon(
                              Icons.send,
                              color: Theme.of(context).colorScheme.secondary,
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
            return const Center(child: Text("User not found."));
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

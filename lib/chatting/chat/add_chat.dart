import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/chatting/chat/chat_list.dart';
import 'package:capston/chatting/chat/message/log.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:capston/chatting/chat/chat_user.dart';

class AddChat extends StatefulWidget {
  final ChatListState chatListParent;
  const AddChat({
    Key? key,
    required this.chatListParent,
  }) : super(key: key);

  @override
  State<AddChat> createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  String roomName = "";

// Add chatting room
  void addroom() async {
    // 입력된 문자가 없을 경우 리턴
    if (roomName.isEmpty) return;

    CollectionReference chatColRef =
        widget.chatListParent.firestore.collection('chat');

    Chat chat = Chat(
        roomName: roomName,
        recentMessage: "",
        userList: [ChatUser(userID: widget.chatListParent.currentUser.uid)]);
    // add user to chatting room field
    chatColRef.add(chat.toJson()).then((DocumentReference doc) {
      widget.chatListParent.currUserDocRef.update({
        'chatList': FieldValue.arrayUnion([doc.id]),
      }).then((value) {
        print("Value Added to Array");
        addEnterEventLog(
            roomID: doc.id, uid: widget.chatListParent.currentUser.uid);
        FirebaseMessaging.instance.subscribeToTopic(doc.id);
      }).catchError((error) {
        print("Failed to add value to array: $error");
      });
    }).catchError((error) {
      print("Failed to add document: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("톡방 생성",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20)),
                  IconButton(
                      color: Colors.white,
                      iconSize: 30,
                      onPressed: () {
                        addroom();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add_circle_rounded))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.white,
                ),
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          roomName = value;
                        });
                      },
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        // border: const OutlineInputBorder(),
                        hintText: "톡방 이름",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Palette.textColor1,
                        ),
                        contentPadding: EdgeInsets.only(bottom: 3),
                      ),
                      style: const TextStyle(fontSize: 14),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            )
          ],
        ));
  }
}

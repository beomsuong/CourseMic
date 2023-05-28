import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends StatefulWidget {
  final String roomID;
  Messages({Key? key, required this.roomID}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late final CollectionReference userRef;
  late final Stream messageStream;
  Map<String, String> userMap = {};

  @override
  void initState() {
    super.initState();
    userRef = FirebaseFirestore.instance.collection('exuser');
    messageStream = FirebaseFirestore.instance
        .collection('exchat')
        .doc(widget.roomID)
        .collection('message')
        .orderBy('time', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            String userID = chatDocs[index]['userID'];
            userMap.containsKey(userID)
                ? null
                : readUserName(userID)
                    .then((userName) => storeUserName(userID, userName));
            return ChatBubbles(
                chatDocs[index]['text'],
                chatDocs[index]['userID'].toString() == user!.uid,
                userMap[userID] ?? 'userName',
                chatDocs[index]['userImage'],
                chatDocs[index]['time'],
                widget.roomID);
          },
        );
      },
    );
  }

  void storeUserName(String userID, String userName) => setState(() {
        userMap[userID] = userName;
      });
  Future<String> readUserName(String userID) async {
    var docSnapshot = await userRef.doc(userID).get();
    if (docSnapshot.exists) {
      return docSnapshot.get('이름');
    }
    return '알수없음';
  }
}

//TODO: chatDocs-roomname필요한지 확인하기
import 'package:capston/chatting/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';

class Messages extends StatefulWidget {
  final String roomID;
  final ChatScreenState chatDataParent;
  const Messages({Key? key, required this.roomID, required this.chatDataParent})
      : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late final CollectionReference userRef;
  late final Stream messageStream;
  Map<String, String> userMap = {};
  Map<String, String> userImage = {};

  @override
  void initState() {
    super.initState();
    userRef = FirebaseFirestore.instance.collection('user');
    messageStream = FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.roomID)
        .collection('log')
        .orderBy('sendTime', descending: true)
        .snapshots();

    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final chatDocs = await FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.roomID)
        .collection('log')
        .get();

    // 유저마다 한 번만 호출되도록 Set을 사용
    final uniqueUserIDs = chatDocs.docs.map((doc) => doc['uid']).toSet();

    for (final userID in uniqueUserIDs) {
      final userName = await readUserName(userID);
      final userImageURL = await getUserImageURL(userID);
      userMap[userID] = userName;
      userImage[userID] = userImageURL;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs as List<DocumentSnapshot>;
        if (chatDocs.isNotEmpty) {
          widget.chatDataParent.widget.lastMessage = chatDocs.first["content"];
        }
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatDoc = chatDocs[index];
            final userID = chatDoc['uid'];
            final userName = userMap[userID] ?? 'Unknown';
            final userImageURL = userImage[userID] ?? 'unknown.jpg';

            return GestureDetector(
              onDoubleTap: () {
                print('message double taps');
              },
              child: ChatBubbles(
                chatDoc['content'],
                chatDoc['uid'].toString() == user!.uid,
                chatDoc['uid'],
                userName,
                userImageURL,
                chatDoc['sendTime'],
                widget.roomID,
                key: ValueKey(chatDoc.id),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> readUserName(String userID) async {
    var docSnapshot = await userRef.doc(userID).get();
    if (docSnapshot.exists) {
      return docSnapshot.get('name');
    }
    return 'Unknown';
  }

  Future<String> getUserImageURL(String userID) async {
    var docSnapshot = await userRef.doc(userID).get();
    if (docSnapshot.exists) {
      return docSnapshot.get('imageURL') as String;
    }
    return 'unknown.jpg';
  }
}

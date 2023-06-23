import 'package:capston/chatting/chat/message/log.dart';
import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/palette.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  final String unknownImageURL =
      "https://firebasestorage.googleapis.com/v0/b/coursermic.appspot.com/o/user.png?alt=media&token=1866f8ce-d6bd-4676-9125-3910b3aa6817";

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
  }

  Stream<QuerySnapshot<Object?>> fetchUserDetails(
      QuerySnapshot<Object?> message) async* {
    // 유저마다 한 번만 호출되도록 Set을 사용
    final uniqueUserIDs = message.docs.map((doc) => doc['uid']).toSet();

    for (final userID in uniqueUserIDs) {
      final user = await readUserNameAndURL(userID);
      userMap[userID] = user[0]; // [0] : userName
      userImage[userID] = user[1]; // [1] : userImageURL
    }

    yield message;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: messageStream.asyncExpand((message) => fetchUserDetails(message)),
      builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatDoc = chatDocs[index];
            final userID = chatDoc['uid'];
            final userName = userMap[userID]!;
            final userImageURL = userImage[userID]!;
            final type = LogType.values[chatDoc['type']];
            final logDocRef = FirebaseFirestore.instance
                .collection('chat')
                .doc(widget.roomID)
                .collection('log')
                .doc(chatDoc.id);

            switch (type) {
              case LogType.text:
              case LogType.media:
                final MSG msg = MSG.fromJson(chatDoc);
                if (!msg.readers
                    .contains(widget.chatDataParent.currentUser.uid)) {
                  //읽은 사람 중에 내가 없으면
                  msg.readers.add(widget.chatDataParent.currentUser.uid);
                  logDocRef.update({
                    'readers': FieldValue.arrayUnion(
                        [widget.chatDataParent.currentUser.uid])
                  });
                }
                return ChatBubbles(
                  msg.content,
                  msg.uid == user!.uid,
                  msg.uid,
                  userName,
                  userImageURL,
                  msg.sendTime,
                  widget.roomID,
                  msg.react,
                  msg.readers,
                  key: ValueKey(chatDoc.id),
                );
              case LogType.enter:
              case LogType.exit:
                final EventLog eventLog = EventLog.fromJson(chatDoc);
                return Center(
                    child: Card(
                        color: Palette.darkGray.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 3, bottom: 3),
                          child: Text(
                            "$userName님이 ${eventLog.type == LogType.enter ? "들어왔습니다." : "나갔습니다."}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        )));
              case LogType.date:
              case LogType.end:
                final EndLog endLog = EndLog.fromJson(chatDoc);

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("프로젝트가 마무리되었습니다! 참여도를 정산해주세요!",
                                style: TextStyle()),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton.icon(
                                onPressed: endLog.calUserIDs.contains(
                                        widget.chatDataParent.currentUser.uid)
                                    ? null
                                    : () {},
                                icon: const Icon(
                                  Icons.hotel_class_rounded,
                                ),
                                label: const Text("참여도 정산하기")),
                          ]),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }

  Future<List<String>> readUserNameAndURL(String userID) async {
    var docSnapshot = await userRef.doc(userID).get();
    if (docSnapshot.exists) {
      return [docSnapshot.get('name'), docSnapshot.get('imageURL')];
    }
    return ['Unknown', unknownImageURL];
  }
}

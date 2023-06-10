import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:capston/palette.dart';
import 'package:flutter/material.dart';

import 'package:capston/chatting/chat/add_chat.dart';
import 'package:capston/chatting/chat/search_chat.dart';
import 'package:capston/chatting/chat_screen.dart';

import 'package:capston/widgets/GradientText.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);
  @override
  State<ChatList> createState() => ChatListState();
}

typedef RoomList = List<List<dynamic>>;

class ChatListState extends State<ChatList> {
  final FirebaseAuth authentication = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final User currentUser;
  late final DocumentReference currUserDocRef;

  Map<String, Widget> roomWidgetList = {};

  bool bFuture = false;

  @override
  initState() {
    super.initState();
    currentUser = authentication.currentUser!;
    currUserDocRef = firestore.collection('user').doc(currentUser.uid);
  }

  Future<RoomList> initChatList() async {
    RoomList roomList = [];
    late List<dynamic> roomIdList;
    await currUserDocRef.get().then((snapshot) {
      roomIdList = snapshot.get('chatList');
    });

    late List<dynamic> userList;
    for (var roomID in roomIdList) {
      DocumentReference roomDocRef = firestore.collection('chat').doc(roomID);
      DocumentSnapshot roomnameSnapshot = await roomDocRef.get();

      String roomName = roomnameSnapshot.get('roomName');
      int userrole = 0;

      userList = roomnameSnapshot.get('userList');
      for (var user in userList) {
        if (user['userID'] == currentUser.uid) {
          userrole = user['role'];
          break;
        }
      }

      final chatDocsSnapshot = await firestore
          .collection('chat')
          .doc(roomID)
          .collection('message')
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      if (chatDocsSnapshot.docs.isNotEmpty) {
        final lastMessage = chatDocsSnapshot.docs[0]['text'];
        roomList.add([
          roomID,
          roomName,
          lastMessage,
          userrole,
          chatDocsSnapshot.docs[0]['time']
        ]);
      } else {
        roomList.add(
          [roomID, roomName, '', userrole, ''],
        );
      }
    }
    roomList.sort((a, b) {
      if (a[4] == '') return -1;
      if (b[4] == '') return 1;
      return (b[4] as Timestamp).compareTo(a[4] as Timestamp);
    });

    return roomList;
  }

  Widget room(String id, String name, String message, int role) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ChatScreen(
                roomID: id,
                chatListParent: this,
              );
            },
          ),
        );
        setState(() {});
      },
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 8), //톡방간 간격
          child: Row(children: [
            if (role == 0)
              Image.asset(
                "assets/image/logo.png",
                fit: BoxFit.contain,
              )
            else if (role >= 16)
              Image.asset(
                "assets/image/commander.png",
                fit: BoxFit.contain,
                color: Palette.pastelPurple,
              )
            else if (role >= 8)
              Image.asset(
                "assets/image/explorer.png",
                fit: BoxFit.contain,
                color: Palette.pastelPurple,
              )
            else if (role >= 4)
              Image.asset(
                "assets/image/artist.png",
                fit: BoxFit.contain,
                color: Palette.pastelPurple,
              )
            else if (role >= 2)
              Image.asset(
                "assets/image/communicator.png",
                fit: BoxFit.contain,
                color: Palette.pastelPurple,
              )
            else if (role >= 1)
              Image.asset(
                "assets/image/explorer.png",
                fit: BoxFit.contain,
                color: Palette.pastelPurple,
              )
            else if (role == 0)
              Image.asset(
                //톡방별 대표 이미지 개개인 프사나 해당 톡방에서의 역할 표시하면 좋을듯
                "assets/image/logo.png",
                fit: BoxFit.contain,
                color: Palette.pastelPurple,
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //글자 왼쪽 정렬
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        // 톡방 제목은 굵게
                      ),
                      Text(
                        message,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    ); // SizedBox를 제거하고 Text 위젯만 반환
  }

  void addRoom(String id, String name, [String lastMessage = ""]) {
    setState(() {
      roomWidgetList[id] = room(id, name, lastMessage, 0);
    });
  }

  void leaveRoom(String id) {
    setState(() {
      roomWidgetList.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const GradientText(text: "채팅방"),
          centerTitle: false,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchChat(
                            chatListParent: this,
                          )),
                );
                setState(() {});
              },
              icon: const Icon(
                Icons.search_rounded,
                color: Palette.pastelPurple,
                size: 30,
              ), // 원하는 아이콘을 선택합니다.
            ),
          ],
        ),
        body: FutureBuilder(
          future: initChatList(),
          builder: (BuildContext context, AsyncSnapshot<RoomList> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator()); // 로딩 중일 때 표시될 위젯
            }
            if ((snapshot.data!).isEmpty) {
              return const Center(
                  child: Text("현재 참여중인 채팅방이 없습니다.",
                      style: TextStyle(fontWeight: FontWeight.w500)));
            }

            if (!bFuture) {
              bFuture = true;
              for (var data in snapshot.data!) {
                roomWidgetList[data[0]] =
                    room(data[0], data[1], data[2], data[3]);
              }
            }

            return ListView(
              children: [
                for (var roomID in roomWidgetList.keys) roomWidgetList[roomID]!,
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
            tooltip: '톡방 추가',
            child: const Icon(Icons.playlist_add_rounded),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddChat(
                    chatListParent: this,
                  );
                },
              );
            }));
  }
}

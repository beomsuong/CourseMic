import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/mypage/my_user.dart';
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
  late final CollectionReference chatColRef;

  Map<Timestamp, Widget> chatWidgetMap = {};

  @override
  initState() {
    super.initState();
    currentUser = authentication.currentUser!;
    currUserDocRef = firestore.collection('user').doc(currentUser.uid);
    chatColRef = firestore.collection('chat');
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
              },
              icon: const Icon(
                Icons.search_rounded,
                color: Palette.pastelPurple,
                size: 30,
              ), // 원하는 아이콘을 선택합니다.
            ),
          ],
        ),
        body: StreamBuilder(
          stream: currUserDocRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator()); // 로딩 중일 때 표시될 위젯
            }
            if (snapshot.data!.get('chatList').isEmpty) {
              return const Center(
                  child: Text("현재 참여중인 채팅방이 없습니다.",
                      style: TextStyle(fontWeight: FontWeight.w500)));
            }
            MyUser currentMyUser = MyUser.fromJson(snapshot.data!);

            return ListView(
              children: [
                for (var roomID in currentMyUser.chatList)
                  StreamBuilder(
                      stream: chatColRef.doc(roomID).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child:
                                  CircularProgressIndicator()); // 로딩 중일 때 표시될 위젯
                        }
                        Chat chat = Chat.fromJson(snapshot.data!);
                        return Room(
                          chatListParent: this,
                          id: roomID,
                          name: chat.roomName,
                          recentMessage: chat.recentMessage,
                          userRole: chat.getUser(userID: currentUser.uid)!.role,
                        );
                      }),
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

class Room extends StatelessWidget {
  ChatListState chatListParent;

  late final String id;
  late final String name;
  String recentMessage;
  int userRole;

  Room({
    super.key,
    required this.chatListParent,
    required this.id,
    required this.name,
    required this.recentMessage,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ChatScreen(
                roomID: id,
                roomName: name,
                chatListParent: chatListParent,
              );
            },
          ),
        );
      },
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8), //톡방간 간격
          child: Row(children: [
            if (userRole == 0)
              SizedBox(
                width: 70,
                height: 60,
                child: Image.asset(
                  "assets/image/logo.png",
                  scale: 2.5,
                ),
              )
            else if (userRole >= 16)
              SizedBox(
                width: 70,
                height: 60,
                child: Image.asset(
                  "assets/image/commander.png",
                  scale: 9,
                  color: Palette.pastelPurple,
                ),
              )
            else if (userRole >= 8)
              SizedBox(
                width: 70,
                height: 60,
                child: Image.asset(
                  "assets/image/explorer.png",
                  scale: 8.5,
                  color: Palette.pastelPurple,
                ),
              )
            else if (userRole >= 4)
              SizedBox(
                width: 70,
                height: 60,
                child: Image.asset(
                  "assets/image/artist.png",
                  scale: 8.5,
                  color: Palette.pastelPurple,
                ),
              )
            else if (userRole >= 2)
              SizedBox(
                width: 70,
                height: 60,
                child: Image.asset(
                  "assets/image/engineer.png",
                  scale: 9.5,
                  color: Palette.pastelPurple,
                ),
              )
            else if (userRole >= 1)
              SizedBox(
                width: 70,
                height: 60,
                child: Image.asset(
                  "assets/image/communicator.png",
                  scale: 9.5,
                  color: Palette.pastelPurple,
                ),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
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
                        recentMessage,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    ); // SizedBox를 제거하고 Text 위젯만 반환
  }
}

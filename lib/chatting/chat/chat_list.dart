import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/mypage/my_user.dart';
import 'package:capston/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:capston/palette.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:capston/chatting/chat/add_chat.dart';
import 'package:capston/chatting/chat/search_chat.dart';
import 'package:capston/chatting/chat_screen.dart';

import 'package:capston/widgets/GradientText.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);
  @override
  State<ChatList> createState() => ChatListState();
}

typedef RoomList = List<List<dynamic>>;

class ChatListState extends State<ChatList> with WidgetsBindingObserver {
  final FirebaseAuth authentication = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const secureStorage = FlutterSecureStorage();

  late final User currentUser; //현재 유저
  late final DocumentReference currUserDocRef;
  late final CollectionReference chatColRef;
  String? lastMessage; //가장 마지막 입력된 메시지
  Map<Timestamp, Widget> chatWidgetMap = {};

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    currentUser = authentication.currentUser!;
    currUserDocRef = firestore.collection('user').doc(currentUser.uid);
    chatColRef = firestore.collection('chat');
    FCMLocalNotification.initializeNotification(context);
    secureStorage.read(key: "lastNotification").then((lastNoification) async {
      if (lastNoification == null) return;
      if (lastNoification.isEmpty) return;
      // secureStorage.write(key: "lastNotification", value: "");
      var roomID = lastNoification.split(" ")[1];
      lastMessage = lastNoification.split(" ")[3];

      secureStorage.write(key: "lastNotification", value: "");
      var roomName = (await chatColRef.doc(roomID).get()).get('roomName');

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              roomID: roomID,
              roomName: roomName,
            );
          },
        ),
      );
    });
    // backgroundNotificationToChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      backgroundNotificationToChat();
    }
  }

  void backgroundNotificationToChat() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    if (message != null && lastMessage != message.notification!.body) {
      // 액션 부분 -> 파라미터는 message.data['test_parameter1'] 이런 방식으로...
      lastMessage = message.notification!.body;
      var roomName = (await FirebaseFirestore.instance
              .collection('chat')
              .doc(message.data['roomID'])
              .get())
          .get('roomName');

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              roomID: message.data['roomID'],
              roomName: roomName,
            );
          },
        ),
      );
    }
    setState(() {});
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
              ),
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

import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/chatting/modifyrole.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:capston/todo_list/todo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/new_message.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'chat/viewuserprofile.dart';

class ChatScreen extends StatefulWidget {
  final String roomID;
  const ChatScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final DocumentReference chatDocRef;
  late Chat chat;
  Map<String, String> userNameList = {};

  late final DocumentReference userDocRef;
  late final User currentUser;
  List<String> userChatList = List<String>.empty(growable: true);

  late final CollectionReference toDoColRef;
  late Future<double> progressPercentFuture;
  late Future<void> chatFuture;

  @override
  void initState() {
    super.initState();
    currentUser = _authentication.currentUser!;
    userDocRef = firestore.collection("user").doc(currentUser.uid);
    chatDocRef = firestore.collection('chat').doc(widget.roomID);
    toDoColRef =
        firestore.collection("chat").doc(widget.roomID).collection("todo");
    progressPercentFuture = calculateProgressPercent();
    chatFuture = readInitChatData();
  }

  Future<void> readInitChatData() async {
    // get user chatList data
    userDocRef.get().then((value) {
      userChatList =
          ((value.data() as Map<String, dynamic>)['chatList']) as List<String>;
    });

    // get chat data
    await readRoomName();
    for (var user in chat.userList) {
      firestore.collection('user').doc(user.userID).get().then((value) {
        userNameList[user.userID] = value.data()!['name'];
      });
    }
  }

  // also read chat data
  Future<String> readRoomName() async {
    await chatDocRef.get().then((value) {
      chat = Chat.fromJson(value);
    });
    return chat.roomName;
  }

  void updateChat() {
    setState(() {
      chatFuture = readInitChatData();
    });
  }

  String progressCount = "";
  Future<double> calculateProgressPercent() async {
    double progressPercent = 0.0;
    await toDoColRef
        .where('state', isEqualTo: ToDoState.Done.index)
        .get()
        .then((snapshot) {
      progressPercent =
          snapshot.docs.isEmpty ? 0.0 : snapshot.docs.length.toDouble();
      progressCount = progressPercent.toInt().toString();
    });
    if (progressPercent == 0.0) return progressPercent;
    await toDoColRef.get().then(
      (snapshot) {
        progressPercent /= snapshot.docs.length;
        progressCount += "/${snapshot.docs.length}";
      },
    );
    return progressPercent;
  }

  void updateProgressPercent() {
    setState(() {
      progressPercentFuture = calculateProgressPercent();
    });
  }

  Widget roleSelect(String userID, String userName, int userRole) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Viewuserprofile(userid: userID);
            },
          ),
        );
      },
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 8), //톡방간 간격
          child: Row(children: [
            if (userRole == 0)
              Image.asset(
                "assets/image/logo.png",
                width: 30,
                height: 30,
                color: Colors.purple,
              )
            else if (userRole >= 16)
              Image.asset("assets/image/commander.png",
                  width: 30, height: 30, color: Colors.purple)
            else if (userRole >= 8)
              Image.asset("assets/image/explorer.png",
                  width: 30, height: 30, color: Colors.purple)
            else if (userRole >= 4)
              Image.asset(
                "assets/image/artist.png",
                width: 30,
                height: 30,
              )
            else if (userRole >= 2)
              Image.asset("assets/image/communicator.png",
                  width: 30, height: 30, color: Colors.purple)
            else if (userRole >= 1)
              Image.asset(
                "assets/image/explorer.png",
                width: 30,
                height: 30,
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //글자 왼쪽 정렬
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                        // 톡방 제목은 굵게
                      ),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // chatting room background
      backgroundColor: Palette.lightGray,
      appBar: AppBar(
        // appBar background
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: Center(
          child: FutureBuilder(
              future: readRoomName(),
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? snapshot.data! : "RoomName",
                    style: const TextStyle(color: Colors.black));
              }),
        ),
      ),
      endDrawer: Drawer(
        child: FutureBuilder(
            future: chatFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const CircularProgressIndicator(
                  color: Palette.pastelPurple,
                );
              }
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(
                          child: Text(
                            chat.roomName,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(children: [
                          const SizedBox(
                            child: Text(
                              '코드: ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Text(
                              widget.roomID.substring(0, 4),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ]),
                        const Divider(
                          thickness: 0.5,
                          height: 1,
                          color: Palette.darkGray,
                        ),
                        const SizedBox(
                          child: Text(
                            '참여자',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        for (var user in chat.userList)
                          roleSelect(
                            user.userID,
                            userNameList[user.userID] ?? "userName",
                            user.role,
                          ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('역할 수정하기'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ModifyRole(
                            role: chat
                                .userList[chat.getIndexOfUser(
                                    userID: currentUser.uid)]
                                .role,
                            roomid: widget.roomID,
                            useruid: currentUser.uid,
                            returnuserrole: (int userrole) {
                              chat
                                  .userList[chat.getIndexOfUser(
                                      userID: currentUser.uid)]
                                  .role = userrole;
                              chatDocRef.update({
                                'userList': chat.userList,
                              });
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app_rounded,
                        color: Colors.red),
                    title: const Text('나가기'),
                    onTap: () {
                      chat.userList.removeAt(chat.getIndexOfUser(
                        userID: currentUser.uid,
                      ));
                      // userList.removeWhere(
                      //     (user1) => user1['userID'] == user.uid);
                      userChatList.remove(widget.roomID);
                      chatDocRef.update(chat.userListToJson());
                      userDocRef.update({
                        'chatList': userChatList,
                      });
                      // pop Drawer
                      Navigator.of(context).pop();
                      // pop ChatScreen
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: progressPercentFuture,
              builder: (context, snapshot) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToDoPage(
                        roomID: widget.roomID,
                        chatScreenState: this,
                      ),
                    ),
                  ),
                  child: LinearPercentIndicator(
                    padding: const EdgeInsets.all(0),
                    animation: true,
                    animationDuration: 500,
                    lineHeight: 15.0,
                    percent: snapshot.hasData ? snapshot.data! : 0.0,
                    center: Text(progressCount.isEmpty ? "" : progressCount,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12)),
                    // only one color can accept
                    linearGradient: const LinearGradient(colors: [
                      Palette.brightViolet,
                      Palette.pastelPurple,
                      Palette.brightBlue
                    ]),
                  ),
                );
              }),
          Expanded(child: Messages(roomID: widget.roomID)),
          NewMessage(
            roomID: widget.roomID,
            chatScreenState: this,
          ),
        ],
      ),
    );
  }
}

import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:capston/todo_list/todo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/new_message.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String roomID;
  const ChatScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final DocumentReference chatRef;
  late Chat chat;
  Map<String, String> userNameList = {};

  late final CollectionReference toDoRef;
  late Future<double> progressPercentFuture;

  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    toDoRef =
        firestore.collection("exchat").doc(widget.roomID).collection("todo");
    progressPercentFuture = calculateProgressPercent();
    readInitChatData();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.uid);
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> readInitChatData() async {
    chatRef = firestore.collection('exchat').doc(widget.roomID);
    await readRoomName();
    for (var user in chat.userList) {
      firestore.collection('exuser').doc(user.userID).get().then((value) {
        userNameList[user.userID] = value.data()!['이름'];
      });
    }
  }

  // also read chat data
  Future<String> readRoomName() async {
    await chatRef.get().then((value) {
      chat = Chat.fromJson(value);
    });
    return chat.roomName;
  }

  String progressCount = "";
  Future<double> calculateProgressPercent() async {
    double progressPercent = 0.0;
    await toDoRef
        .where('state', isEqualTo: ToDoState.Done.index)
        .get()
        .then((snapshot) {
      progressPercent =
          snapshot.docs.isEmpty ? 0.0 : snapshot.docs.length.toDouble();
      progressCount = progressPercent.toInt().toString();
    });
    if (progressPercent == 0.0) return progressPercent;
    await toDoRef.get().then(
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
        title: FutureBuilder(
            future: readRoomName(),
            builder: (context, snapshot) {
              return Center(
                  child: Text(snapshot.hasData ? snapshot.data! : "RoomName",
                      style: const TextStyle(color: Colors.black)));
            }),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app_sharp,
              color: Colors.black54,
            ),
            onPressed: () {
              //_authentication.signOut();
              Navigator.pop(context);
            },
          )
        ],
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
          Expanded(
            child: Messages(roomID: widget.roomID),
          ),
          NewMessage(
            roomID: widget.roomID,
            chatScreenState: this,
          ),
        ],
      ),
    );
  }
}

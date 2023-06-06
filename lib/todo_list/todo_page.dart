import 'package:capston/chatting/chat/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:capston/todo_list/todo_list.dart';

import 'package:capston/palette.dart';

class ToDoPage extends StatefulWidget {
  final roomID;
  const ToDoPage({super.key, required this.roomID});

  @override
  State<ToDoPage> createState() => ToDoPageState();
}

// 추후 수정
class ToDoPageState extends State<ToDoPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Chat chat;
  Map<String, String> userNameList = {};
  // 추후에 옮길 예정 (chat_screen || new_message)
  @override
  void initState() {
    super.initState();
    loadingData();
  }

  Future<void> loadingData() async {
    await firestore.collection('exchat').doc(widget.roomID).get().then((value) {
      chat = Chat.fromJson(value);
    });
    for (var user in chat.userList) {
      firestore.collection('exuser').doc(user.userID).get().then((value) {
        userNameList[user.userID] = value.data()!['이름'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.lightGray,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            toolbarHeight: 100,
            centerTitle: true,
            title: const Text(
              '팀프로젝트',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            backgroundColor: Colors.white,
          ),
        ),
        body: ToDoList(
          roomID: widget.roomID,
          dataState: this,
        ));
  }
}

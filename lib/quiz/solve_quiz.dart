import 'package:capston/chatting/chat/add_chat.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class solve_quiz extends StatefulWidget {
  const solve_quiz({super.key});

  @override
  State<solve_quiz> createState() => _solve_quizState();
}

class _solve_quizState extends State<solve_quiz> {
  List<DocumentSnapshot> msgList = [];
  List<DocumentSnapshot> quizMsgList = [];

  @override
  void initState() {
    super.initState();
    fetchMessagesFromFirestore();//아직 모름
  }

  Future<void> fetchMessageFromFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
    .collection('exchat')
    .doc(roomname)
    .collection('message')
    .orderBy('timeStamp', descending: true)//최신 -> 오래됨
    .get();

    setState(() {
      quizMsgList = snapshot.docs;
      shuffleMessages();
    });
  }

  void shuffleMessages() {
    setState(() {
      quizMsgList.shuffle(); // 메시지 순서 섞기
    });
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("순서 맞추기 Quiz"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          const Padding(
            //일단 만들어뒀음
            padding: EdgeInsets.symmetric(),
            child: Text('다음 대화들을 일이 일어난 순서대로 배치해주세요.'),
          ),
          ,
          ElevatedButton.icon(
            onPressed: () {
              //이곳에 퀴즈 정답 제출
            },
            icon: const Icon(Icons.check),
            label: const Text('제출'),
          )
        ],
      ),
    );
  }
}

import 'package:capston/chatting/chat/add_chat.dart';
import 'package:capston/chatting/chat/message/imp_msg.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/view_important_message.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

//----------------------------------------------------------
//----------------------------------------------------------
//----------------------------------------------------------

class solve_quiz extends StatelessWidget {
  final String roomname;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GlobalKey<_BuildOrderQuizState> buildOrderQuizKey =
  //     GlobalKey<_BuildOrderQuizState>();
  // final GlobalKey<_BuildWriterQuizState> buildWriterQuizKey =
  //     GlobalKey<_BuildWriterQuizState>();

  solve_quiz({super.key, required this.roomname});

  Future<List<imp_msg>> getimpMsgList() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('chat')
        .doc(roomname)
        .collection('imp_msg')
        .orderBy('timeStamp', descending: true)
        .limit(5)
        .get();

    List<imp_msg> impMsgList = [];
    for (var document in querySnapshot.docs) {
      impMsgList.add(imp_msg.fromJson(document));
    }

    return impMsgList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("퀴즈를 푸세요"),
      ),
      body: FutureBuilder<List<imp_msg>>(
        future: getimpMsgList(),
        builder: (BuildContext context, AsyncSnapshot<List<imp_msg>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            List<imp_msg> impMsgList = snapshot.data!;
            if (impMsgList.length >= 5) {
              return BuildOrderQuiz(
                roomname: roomname,
                impMsgList: impMsgList,
              );
            } else {
              return BuildWriterQuiz(
                roomname: roomname,
                impMsgList: impMsgList,
              );
            }
          } else {
            return const Text("No data available");
          }
        },
      ),
    );
  }
}

//!---------------------------------------------------------------------------------------------------------------------------------
class BuildOrderQuiz extends StatefulWidget {
  final String roomname;
  final List<imp_msg> impMsgList;

  const BuildOrderQuiz({
    super.key,
    required this.roomname,
    required this.impMsgList,
  });

  @override
  _BuildOrderQuizState createState() => _BuildOrderQuizState();
}

class _BuildOrderQuizState extends State<BuildOrderQuiz> {
  late List<imp_msg> reorderedList;

  @override
  void initState() {
    super.initState();
    reorderedList = List.from(widget.impMsgList);
    reorderedList.shuffle();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final imp_msg item = reorderedList.removeAt(oldIndex);
      reorderedList.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("중요 메시지를 순서대로 나열하세요"),
          const SizedBox(height: 16),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reorderedList.length,
            itemBuilder: (context, index) {
              final item = reorderedList[index];
              return ReorderableDragStartListener(
                index: index,
                key: Key('$index'),
                child: ListTile(
                  tileColor: Colors.amber,
                  title: Text(item.msgDetail),
                ),
              );
            },
            onReorder: _onReorder,
          ),
        ],
      ),
    );
  }
}

//!---------------------------------------------------------------------------------------------------------------------------------
class BuildWriterQuiz extends StatefulWidget {
  final String roomname;
  final List<imp_msg> impMsgList;

  const BuildWriterQuiz(
      {super.key, required this.roomname, required this.impMsgList});

  @override
  State<BuildWriterQuiz> createState() => _BuildWriterQuizState();
}

class _BuildWriterQuizState extends State<BuildWriterQuiz> {
  late List<imp_msg> implist; //!가제
  String? selectedUserID;
  String? randomMsgTxt;

  @override
  void initState() {
    super.initState();
    implist = List.from(widget.impMsgList);
    final randomIndex = Random().nextInt(implist.length);
    randomMsgTxt = implist[randomIndex].msgDetail;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("작성자를 맞춰보세요"),
            Card(
              child: SizedBox(
                width: 300,
                height: 100,
                child: Center(
                  child: Text(
                    randomMsgTxt!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            const Divider(thickness: 5),
            ...widget.impMsgList.map(
              (msg) => RadioListTile(
                title: Text(msg.userId),
                value: msg.userId,
                groupValue: selectedUserID,
                onChanged: (value) {
                  setState(() {
                    selectedUserID = value as String;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class imp_msg {
  final String msgDetail;
  final Timestamp timeStamp;
  final String userId;

  imp_msg({
    required this.msgDetail,
    required this.timeStamp,
    required this.userId,
  });

  factory imp_msg.fromJson(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return imp_msg(
      msgDetail: data['msg_detail'],
      timeStamp: data['timeStamp'] as Timestamp,
      userId: data['user_id'],
    );
  }
}

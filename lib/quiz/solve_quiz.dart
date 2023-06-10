// ignore_for_file: non_constant_identifier_names

import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/palette.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class solve_quiz extends StatefulWidget {
  final ChatScreenState chatScreenState;
  final String roomID;

  const solve_quiz(
      {Key? key, required this.roomID, required this.chatScreenState})
      : super(key: key);

  @override
  _solve_quizState createState() => _solve_quizState();
}

class _solve_quizState extends State<solve_quiz> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int score = 10;

  Future<void> setQuiz(Timestamp quiz_C_date, List<String> quiz_passer) async {
    try {
      await _firestore
          .collection('chat')
          .doc(widget.roomID)
          .collection('quiz')
          .doc()
          .set({
        'quiz_C_date': quiz_C_date,
        'quiz_passer': quiz_passer,
      });
    } catch (error) {
      print('퀴즈 세팅 실패: $error');
    }
  }

  Future<void> updateOrCreateQuiz() async {
    try {
      print('그 메서드 불러와짐');
      final CollectionReference chatRef = _firestore.collection('chat');
      final DocumentReference roomRef =
          chatRef.doc(widget.roomID); // 방 도큐먼트 레퍼런스
      final CollectionReference quizRef =
          roomRef.collection('quiz'); // 해당 방의 퀴즈 컬렉션 레퍼런스

      final QuerySnapshot querySnapshot =
          await quizRef.orderBy('quiz_C_date', descending: true).limit(1).get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isNotEmpty) {
        final DocumentSnapshot latestQuiz = documents.first;
        final Map<String, dynamic>? data =
            latestQuiz.data() as Map<String, dynamic>?;
        final Timestamp latestTimestamp = data?['quiz_C_date'];

        final Timestamp currentTimestamp = Timestamp.now();
        final Duration difference =
            currentTimestamp.toDate().difference(latestTimestamp.toDate());
        const score = 5;

        if (difference.inHours < 24) {
          //! 24시간 이내
          List<String> quizPasser =
              List<String>.from(data?['quiz_passer'] ?? []);

          if (!quizPasser.contains(widget.chatScreenState.currentUser.uid)) {
            //! 유저가 푼 사람 목록에 없으면
            quizPasser.add(widget.chatScreenState.currentUser.uid);
          }

          await latestQuiz.reference.set(
            {
              'quiz_passer': quizPasser,
            },
            SetOptions(merge: true),
          );
        } else {
          final Timestamp newTimestamp = Timestamp.now();
          final List<String> quizPasser = [];

          await setQuiz(newTimestamp, quizPasser);
        }
      } else {
        final Timestamp newTimestamp = Timestamp.now();
        final List<String> quizPasser = [];

        await setQuiz(newTimestamp, quizPasser);
      }
    } catch (error) {
      print('퀴즈 업데이트 또는 생성 실패: $error');
    }
  }

  Future<List<imp_msg>> getimpMsgList() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('chat')
        .doc(widget.roomID)
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
        title: const Text("QUIZ"),
        centerTitle: true,
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
                roomID: widget.roomID,
                impMsgList: impMsgList,
                updateOrCreateQuiz: updateOrCreateQuiz,
              );
            } else {
              return BuildWriterQuiz(
                roomID: widget.roomID,
                impMsgList: impMsgList,
                updateOrCreateQuiz: updateOrCreateQuiz,
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

class BuildOrderQuiz extends StatefulWidget {
  final String roomID;
  final List<imp_msg> impMsgList;
  final Function updateOrCreateQuiz;

  const BuildOrderQuiz({
    Key? key,
    required this.roomID,
    required this.impMsgList,
    required this.updateOrCreateQuiz,
  }) : super(key: key);

  @override
  _BuildOrderQuizState createState() => _BuildOrderQuizState();
}

class _BuildOrderQuizState extends State<BuildOrderQuiz> {
  late List<imp_msg> reorderedList;
  late List<imp_msg> answerList;

  @override
  void initState() {
    super.initState();
    reorderedList = List.from(widget.impMsgList);
    answerList = List.from(widget.impMsgList);
    reorderedList.shuffle();
  }

  bool submitAnswer() {
    answerList = answerList.reversed.toList();
    for (int i = 0; i < answerList.length; i++) {
      if (reorderedList[i] != answerList[i]) {
        return false;
      }
    }
    return true;
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
          const Text("Q. 다음 중요메세지들을 오랜된 메세지(맨 위)부터 차례대로 나열하세요. (5점)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
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
                  tileColor: Palette.pastelYellow,
                  leading: Text(
                    '${item.userId} :',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Palette.pastelBlack),
                  ),
                  title: Wrap(
                    children: [
                      Text(
                        item.msgDetail,
                        style: const TextStyle(color: Palette.pastelBlack),
                        maxLines: 5,
                      )
                    ],
                  ),
                  trailing: const Icon(Icons.menu_rounded,
                      color: Palette.pastelBlack),
                  titleAlignment: ListTileTitleAlignment.threeLine,
                ),
              );
            },
            onReorder: _onReorder,
          ),
          Expanded(child: Container()),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: () {
                // print(
                //     '제출: ${reorderedList[0].msgDetail} | ${reorderedList[1].msgDetail} | ${reorderedList[2].msgDetail} | ${reorderedList[3].msgDetail} | ${reorderedList[4].msgDetail}');
                // print(
                //     '정답: ${answerList[0].msgDetail} | ${answerList[1].msgDetail} | ${answerList[2].msgDetail} | ${answerList[3].msgDetail} | ${answerList[4].msgDetail}');
                if (submitAnswer()) {
                  //! 정답
                  widget.updateOrCreateQuiz();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            '정답!',
                            textAlign: TextAlign.center,
                          ),
                          content: const Wrap(
                            children: [
                              Text(
                                '10점',
                                style: TextStyle(
                                    color: Palette.brightBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(' 획득!'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                //Navigator.pop(context);
                              },
                              child: const Text('확인'),
                            ),
                          ],
                        );
                      });
                } else {
                  //! 오답
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            "오답!",
                            textAlign: TextAlign.center,
                          ),
                          content: const Text(''), //! 여기 수정
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigator.pop(context);
                              },
                              child: const Text('확인'),
                            )
                          ],
                        );
                      });
                }
              },
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text(
                "제출!",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Palette.pastelPurple,
            ),
          )
        ],
      ),
    );
  }
}

class BuildWriterQuiz extends StatefulWidget {
  final String roomID;
  final List<imp_msg> impMsgList;
  final Function() updateOrCreateQuiz; // updateOrCreateQuiz 콜백 함수

  const BuildWriterQuiz({
    Key? key,
    required this.roomID,
    required this.impMsgList,
    required this.updateOrCreateQuiz,
  }) : super(key: key);

  @override
  _BuildWriterQuizState createState() => _BuildWriterQuizState();
}

const _snackBar = SnackBar(
  content: Center(
    child: Text(
      "답변이 선택되지 않았어요!",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  behavior: SnackBarBehavior.floating,
  margin: EdgeInsets.all(100.0),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10))),
  padding: EdgeInsets.all(15.0),
  backgroundColor: Palette.pastelPurple,
);

class _BuildWriterQuizState extends State<BuildWriterQuiz> {
  late List<imp_msg> implist;
  String? selectedUserID;
  String? randomMsgTxt;
  String? randomMsgAnswer;

  @override
  void initState() {
    super.initState();
    implist = List.from(widget.impMsgList);
    final randomIndex = Random().nextInt(implist.length);
    randomMsgTxt = implist[randomIndex].msgDetail;
    randomMsgAnswer = implist[randomIndex].userId;
  }

  void submitAnswer() {
    if (selectedUserID == randomMsgAnswer) {
      //! 정답이면
      widget.updateOrCreateQuiz(); // updateOrCreateQuiz 콜백 호출
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('정답!'),
              content: const Wrap(
                children: [
                  Text(
                    '10 포인트',
                    style: TextStyle(
                      color: Palette.brightBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(' 획득!'),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      // Navigator.pop(context);
                    },
                    child: const Text('확인'))
              ],
            );
          });
    } else if (selectedUserID != randomMsgAnswer) {
      if (selectedUserID == null) {
        ScaffoldMessenger.of(context).showSnackBar(_snackBar);
      }
    } else {
      Future.delayed(Duration.zero, () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const SnackBar(
                content: Text("답변이 선택되지 않았어요!"),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(30.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: EdgeInsets.all(15.0),
                backgroundColor: Palette.pastelPurple,
              );
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "Q. 다음 대화를 한 사람은 누구인가?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 13,
            ),
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
            const Padding(
              padding: EdgeInsets.all(16.0),
            ),
            ...widget.impMsgList.map(
              (msg) => RadioListTile(
                title: Text(msg.userId),
                value: msg.userId,
                groupValue: selectedUserID,
                onChanged: (value) {
                  setState(() {
                    selectedUserID = value as String;
                    print('$selectedUserID is selected!');
                  });
                },
              ),
            ),
            Expanded(child: Container()),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: submitAnswer,
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text(
                  "제출!",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: Palette.pastelPurple,
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

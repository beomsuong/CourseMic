//import 'package:capston/message/addmessage.dart';
import 'package:capston/quiz/solve_quiz.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final currentYear = DateTime.now().year; //실제 시간의 년도

typedef ImpMsgSnapshot = QuerySnapshot<Map<String, dynamic>>;

class ImportantMessagesPage extends StatelessWidget {
  final String roomname;
  late Stream<QuerySnapshot<Object?>> imgMsgStream;

  ImportantMessagesPage({Key? key, required this.roomname}) : super(key: key);

  Stream<QuerySnapshot<Map<String, dynamic>>> loadImpMsgList() async* {
    var snapshot = await FirebaseFirestore.instance
        .collection('exchat')
        .doc(roomname)
        .collection('imp_msg')
        .orderBy('timeStamp', descending: true) // 시간 역순으로 정렬
        .get();
    yield snapshot;
  }

  @override
  Widget build(BuildContext context) {
    imgMsgStream = loadImpMsgList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('중요한 메시지 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: imgMsgStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          // 해당 채팅방의 중요한 메시지만 필터링하여 보여줌

          return ListView.builder(
            reverse: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;

              final messageDetail = data['msg_detail'] ?? '';
              final sendTime = data['timeStamp'] as Timestamp;
              final userId = data['user_id'] ?? '';
              final impMsgId = documents[index].id;

              final dateTime = sendTime.toDate();
              late var fmtTime = DateFormat('M월 dd일 h:mm a').format(dateTime);
              final msgYear = dateTime.year;

              if (currentYear != msgYear) {
                //년도 비교. 년도가 다를 때만 년도 표기
                fmtTime = DateFormat('yyyy년 M월 d일 hh:mm').format(dateTime);
              } else {
                fmtTime = DateFormat('M월 d일 h:mm a').format(dateTime);
              }

              return GestureDetector(
                onLongPress: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('이 메시지를 삭제하시겠습니까?'),
                    content: Text(messageDetail),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          print(documents[index].id);
                          deleteImpMsg(roomname, impMsgId);
                          Navigator.pop(context);
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                ),
                child: ListTile(
                  title: Text(
                    userId,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    messageDetail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Text(
                    fmtTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => solve_quiz(
                roomname: roomname,
              ),
            ),
          );
        },
        child: const Text("Quiz!"),
      ),
    );
  }

  // bool isDifferentDate(QueryDocumentSnapshot<Object?> prev,ㅏ두
  //     QueryDocumentSnapshot<Object?> current) {
  //   final prevTime =
  //       (prev.data() as Map<String, dynamic>)['timeStamp'] as Timestamp;
  //   final currentTime =
  //       (current.data() as Map<String, dynamic>)['timeStamp'] as Timestamp;

  //   final prevDateTime = prevTime.toDate();
  //   final currentDateTime = currentTime.toDate();

  //   return prevDateTime.day != currentDateTime.day ||
  //       prevDateTime.month != currentDateTime.month ||
  //       prevDateTime.year != currentDateTime.year;
  // }
  //! 적용 대기
}

//---------------------------------------------------------------------------------------------------
Future<void> deleteImpMsg(String roomname, String impMsgId) async {
  try {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(roomname)
        .collection('imp_msg')
        .doc(impMsgId)
        .delete();
    print('중요한 메시지 삭제 완료!');
  } catch (error) {
    print('중요한 메시지 삭제 실패!: $error');
  }
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//--------------------------------- Simple Message View Code------------------------------------------

class SimpleImportantMessage extends StatelessWidget {
  final String roomname;

  const SimpleImportantMessage({Key? key, required this.roomname})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .doc(roomname)
            .collection('imp_msg')
            .orderBy('timeStamp', descending: true) // 최근 시간 순으로 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          return Column(
            children: [
              SizedBox(
                height: 29,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImportantMessagesPage(roomname: roomname),
                          ),
                        );
                      },
                      child: const Text(
                        '+ 중요 메시지 전부 보기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final data =
                        documents[index].data() as Map<String, dynamic>;

                    final messageDetail = data['msg_detail'] ?? '';
                    final sendTime = data['timeStamp'] as Timestamp;
                    final userId = data['user_id'] ?? '';
                    final dateTime = sendTime.toDate();
                    final fmtTime = DateFormat('M/d').format(dateTime);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0 ||
                            isDifferentDate(
                                //  !CAUTION!: 성능에 문제를 일으킬 수 있음
                                documents[index - 1],
                                documents[index]))
                          Padding(
                            //if문이 true일 때만 실행. 시간을 패딩으로 같은 날짜의 시간 기입'
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, //제거시 날짜 중앙 정렬
                              children: [
                                const Divider(color: Colors.purple),
                                Text(
                                  fmtTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ListTile(
                          //메시지 본문. trailing의 날짜 삭제
                          title: Text(
                            '$userId : $messageDetail',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  //! 문제될 시 삭제 혹은 개선
  bool isDifferentDate(QueryDocumentSnapshot<Object?> prev,
      QueryDocumentSnapshot<Object?> current) {
    final prevTime =
        (prev.data() as Map<String, dynamic>)['timeStamp'] as Timestamp;
    final currentTime =
        (current.data() as Map<String, dynamic>)['timeStamp'] as Timestamp;

    final prevDateTime = prevTime.toDate();
    final currentDateTime = currentTime.toDate();

    return prevDateTime.day != currentDateTime.day ||
        prevDateTime.month != currentDateTime.month ||
        prevDateTime.year != currentDateTime.year;
  }
}
